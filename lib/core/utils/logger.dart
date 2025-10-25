import 'dart:developer' as developer;
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Log levels for the application
enum LogLevel {
  trace,
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Logger interface for the application
abstract class Logger {
  void trace(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra});
  void debug(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra});
  void info(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra});
  void warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra});
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra});
  void fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra});
}

/// Production logger implementation
class ProductionLogger implements Logger {
  final String _name;
  final LogLevel _minLevel;
  final bool _enableConsoleOutput;
  final bool _enableFileOutput;
  final bool _enableRemoteLogging;

  ProductionLogger({
    required String name,
    LogLevel minLevel = LogLevel.info,
    bool enableConsoleOutput = true,
    bool enableFileOutput = false,
    bool enableRemoteLogging = false,
  }) : _name = name,
       _minLevel = minLevel,
       _enableConsoleOutput = enableConsoleOutput,
       _enableFileOutput = enableFileOutput,
       _enableRemoteLogging = enableRemoteLogging;

  @override
  void trace(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log(LogLevel.trace, message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log(LogLevel.fatal, message, error: error, stackTrace: stackTrace, extra: extra);
  }

  void _log(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    if (level.index < _minLevel.index) return;

    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level.name.toUpperCase()] $_name: $message';

    if (_enableConsoleOutput) {
      if (kDebugMode) {
        developer.log(
          logMessage,
          name: _name,
          level: _getLogLevel(level),
          error: error,
          stackTrace: stackTrace,
        );
      } else {
        print(logMessage);
        if (error != null) print('Error: $error');
        if (stackTrace != null) print('Stack trace: $stackTrace');
        if (extra != null) print('Extra: $extra');
      }
    }

    if (_enableFileOutput) {
      _writeToFile(level, logMessage, error: error, stackTrace: stackTrace, extra: extra);
    }

    if (_enableRemoteLogging) {
      _sendToRemote(level, message, error: error, stackTrace: stackTrace, extra: extra);
    }
  }

  int _getLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.trace:
        return 500;
      case LogLevel.debug:
        return 700;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  void _writeToFile(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final logFile = File('${directory.path}/logs/app.log');
      
      // Create logs directory if it doesn't exist
      await logFile.parent.create(recursive: true);
      
      final timestamp = DateTime.now().toIso8601String();
      final logEntry = '[$timestamp] [$level.name.toUpperCase()] $_name: $message';
      
      String fullLogEntry = logEntry;
      if (error != null) {
        fullLogEntry += '\nError: $error';
      }
      if (stackTrace != null) {
        fullLogEntry += '\nStack trace: $stackTrace';
      }
      if (extra != null) {
        fullLogEntry += '\nExtra: $extra';
      }
      fullLogEntry += '\n---\n';
      
      await logFile.writeAsString(fullLogEntry, mode: FileMode.append);
      
      // Rotate log file if it gets too large (10MB)
      final fileSize = await logFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        await _rotateLogFile(logFile);
      }
    } catch (e) {
      // Fallback to console if file logging fails
      print('File logging failed: $e');
    }
  }
  
  Future<void> _rotateLogFile(File logFile) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final rotatedFile = File('${logFile.path}.$timestamp');
      await logFile.rename(rotatedFile.path);
      
      // Keep only the last 5 log files
      final logDir = logFile.parent;
      final logFiles = await logDir.list()
          .where((file) => file.path.contains('app.log'))
          .toList();
      
      if (logFiles.length > 5) {
        // Sort by modification time and delete oldest
        logFiles.sort((a, b) => a.statSync().modified.compareTo(b.statSync().modified));
        for (int i = 0; i < logFiles.length - 5; i++) {
          await logFiles[i].delete();
        }
      }
    } catch (e) {
      print('Log rotation failed: $e');
    }
  }

  void _sendToRemote(
    LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) async {
    try {
      // Only send ERROR and FATAL logs to remote service
      if (level.index < LogLevel.error.index) return;
      
      final logData = {
        'timestamp': DateTime.now().toIso8601String(),
        'level': level.name.toUpperCase(),
        'logger': _name,
        'message': message,
        'error': error?.toString(),
        'stackTrace': stackTrace?.toString(),
        'extra': extra,
        'platform': Platform.operatingSystem,
        'version': '1.0.0', // TODO: Get from app version
      };
      
      // TODO: Implement actual remote logging service
      // This could be Sentry, LogRocket, or a custom logging service
      print('Remote logging: $logData');
    } catch (e) {
      print('Remote logging failed: $e');
    }
  }
}

/// Development logger implementation
class DevelopmentLogger implements Logger {
  final String _name;

  DevelopmentLogger({required String name}) : _name = name;

  @override
  void trace(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log('TRACE', message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void debug(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log('DEBUG', message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void info(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log('INFO', message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void warning(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log('WARNING', message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log('ERROR', message, error: error, stackTrace: stackTrace, extra: extra);
  }

  @override
  void fatal(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? extra}) {
    _log('FATAL', message, error: error, stackTrace: stackTrace, extra: extra);
  }

  void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
    Map<String, dynamic>? extra,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] [$level] $_name: $message';

    developer.log(
      logMessage,
      name: _name,
      level: _getLogLevel(level),
      error: error,
      stackTrace: stackTrace,
    );

    if (extra != null) {
      developer.log('Extra data: $extra', name: _name);
    }
  }

  int _getLogLevel(String level) {
    switch (level) {
      case 'TRACE':
        return 500;
      case 'DEBUG':
        return 700;
      case 'INFO':
        return 800;
      case 'WARNING':
        return 900;
      case 'ERROR':
        return 1000;
      case 'FATAL':
        return 1200;
      default:
        return 800;
    }
  }
}

/// Logger factory
class LoggerFactory {
  static Logger createLogger(String name, {bool isProduction = false}) {
    if (isProduction) {
      return ProductionLogger(name: name);
    } else {
      return DevelopmentLogger(name: name);
    }
  }
}

/// Global logger instance
final Logger logger = LoggerFactory.createLogger('AudioBookshelfUI');
