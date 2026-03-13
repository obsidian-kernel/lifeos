import '../error/result.dart';

/// Metadata embedded in every backup file.
/// Version-tagged so future import logic can handle old backup formats.
class BackupManifest {
  final int backupSchemaVersion;
  final DateTime createdAt;
  final String appVersion;
  final Map<String, int> recordCounts;

  const BackupManifest({
    required this.backupSchemaVersion,
    required this.createdAt,
    required this.appVersion,
    required this.recordCounts,
  });

  Map<String, dynamic> toJson() => {
        'backupSchemaVersion': backupSchemaVersion,
        'createdAt': createdAt.toIso8601String(),
        'appVersion': appVersion,
        'recordCounts': recordCounts,
      };

  factory BackupManifest.fromJson(Map<String, dynamic> json) =>
      BackupManifest(
        backupSchemaVersion: json['backupSchemaVersion'] as int,
        createdAt: DateTime.parse(json['createdAt'] as String),
        appVersion: json['appVersion'] as String,
        recordCounts: Map<String, int>.from(
          json['recordCounts'] as Map,
        ),
      );
}

/// Result of a backup validation dry-run.
class BackupValidationResult {
  final bool isValid;
  final BackupManifest? manifest;
  final List<String> errors;
  final List<String> warnings;

  const BackupValidationResult({
    required this.isValid,
    this.manifest,
    this.errors = const [],
    this.warnings = const [],
  });
}

/// Conflict resolution strategy during restore.
enum RestoreConflictStrategy {
  /// Skip records that already exist in the database.
  skipExisting,

  /// Overwrite existing records with backup data.
  overwriteExisting,

  /// Abort the entire restore if any conflict is detected.
  abortOnConflict,
}

/// Abstract contract for backup and restore operations.
///
/// Design decisions:
/// - Two backup formats: JSON (human-readable, portable) and raw SQLite file.
///   JSON is the primary format — it survives schema migrations.
///   Raw SQLite export is secondary — for exact point-in-time snapshots.
/// - Every JSON backup is version-tagged via BackupManifest.
///   Future import logic reads the version and applies transformation if needed.
/// - Dry-run validation before committing any restore.
///   Users must be able to inspect what will be imported before it lands.
/// - Conflict resolution is caller-specified, not hardcoded.
///
/// Implementation in Phase 9. Interface defined now so the provider
/// tree and dependency graph are correct from Phase 0 onward.
abstract interface class BackupService {
  /// Export all data to a JSON file at [destinationPath].
  /// Returns the final file path on success.
  Future<Result<String>> exportJson(String destinationPath);

  /// Export raw SQLite database file to [destinationPath].
  /// Returns the final file path on success.
  Future<Result<String>> exportDatabase(String destinationPath);

  /// Validate a backup file at [backupPath] without importing.
  /// Returns validation result with manifest and any errors/warnings.
  Future<Result<BackupValidationResult>> validateBackup(String backupPath);

  /// Import data from a JSON backup at [backupPath].
  /// [conflictStrategy] determines behavior when records already exist.
  Future<Result<void>> importJson(
    String backupPath, {
    RestoreConflictStrategy conflictStrategy =
        RestoreConflictStrategy.skipExisting,
  });

  /// Returns the default backup directory path for this platform.
  Future<Result<String>> getDefaultBackupDirectory();
}