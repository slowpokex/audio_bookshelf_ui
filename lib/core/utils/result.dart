import 'package:equatable/equatable.dart';

/// A generic result class that can represent either success or failure
sealed class Result<T> extends Equatable {
  const Result();

  /// Creates a successful result with data
  const factory Result.success(T data) = Success<T>;

  /// Creates a failure result with error information
  const factory Result.failure(String message) = Failure<T>;

  /// Returns true if this result represents a success
  bool get isSuccess => this is Success<T>;

  /// Returns true if this result represents a failure
  bool get isFailure => this is Failure<T>;

  /// Returns the data if this is a success, null otherwise
  T? get data => isSuccess ? (this as Success<T>).data : null;

  /// Returns the failure message if this is a failure, null otherwise
  String? get failureMessage => isFailure ? (this as Failure<T>).message : null;

  /// Maps the data if this is a success
  Result<U> map<U>(U Function(T) mapper) {
    if (isSuccess) {
      return Result.success(mapper((this as Success<T>).data));
    } else {
      return Result.failure((this as Failure<T>).message);
    }
  }

  /// Maps the failure if this is a failure
  Result<T> mapFailure(String Function(String) mapper) {
    if (isFailure) {
      return Result.failure(mapper((this as Failure<T>).message));
    } else {
      return Result.success((this as Success<T>).data);
    }
  }

  /// Executes a function if this is a success
  Result<T> onSuccess(void Function(T) callback) {
    if (isSuccess) {
      callback((this as Success<T>).data);
    }
    return this;
  }

  /// Executes a function if this is a failure
  Result<T> onFailure(void Function(String) callback) {
    if (isFailure) {
      callback((this as Failure<T>).message);
    }
    return this;
  }

  /// Returns the data if this is a success, or a default value if it's a failure
  T getOrElse(T defaultValue) {
    return isSuccess ? (this as Success<T>).data : defaultValue;
  }

  /// Returns the data if this is a success, or throws an exception if it's a failure
  T getOrThrow() {
    if (isSuccess) {
      return (this as Success<T>).data;
    } else {
      throw Exception((this as Failure<T>).message);
    }
  }

  /// Returns the data if this is a success, or computes a default value if it's a failure
  T getOrElseCompute(T Function() defaultValue) {
    return isSuccess ? (this as Success<T>).data : defaultValue();
  }
}

/// Represents a successful result
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  List<Object?> get props => [data];
}

/// Represents a failed result
class Failure<T> extends Result<T> {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Extension methods for Result
extension ResultExtensions<T> on Result<T> {
  /// Chains another operation if this result is a success
  Result<U> flatMap<U>(Result<U> Function(T) mapper) {
    if (isSuccess) {
      return mapper((this as Success<T>).data);
    } else {
      return Result.failure((this as Failure<T>).message);
    }
  }

  /// Chains another operation if this result is a failure
  Result<T> flatMapFailure(Result<T> Function(String) mapper) {
    if (isFailure) {
      return mapper((this as Failure<T>).message);
    } else {
      return Result.success((this as Success<T>).data);
    }
  }

  /// Transforms this result into another type
  U fold<U>(U Function(T) onSuccess, U Function(String) onFailure) {
    if (isSuccess) {
      return onSuccess((this as Success<T>).data);
    } else {
      return onFailure((this as Failure<T>).message);
    }
  }

  /// Returns the data if this is a success, or null if it's a failure
  T? getOrNull() {
    return isSuccess ? (this as Success<T>).data : null;
  }

  /// Returns the data if this is a success, or a default value if it's a failure
  T getOrDefault(T defaultValue) {
    return isSuccess ? (this as Success<T>).data : defaultValue;
  }
}
