import 'package:equatable/equatable.dart';

/// Base class for all failures in the application
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final DateTime timestamp;

  const Failure({
    required this.message,
    this.code,
    this.details,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [message, code, details, timestamp];
}

/// General failures
class GeneralFailure extends Failure {
  const GeneralFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Local storage failures
class LocalStorageFailure extends Failure {
  const LocalStorageFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Audio playback failures
class AudioPlaybackFailure extends Failure {
  const AudioPlaybackFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Authorization failures
class AuthorizationFailure extends Failure {
  const AuthorizationFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// File system failures
class FileSystemFailure extends Failure {
  const FileSystemFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// AI Agent failures
class AIAgentFailure extends Failure {
  const AIAgentFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Accessibility failures
class AccessibilityFailure extends Failure {
  const AccessibilityFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Community failures
class CommunityFailure extends Failure {
  const CommunityFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Security failures
class SecurityFailure extends Failure {
  const SecurityFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Performance failures
class PerformanceFailure extends Failure {
  const PerformanceFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Configuration failures
class ConfigurationFailure extends Failure {
  const ConfigurationFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Import/Export failures
class ImportExportFailure extends Failure {
  const ImportExportFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Sync failures
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}

/// Backup/Restore failures
class BackupRestoreFailure extends Failure {
  const BackupRestoreFailure({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
  });
}
