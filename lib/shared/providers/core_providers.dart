import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/database/app_database.dart';
import '../../core/services/backup_service.dart';
import '../../core/services/file_system_service.dart';
import '../../core/services/impl/file_system_service_impl.dart';
import '../../core/services/impl/notification_service_impl.dart';
import '../../core/services/notification_service.dart';

part 'core_providers.g.dart';

/// Single AppDatabase instance. Never garbage collected.
@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
}

/// Notification service singleton. Initialized once at startup.
@Riverpod(keepAlive: true)
NotificationService notificationService(Ref ref) {
  final service = NotificationServiceImpl();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
}

/// File system service. Stateless — safe as singleton.
@Riverpod(keepAlive: true)
FileSystemService fileSystemService(Ref ref) {
  return FileSystemServiceImpl();
}

/// Backup service stub. Implemented in Phase 9.
/// Throws loudly if called before implementation — catches premature usage.
@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) {
  throw UnimplementedError(
    'BackupService is not implemented until Phase 9.',
  );
}

/// Initializes the notification service at app startup.
/// Errors are logged — app does not crash if notifications fail to init.
@riverpod
Future<void> initializeNotifications(Ref ref) async {
  final service = ref.watch(notificationServiceProvider);
  final result = await service.initialize();
  result.fold(
    onSuccess: (_) {},
    onFailure: (error) {
      // ignore: avoid_print
      print('[LifeOS] Notification init failed: ${error.message}');
    },
  );
}
