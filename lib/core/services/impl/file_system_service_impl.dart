import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../error/app_error.dart';
import '../../error/result.dart';
import '../file_system_service.dart';

/// Production implementation of FileSystemService.
/// Handles Windows and Android with a single implementation.
/// dart:io covers both platforms for file scanning.
/// file_picker handles the OS-native directory/file picker dialogs.
/// url_launcher handles opening files with OS default applications.
class FileSystemServiceImpl implements FileSystemService {
  @override
  Future<Result<String?>> pickDirectory() async {
    try {
      final path = await FilePicker.platform.getDirectoryPath();
      return Success(path);
    } catch (e) {
      return Failure(
        FileSystemError('Failed to open directory picker', cause: e),
      );
    }
  }

  @override
  Future<Result<List<String>?>> pickFiles({
    List<String>? allowedExtensions,
    bool allowMultiple = true,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: allowMultiple,
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      if (result == null) return const Success(null);

      final paths = result.paths
          .whereType<String>()
          .toList();

      return Success(paths);
    } catch (e) {
      return Failure(
        FileSystemError('Failed to open file picker', cause: e),
      );
    }
  }

  @override
  Future<Result<bool>> fileExists(String path) async {
    try {
      final exists = await File(path).exists();
      return Success(exists);
    } catch (e) {
      return Failure(
        FileSystemError('Failed to check file existence: $path', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> openFile(String path) async {
    try {
      final uri = Uri.file(path);
      final canOpen = await canLaunchUrl(uri);

      if (!canOpen) {
        return Failure(
          FileSystemError('No application registered to open: $path'),
        );
      }

      await launchUrl(uri);
      return const Success(null);
    } catch (e) {
      return Failure(
        FileSystemError('Failed to open file: $path', cause: e),
      );
    }
  }

  @override
  Future<Result<DirectoryScanResult>> scanDirectory(
    String directoryPath, {
    List<String>? extensions,
  }) async {
    try {
      final dir = Directory(directoryPath);
      final exists = await dir.exists();

      if (!exists) {
        return Failure(
          FileSystemError('Directory does not exist: $directoryPath'),
        );
      }

      final files = <FileMetadata>[];
      int totalScanned = 0;
      int failed = 0;

      // Recursive listing with error isolation per file.
      // A single unreadable file does not abort the entire scan.
      await for (final entity in dir.list(recursive: true)) {
        if (entity is! File) continue;

        totalScanned++;
        final ext = p.extension(entity.path).replaceFirst('.', '').toLowerCase();

        // Extension filter
        if (extensions != null && !extensions.contains(ext)) continue;

        try {
          final stat = await entity.stat();
          files.add(FileMetadata(
            path: entity.path,
            name: p.basename(entity.path),
            extension: ext,
            sizeBytes: stat.size,
            createdAt: stat.changed.toUtc(),
            modifiedAt: stat.modified.toUtc(),
          ));
        } catch (_) {
          failed++;
          // Unreadable file — skip and count as failed.
        }
      }

      return Success(DirectoryScanResult(
        files: files,
        totalScanned: totalScanned,
        failed: failed,
      ));
    } catch (e) {
      return Failure(
        FileSystemError('Failed to scan directory: $directoryPath', cause: e),
      );
    }
  }

  @override
  Future<Result<FileMetadata>> getFileMetadata(String path) async {
    try {
      final file = File(path);
      final exists = await file.exists();

      if (!exists) {
        return Failure(NotFoundError('File not found: $path'));
      }

      final stat = await file.stat();
      final ext = p.extension(path).replaceFirst('.', '').toLowerCase();

      return Success(FileMetadata(
        path: path,
        name: p.basename(path),
        extension: ext,
        sizeBytes: stat.size,
        createdAt: stat.changed.toUtc(),
        modifiedAt: stat.modified.toUtc(),
      ));
    } catch (e) {
      return Failure(
        FileSystemError('Failed to get file metadata: $path', cause: e),
      );
    }
  }

  @override
  Future<Result<String>> getAppDocumentsPath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return Success(dir.path);
    } catch (e) {
      return Failure(
        FileSystemError('Failed to resolve app documents directory', cause: e),
      );
    }
  }

  @override
  Stream<String> watchDirectory(String directoryPath) {
    final dir = Directory(directoryPath);
    return dir
        .watch(recursive: true)
        .map((event) => event.path)
        .handleError((_) {
      // Directory watcher errors (e.g. directory deleted) are swallowed.
      // The File Manager module will detect stale entries on next rescan.
    });
  }
}
