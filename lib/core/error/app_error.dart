/// Sealed hierarchy of all typed errors in LifeOS.
/// Add new error types here as new failure modes are identified.
/// Never throw raw exceptions — always wrap in AppError.
sealed class AppError {
  final String message;
  final Object? cause;

  const AppError(this.message, {this.cause});

  @override
  String toString() => '$runtimeType: $message';
}

/// Thrown when any database read/write/delete operation fails.
final class DatabaseError extends AppError {
  const DatabaseError(super.message, {super.cause});
}

/// Thrown when a file system operation fails (missing file, no permission, etc).
final class FileSystemError extends AppError {
  const FileSystemError(super.message, {super.cause});
}

/// Thrown when input validation fails before hitting the database.
final class ValidationError extends AppError {
  const ValidationError(super.message, {super.cause});
}

/// Thrown when a record expected to exist is not found.
final class NotFoundError extends AppError {
  const NotFoundError(super.message, {super.cause});
}

/// Thrown when a duplicate record violates a uniqueness constraint.
final class ConflictError extends AppError {
  const ConflictError(super.message, {super.cause});
}

/// Thrown when a backup, export, or import operation fails.
final class BackupError extends AppError {
  const BackupError(super.message, {super.cause});
}

/// Catch-all for unexpected errors that don't fit other categories.
final class UnexpectedError extends AppError {
  const UnexpectedError(super.message, {super.cause});
}
