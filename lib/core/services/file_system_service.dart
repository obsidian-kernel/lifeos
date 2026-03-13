import '../error/result.dart';

/// Metadata returned when indexing a file from the filesystem.
class FileMetadata {
  final String path;
  final String name;
  final String extension;
  final int sizeBytes;
  final DateTime createdAt;
  final DateTime modifiedAt;

  const FileMetadata({
    required this.path,
    required this.name,
    required this.extension,
    required this.sizeBytes,
    required this.createdAt,
    required this.modifiedAt,
  });
}

/// Result of a directory scan operation.
class DirectoryScanResult {
  final List<FileMetadata> files;
  final int totalScanned;
  final int failed;

  const DirectoryScanResult({
    required this.files,
    required this.totalScanned,
    required this.failed,
  });
}

/// Abstract contract for all file system operations in LifeOS.
///
/// Design decisions:
/// - Abstract interface. Platform implementations in impl/.
/// - No binary content ever passes through this service.
///   Only paths and metadata. The DB stores paths — never file content.
/// - openFile delegates to OS default application — no in-app viewer.
/// - scanDirectory is used by both the File Manager and Music Player modules.
///   Both need directory indexing — shared infrastructure.
/// - watchDirectory returns a stream of changed paths.
///   Used by File Manager to detect moved/deleted files and mark them stale.
///
/// Platform implementations:
/// - Windows: dart:io + path_provider + url_launcher
/// - Android: file_picker + url_launcher
abstract interface class FileSystemService {
  /// Prompt the user to pick a single directory.
  /// Returns the selected path, or null if cancelled.
  Future<Result<String?>> pickDirectory();

  /// Prompt the user to pick one or more files.
  /// [allowedExtensions] filters the picker (e.g. ['mp3', 'flac']).
  /// Returns selected file paths, or null if cancelled.
  Future<Result<List<String>?>> pickFiles({
    List<String>? allowedExtensions,
    bool allowMultiple = true,
  });

  /// Returns true if the file at [path] currently exists on disk.
  Future<Result<bool>> fileExists(String path);

  /// Opens [path] using the OS default application.
  /// No in-app viewer. Let the OS handle it.
  Future<Result<void>> openFile(String path);

  /// Scans [directoryPath] recursively and returns metadata for all files.
  /// [extensions] filters results (e.g. ['mp3', 'flac'] for music scan).
  /// Pass null to return all files regardless of extension.
  Future<Result<DirectoryScanResult>> scanDirectory(
    String directoryPath, {
    List<String>? extensions,
  });

  /// Returns metadata for a single file at [path].
  Future<Result<FileMetadata>> getFileMetadata(String path);

  /// Returns the application's document directory path.
  /// Used for backup file placement.
  Future<Result<String>> getAppDocumentsPath();

  /// Watch [directoryPath] for file system changes.
  /// Emits the changed file path when a create/modify/delete event occurs.
  /// Used by File Manager to detect stale indexed files.
  Stream<String> watchDirectory(String directoryPath);
}