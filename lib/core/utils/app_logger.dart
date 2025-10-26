import 'logger.dart';

/// Structured logging utility for the Audio Bookshelf UI application
/// Follows the logging architecture defined in the project documentation
class AppLogger {
  static final Logger _logger = LoggerFactory.createLogger('AudioBookshelfUI');
  
  /// Log audio playback events
  static void logAudioEvent(String event, Map<String, dynamic> data) {
    _logger.info('Audio Event: $event', extra: {
      'category': 'Audio Playback',
      'event': event,
      'data': data,
    });
  }
  
  /// Log audio operations
  static void logAudioOperation(String operation, String component, {int? duration, Map<String, dynamic>? extra}) {
    _logger.info('Audio Operation: $operation in $component', extra: {
      'category': 'Audio Playback',
      'operation': operation,
      'component': component,
      'duration': duration,
      'extra': extra,
    });
  }
  
  /// Log audio playback errors
  static void logAudioError(String operation, String component, String error, StackTrace? stackTrace) {
    _logger.error('Audio Error: $operation in $component - $error', 
      stackTrace: stackTrace,
      extra: {
        'category': 'Audio Playback',
        'operation': operation,
        'component': component,
        'error': error,
      }
    );
  }
  
  /// Log user actions and interactions
  static void logUserAction(String action, String screen, {Map<String, dynamic>? data}) {
    _logger.info('User Action: $action on $screen', extra: {
      'category': 'User Actions',
      'action': action,
      'screen': screen,
      'data': data,
    });
  }
  
  /// Log navigation events
  static void logNavigation(String from, String to, {String? method}) {
    _logger.info('Navigation: $from -> $to', extra: {
      'category': 'User Actions',
      'action': 'navigation',
      'from': from,
      'to': to,
      'method': method,
    });
  }
  
  /// Log API calls and network requests
  static void logApiCall(String method, String endpoint, {int? statusCode, int? duration}) {
    _logger.info('API Call: $method $endpoint', extra: {
      'category': 'API Calls',
      'method': method,
      'endpoint': endpoint,
      'statusCode': statusCode,
      'duration': duration,
    });
  }
  
  /// Log API errors
  static void logApiError(String method, String endpoint, String error, {int? statusCode}) {
    _logger.error('API Error: $method $endpoint - $error', extra: {
      'category': 'API Calls',
      'method': method,
      'endpoint': endpoint,
      'error': error,
      'statusCode': statusCode,
    });
  }
  
  /// Log database operations
  static void logDatabaseOperation(String operation, String table, {int? recordCount, int? duration}) {
    _logger.debug('Database Operation: $operation on $table', extra: {
      'category': 'Database Operations',
      'operation': operation,
      'table': table,
      'recordCount': recordCount,
      'duration': duration,
    });
  }
  
  /// Log database errors
  static void logDatabaseError(String operation, String table, String error, StackTrace? stackTrace) {
    _logger.error('Database Error: $operation on $table - $error', 
      stackTrace: stackTrace,
      extra: {
        'category': 'Database Operations',
        'operation': operation,
        'table': table,
        'error': error,
      }
    );
  }
  
  /// Log AI agent activities
  static void logAiAgentActivity(String agent, String activity, {Map<String, dynamic>? data}) {
    _logger.info('AI Agent Activity: $agent - $activity', extra: {
      'category': 'AI Agent Activities',
      'agent': agent,
      'activity': activity,
      'data': data,
    });
  }
  
  /// Log AI agent errors
  static void logAiAgentError(String agent, String error, StackTrace? stackTrace) {
    _logger.error('AI Agent Error: $agent - $error', 
      stackTrace: stackTrace,
      extra: {
        'category': 'AI Agent Activities',
        'agent': agent,
        'error': error,
      }
    );
  }
  
  /// Log performance metrics
  static void logPerformance(String metric, double value, {String? unit, Map<String, dynamic>? context}) {
    _logger.info('Performance: $metric = $value${unit ?? ''}', extra: {
      'category': 'Performance',
      'metric': metric,
      'value': value,
      'unit': unit,
      'context': context,
    });
  }
  
  /// Log security events
  static void logSecurityEvent(String event, {Map<String, dynamic>? data}) {
    _logger.warning('Security Event: $event', extra: {
      'category': 'Security',
      'event': event,
      'data': data,
    });
  }
  
  /// Log authentication events
  static void logAuthentication(String action, {bool? success, String? userId}) {
    _logger.info('Authentication: $action', extra: {
      'category': 'Security',
      'action': action,
      'success': success,
      'userId': userId,
    });
  }
  
  /// Log application lifecycle events
  static void logAppLifecycle(String event, {Map<String, dynamic>? data}) {
    _logger.info('App Lifecycle: $event', extra: {
      'category': 'Application',
      'event': event,
      'data': data,
    });
  }
  
  /// Log general application errors
  static void logError(String error, StackTrace? stackTrace, {Map<String, dynamic>? context}) {
    _logger.error('Application Error: $error', 
      stackTrace: stackTrace,
      extra: {
        'category': 'Application',
        'error': error,
        'context': context,
      }
    );
  }
  
  /// Log fatal errors that may cause app termination
  static void logFatal(String error, StackTrace? stackTrace, {Map<String, dynamic>? context}) {
    _logger.fatal('Fatal Error: $error', 
      stackTrace: stackTrace,
      extra: {
        'category': 'Application',
        'error': error,
        'context': context,
      }
    );
  }
  
  /// Log debug information
  static void logDebug(String message, {Map<String, dynamic>? data}) {
    _logger.debug('Debug: $message', extra: {
      'category': 'Debug',
      'message': message,
      'data': data,
    });
  }
  
  /// Log trace information for detailed debugging
  static void logTrace(String message, {Map<String, dynamic>? data}) {
    _logger.trace('Trace: $message', extra: {
      'category': 'Trace',
      'message': message,
      'data': data,
    });
  }
}
