# Audio Bookshelf UI - Logging System

## Overview

This document describes the comprehensive logging system implemented for the Audio Bookshelf UI application, following the project documentation requirements.

## Architecture

### Log Levels
- **TRACE**: Detailed information for debugging (500)
- **DEBUG**: General debugging information (700)
- **INFO**: General application flow information (800)
- **WARNING**: Potential issues that don't stop execution (900)
- **ERROR**: Error conditions that need attention (1000)
- **FATAL**: Critical errors that may cause app termination (1200)

### Logging Categories
- **Audio Playback**: Track audio events, errors, and performance
- **User Actions**: Log user interactions and navigation
- **API Calls**: Monitor network requests and responses
- **Database Operations**: Track data access and modifications
- **AI Agent Activities**: Log agent processing and results
- **Performance**: Monitor app performance and resource usage
- **Security**: Track authentication and authorization events
- **Application**: General application lifecycle events

## Implementation

### Core Logger (`lib/core/utils/logger.dart`)

The core logging system provides two implementations:

#### ProductionLogger
- Configurable log levels and outputs
- File logging with rotation (10MB max, 5 files)
- Remote logging for monitoring
- Structured data support

#### DevelopmentLogger
- Enhanced debugging output
- Detailed stack traces
- Console-focused logging

### Structured Logger (`lib/core/utils/app_logger.dart`)

The `AppLogger` class provides structured logging methods for different categories:

```dart
// Audio events
AppLogger.logAudioEvent('play', {'bookId': '123', 'position': 45.2});
AppLogger.logAudioError('Failed to load audio', stackTrace, {'bookId': '123'});

// User actions
AppLogger.logUserAction('search', 'library', {'query': 'mystery'});
AppLogger.logNavigation('library', 'player', method: 'tap');

// API calls
AppLogger.logApiCall('GET', '/api/books', statusCode: 200, duration: 150);
AppLogger.logApiError('POST', '/api/login', 'Invalid credentials', statusCode: 401);

// Database operations
AppLogger.logDatabaseOperation('insert', 'audiobooks', recordCount: 1, duration: 25);
AppLogger.logDatabaseError('select', 'audiobooks', 'Connection failed', stackTrace);

// AI agent activities
AppLogger.logAiAgentActivity('recommendation', 'processing', {'userId': '123'});
AppLogger.logAiAgentError('recommendation', 'Failed to process', stackTrace);

// Performance metrics
AppLogger.logPerformance('app_startup', 1.2, unit: 'seconds');
AppLogger.logPerformance('memory_usage', 45.6, unit: 'MB');

// Security events
AppLogger.logSecurityEvent('login_attempt', {'ip': '192.168.1.1'});
AppLogger.logAuthentication('login', success: true, userId: '123');

// Application lifecycle
AppLogger.logAppLifecycle('app_started');
AppLogger.logError('Unexpected error', stackTrace, {'context': 'user_action'});
```

### Configuration (`lib/core/config/logging_config.dart`)

The logging configuration adapts to different environments:

```dart
// Debug mode
- Log Level: DEBUG
- Console Output: Enabled
- File Output: Enabled
- Remote Logging: Disabled

// Production mode
- Log Level: INFO
- Console Output: Enabled
- File Output: Disabled
- Remote Logging: Enabled
```

## Usage Examples

### Basic Logging
```dart
import 'package:audio_bookshelf_ui/core/utils/app_logger.dart';

// Simple logging
AppLogger.logDebug('User clicked play button');
AppLogger.logInfo('Application started successfully');
AppLogger.logError('Database connection failed', stackTrace);
```

### Structured Logging
```dart
// Audio playback tracking
AppLogger.logAudioEvent('play', {
  'bookId': '123',
  'position': 45.2,
  'duration': 180.5,
  'speed': 1.0
});

// User interaction tracking
AppLogger.logUserAction('search', 'library', {
  'query': 'mystery novels',
  'results': 15,
  'filters': ['genre', 'author']
});

// Performance monitoring
AppLogger.logPerformance('database_query', 0.25, unit: 'seconds', context: {
  'table': 'audiobooks',
  'operation': 'select',
  'recordCount': 100
});
```

### Error Handling
```dart
try {
  await loadAudiobook(bookId);
} catch (e, stackTrace) {
  AppLogger.logError('Failed to load audiobook', stackTrace, {
    'bookId': bookId,
    'userId': currentUser.id,
    'action': 'load_audiobook'
  });
}
```

## File Logging

### Log File Location
- **Android**: `/data/data/com.example.audio_bookshelf_ui/app_flutter/logs/app.log`
- **iOS**: `Documents/logs/app.log`
- **Desktop**: `Documents/logs/app.log`

### Log Rotation
- Maximum file size: 10MB
- Maximum files: 5
- Automatic rotation when size limit reached
- Oldest files deleted when limit exceeded

### Log Format
```
[2024-01-15T10:30:45.123Z] [INFO] AudioBookshelfUI: User Action: search on library
Extra: {"category": "User Actions", "action": "search", "screen": "library", "data": {"query": "mystery"}}
---
```

## Remote Logging

### Configuration
Remote logging is enabled in production mode and sends ERROR and FATAL logs to monitoring services.

### Data Structure
```json
{
  "timestamp": "2024-01-15T10:30:45.123Z",
  "level": "ERROR",
  "logger": "AudioBookshelfUI",
  "message": "Database connection failed",
  "error": "Connection timeout",
  "stackTrace": "...",
  "extra": {"context": "user_action"},
  "platform": "android",
  "version": "1.0.0"
}
```

## Privacy & Security

### Data Protection
- **PII Protection**: Never log personal identifiable information
- **Data Anonymization**: User IDs are hashed in logs
- **Secure Transmission**: Logs are encrypted before transmission
- **Retention Policies**: Automatic log cleanup and rotation

### GDPR Compliance
- User consent required for data collection
- Logs can be exported and deleted on request
- No sensitive user data in logs

## Performance Impact

### Optimizations
- **Asynchronous Logging**: Non-blocking log operations
- **Log Buffering**: Batch log entries for efficiency
- **Level Filtering**: Only process logs above minimum level
- **File Rotation**: Prevents disk space issues

### Monitoring
- Log performance metrics to track impact
- Monitor log file sizes and rotation
- Track remote logging success rates

## Best Practices

### Do's
- Use appropriate log levels
- Include relevant context in logs
- Use structured logging for complex data
- Log errors with stack traces
- Monitor log file sizes

### Don'ts
- Don't log sensitive information
- Don't use print() statements
- Don't log in tight loops
- Don't ignore log rotation
- Don't log user passwords or tokens

## Troubleshooting

### Common Issues
1. **Log files not created**: Check file permissions
2. **Remote logging fails**: Check network connectivity
3. **Performance impact**: Reduce log level or disable file logging
4. **Disk space issues**: Check log rotation settings

### Debug Commands
```bash
# Check log files
ls -la Documents/logs/

# Monitor log output
tail -f Documents/logs/app.log

# Check log file sizes
du -h Documents/logs/*
```

## Integration

### With Monitoring Services
- **Sentry**: Error tracking and performance monitoring
- **LogRocket**: User session replay and logging
- **Firebase Analytics**: User behavior tracking
- **Custom Dashboard**: Real-time log monitoring

### With CI/CD
- Log analysis in build pipelines
- Automated error detection
- Performance regression testing
- Security vulnerability scanning

## Future Enhancements

### Planned Features
- Real-time log streaming
- Advanced log filtering
- Custom log formatters
- Integration with more monitoring services
- Machine learning-based log analysis

### Configuration Options
- Dynamic log level changes
- Runtime log configuration
- Custom log destinations
- Advanced filtering rules
