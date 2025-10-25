import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Logging configuration for the Audio Bookshelf UI application
class LoggingConfig {
  static const String _configYaml = '''
# Logging configuration
logging:
  level: INFO
  console_output: true
  file_output: true
  max_file_size: 10MB
  max_files: 5
  include_stack_trace: true
  structured_format: true
''';

  /// Get the appropriate log level based on environment
  static LogLevel getLogLevel() {
    if (kDebugMode) {
      return LogLevel.debug;
    } else {
      return LogLevel.info;
    }
  }

  /// Get console output setting based on environment
  static bool getConsoleOutput() {
    return true; // Always enable console output for debugging
  }

  /// Get file output setting based on environment
  static bool getFileOutput() {
    return kDebugMode; // Enable file logging in debug mode
  }

  /// Get remote logging setting based on environment
  static bool getRemoteLogging() {
    return !kDebugMode; // Enable remote logging in production
  }

  /// Get max file size in bytes (10MB)
  static int getMaxFileSize() {
    return 10 * 1024 * 1024; // 10MB
  }

  /// Get max number of log files to keep
  static int getMaxFiles() {
    return 5;
  }

  /// Get whether to include stack traces
  static bool getIncludeStackTrace() {
    return true;
  }

  /// Get whether to use structured format
  static bool getStructuredFormat() {
    return true;
  }

  /// Get the configuration as a map
  static Map<String, dynamic> getConfig() {
    return {
      'level': getLogLevel().name,
      'console_output': getConsoleOutput(),
      'file_output': getFileOutput(),
      'remote_logging': getRemoteLogging(),
      'max_file_size': getMaxFileSize(),
      'max_files': getMaxFiles(),
      'include_stack_trace': getIncludeStackTrace(),
      'structured_format': getStructuredFormat(),
    };
  }

  /// Get the YAML configuration string
  static String getConfigYaml() {
    return _configYaml;
  }
}
