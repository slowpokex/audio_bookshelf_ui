/// Base class for all exceptions in the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? details;
  final DateTime timestamp;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.details,
    required this.timestamp,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException: $message';
}

/// General exceptions
class GeneralException extends AppException {
  const GeneralException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Network-related exceptions
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Local storage exceptions
class LocalStorageException extends AppException {
  const LocalStorageException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Audio playback exceptions
class AudioPlaybackException extends AppException {
  const AudioPlaybackException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Authentication exceptions
class AuthenticationException extends AppException {
  const AuthenticationException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Authorization exceptions
class AuthorizationException extends AppException {
  const AuthorizationException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// File system exceptions
class FileSystemException extends AppException {
  const FileSystemException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// AI Agent exceptions
class AIAgentException extends AppException {
  const AIAgentException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Accessibility exceptions
class AccessibilityException extends AppException {
  const AccessibilityException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Community exceptions
class CommunityException extends AppException {
  const CommunityException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Security exceptions
class SecurityException extends AppException {
  const SecurityException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Performance exceptions
class PerformanceException extends AppException {
  const PerformanceException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Configuration exceptions
class ConfigurationException extends AppException {
  const ConfigurationException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Import/Export exceptions
class ImportExportException extends AppException {
  const ImportExportException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Sync exceptions
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Backup/Restore exceptions
class BackupRestoreException extends AppException {
  const BackupRestoreException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Circuit breaker exceptions
class CircuitBreakerOpenException extends AppException {
  const CircuitBreakerOpenException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Agent not found exceptions
class AgentNotFoundException extends AppException {
  const AgentNotFoundException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Command handler not found exceptions
class CommandHandlerNotFoundException extends AppException {
  const CommandHandlerNotFoundException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}

/// Query handler not found exceptions
class QueryHandlerNotFoundException extends AppException {
  const QueryHandlerNotFoundException({
    required super.message,
    super.code,
    super.details,
    required super.timestamp,
    super.stackTrace,
  });
}
