import 'app_error.dart';

sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
        Success<T> s => s.value,
        Failure<T> _ => null,
      };

  AppError? get errorOrNull => switch (this) {
        Success<T> _ => null,
        Failure<T> f => f.error,
      };

  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(AppError error) onFailure,
  }) =>
      switch (this) {
        Success<T> s => onSuccess(s.value),
        Failure<T> f => onFailure(f.error),
      };
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);

  @override
  String toString() => 'Success($value)';
}

final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);

  @override
  String toString() => 'Failure(${error.message})';
}