import '../error/result.dart';

/// Notification payload model.
/// Carries structured data through notification tap events.
class NotificationPayload {
  final String featureKey; // e.g. 'habit', 'task', 'pomodoro'
  final String entityId;   // UUID of the related entity
  final String? action;    // Optional: 'complete', 'snooze', 'open'

  const NotificationPayload({
    required this.featureKey,
    required this.entityId,
    this.action,
  });

  /// Serialize to string for storage in notification payload field.
  String serialize() => '$featureKey|$entityId|${action ?? ''}';

  /// Deserialize from notification payload string.
  factory NotificationPayload.deserialize(String raw) {
    final parts = raw.split('|');
    if (parts.length < 2) {
      throw const FormatException('Invalid notification payload format');
    }
    return NotificationPayload(
      featureKey: parts[0],
      entityId: parts[1],
      action: parts.length > 2 && parts[2].isNotEmpty ? parts[2] : null,
    );
  }
}

/// Recurrence rule for scheduled notifications.
enum NotificationRecurrence {
  none,    // One-shot
  daily,
  weekly,
}

/// Abstract contract for all notification operations in LifeOS.
///
/// Design decisions:
/// - Abstract interface. Platform implementations live in impl/.
/// - All methods return Result<T> — no raw exceptions surface to callers.
/// - Stream-based tap handling — callers subscribe, not poll.
/// - Notification IDs are caller-managed (derived from entity UUIDs).
///   This allows deterministic cancellation without storing notification IDs.
///
/// Platform implementations:
/// - Android: flutter_local_notifications with exact alarm scheduling
/// - Windows: flutter_local_notifications Windows channel
abstract interface class NotificationService {
  /// Initialize the notification service.
  /// Must be called once at app startup before any scheduling.
  Future<Result<void>> initialize();

  /// Schedule a one-time notification at [scheduledAt].
  /// [id] must be unique per notification — use entity UUID hash.
  Future<Result<void>> scheduleOnce({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime scheduledAt,
    NotificationPayload? payload,
  });

  /// Schedule a repeating daily notification at [timeOfDay].
  Future<Result<void>> scheduleDaily({
    required int id,
    required String channelId,
    required String title,
    required String body,
    required DateTime timeOfDay,
    NotificationPayload? payload,
  });

  /// Cancel a specific notification by ID.
  Future<Result<void>> cancel(int id);

  /// Cancel all scheduled notifications across all channels.
  Future<Result<void>> cancelAll();

  /// Stream of notification payloads when user taps a notification.
  /// Features subscribe to this stream and handle their own payloads.
  Stream<NotificationPayload> get onNotificationTap;

  /// Returns all currently pending notification IDs.
  /// Used to verify scheduling state during debugging.
  Future<Result<List<int>>> pendingNotificationIds();
}