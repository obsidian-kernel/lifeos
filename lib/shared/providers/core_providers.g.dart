// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'core_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appDatabaseHash() => r'59cce38d45eeaba199eddd097d8e149d66f9f3e1';

/// Single AppDatabase instance. Never garbage collected.
///
/// Copied from [appDatabase].
@ProviderFor(appDatabase)
final appDatabaseProvider = Provider<AppDatabase>.internal(
  appDatabase,
  name: r'appDatabaseProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$appDatabaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppDatabaseRef = ProviderRef<AppDatabase>;
String _$notificationServiceHash() =>
    r'29b07c37284e78c5c58303bcd0f85dfc0650b93d';

/// Notification service singleton. Initialized once at startup.
///
/// Copied from [notificationService].
@ProviderFor(notificationService)
final notificationServiceProvider = Provider<NotificationService>.internal(
  notificationService,
  name: r'notificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef NotificationServiceRef = ProviderRef<NotificationService>;
String _$fileSystemServiceHash() => r'63e4d88b4218dfe5ac5512504a5f54683b9cee0e';

/// File system service. Stateless — safe as singleton.
///
/// Copied from [fileSystemService].
@ProviderFor(fileSystemService)
final fileSystemServiceProvider = Provider<FileSystemService>.internal(
  fileSystemService,
  name: r'fileSystemServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$fileSystemServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FileSystemServiceRef = ProviderRef<FileSystemService>;
String _$backupServiceHash() => r'e2f35718680aa89e8a612685cfca873499739408';

/// Backup service stub. Implemented in Phase 9.
/// Throws loudly if called before implementation — catches premature usage.
///
/// Copied from [backupService].
@ProviderFor(backupService)
final backupServiceProvider = Provider<BackupService>.internal(
  backupService,
  name: r'backupServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$backupServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BackupServiceRef = ProviderRef<BackupService>;
String _$initializeNotificationsHash() =>
    r'c3ee16b3661989506ef1fb6125a3aac5b361eb0b';

/// Initializes the notification service at app startup.
/// Errors are logged — app does not crash if notifications fail to init.
///
/// Copied from [initializeNotifications].
@ProviderFor(initializeNotifications)
final initializeNotificationsProvider =
    AutoDisposeFutureProvider<void>.internal(
  initializeNotifications,
  name: r'initializeNotificationsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$initializeNotificationsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef InitializeNotificationsRef = AutoDisposeFutureProviderRef<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
