import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../error/app_error.dart';
import '../../error/result.dart';
import '../../utils/constants.dart';
import '../notification_service.dart';

class NotificationServiceImpl implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final StreamController<NotificationPayload> _tapController =
      StreamController<NotificationPayload>.broadcast();

  bool _initialized = false;

  @override
  Stream<NotificationPayload> get onNotificationTap => _tapController.stream;

  @override
  Future<Result<void>> initialize() async {
    if (_initialized) return const Success(null);

    try {
      // Initialize timezone database — required before any zonedSchedule call
      tz_data.initializeTimeZones();

      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const initSettings = InitializationSettings(
        android: androidSettings,
      );

      await _plugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationResponse,
      );

      if (defaultTargetPlatform == TargetPlatform.android) {
        await _createAndroidChannels();
      }

      _initialized = true;
      return const Success(null);
    } catch (e) {
      return Failure(
        UnexpectedError('Failed to initialize notification service', cause: e),
      );
    }
  }

  /// Converts a UTC DateTime to TZDateTime in the local timezone.
  /// zonedSchedule requires TZDateTime — plain DateTime is rejected at runtime.
  tz.TZDateTime _toTZDateTime(DateTime dt) {
    final local = tz.local;
    final utc = dt.toUtc();
    return tz.TZDateTime(
      local,
      utc.year,
      utc.month,
      utc.day,
      utc.hour,
      utc.minute,
      utc.second,
    );
  }

  void _onNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      final parsed = NotificationPayload.deserialize(payload);
      _tapController.add(parsed);
    } catch (_) {
      // Malformed payload — discard silently
    }
  }

  Future<void> _createAndroidChannels() async {
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return;

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.habitNotificationChannelId,
        AppConstants.habitNotificationChannelName,
        importance: Importance.high,
      ),
    );

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.taskNotificationChannelId,
        AppConstants.taskNotificationChannelName,
        importance: Importance.high,
      ),
    );

    await androidImpl.createNotificationChannel(
      const AndroidNotificationChannel(
        AppConstants.pomodoroNotificationChannelId,
        AppConstants.pomodoroNotificationChannelName,
        importance: Importance.max,
      ),
    );
  }

  NotificationDetails _buildDetails(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelId,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  @override
  Future<Result<void>> scheduleOnce({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    NotificationPayload? payload,
  }) async {
    if (!_initialized) {
      return const Failure(UnexpectedError('NotificationService not initialized'));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _toTZDateTime(scheduledAt),
        _buildDetails(channelId),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload?.serialize(),
      );
      return const Success(null);
    } catch (e) {
      return Failure(
        UnexpectedError('Failed to schedule notification id:$id', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> scheduleDaily({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime timeOfDay,
    NotificationPayload? payload,
  }) async {
    if (!_initialized) {
      return const Failure(UnexpectedError('NotificationService not initialized'));
    }

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        _toTZDateTime(timeOfDay),
        _buildDetails(channelId),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: payload?.serialize(),
      );
      return const Success(null);
    } catch (e) {
      return Failure(
        UnexpectedError('Failed to schedule daily notification id:$id', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> cancel(int id) async {
    try {
      await _plugin.cancel(id);
      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedError('Failed to cancel notification id:$id', cause: e));
    }
  }

  @override
  Future<Result<void>> cancelAll() async {
    try {
      await _plugin.cancelAll();
      return const Success(null);
    } catch (e) {
      return Failure(UnexpectedError('Failed to cancel all notifications', cause: e));
    }
  }

  @override
  Future<Result<List<int>>> pendingNotificationIds() async {
    try {
      final pending = await _plugin.pendingNotificationRequests();
      return Success(pending.map((r) => r.id).toList());
    } catch (e) {
      return Failure(UnexpectedError('Failed to fetch pending notifications', cause: e));
    }
  }

  void dispose() {
    _tapController.close();
  }
}