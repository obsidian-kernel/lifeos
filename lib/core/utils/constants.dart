/// Application-wide constants for LifeOS.
/// No magic strings or magic numbers anywhere else in the codebase.
abstract final class AppConstants {
  // App identity
  static const String appName = "LifeOS";
  static const String appVersion = "1.0.0";

  // Database
  static const String databaseFileName = 'lifeos.db';
  static const String databaseFolder = 'lifeos';

  // Notification channel IDs
  static const String habitNotificationChannelId = 'lifeos_habits';
  static const String taskNotificationChannelId = 'lifeos_tasks';
  static const String pomodoroNotificationChannelId = 'lifeos_pomodoro';

  static const String habitNotificationChannelName = 'Habit Reminders';
  static const String taskNotificationChannelName = 'Task Reminders';
  static const String pomodoroNotificationChannelName = 'Pomodoro Alerts';

  // Pagination
  static const int defaultPageSize = 50;
  static const int analyticsPageSize = 365;

  // Pomodoro defaults (in minutes)
  static const int defaultWorkDuration = 25;
  static const int defaultShortBreak = 5;
  static const int defaultLongBreak = 15;
  static const int defaultSessionsBeforeLongBreak = 4;

  // File indexing
  static const List<String> supportedAudioExtensions = [
    'mp3',
    'flac',
    'aac',
    'm4a',
    'ogg',
    'wav'
  ];

  // Backup
  static const String backupFileExtension = '.lifeos_backup';
  static const int currentBackupSchemaVersion = 1;
}
