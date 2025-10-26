import 'package:sqflite/sqflite.dart';
import '../utils/app_logger.dart';

/// Service to handle database initialization across platforms
class DatabaseService {
  static bool _isInitialized = false;
  static Database? _database;

  /// Initialize the database factory for the current platform
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('DatabaseService: Already initialized');
      return;
    }

    try {
      AppLogger.logDatabaseOperation('initialize', 'database_service');
      
      // Mobile platforms (Android/iOS) don't require additional initialization
      AppLogger.logDebug('Mobile platform detected - using default database factory');
      
      _isInitialized = true;
      AppLogger.logDatabaseOperation('initialize', 'database_service', duration: 0);
    } catch (e) {
      AppLogger.logDatabaseError('initialize', 'database_service', e.toString(), StackTrace.current);
      throw DatabaseInitializationException('Failed to initialize database factory: $e');
    }
  }

  /// Ensure database factory is initialized before any database operations
  static Future<void> ensureInitialized() async {
    AppLogger.logDebug('ensureInitialized called');
    
    if (!_isInitialized) {
      AppLogger.logDebug('Not initialized, calling initialize()');
      await initialize();
    } else {
      AppLogger.logDebug('Already initialized');
    }
    
    AppLogger.logDebug('ensureInitialized completed');
  }

  /// Force re-initialization of the database factory
  static Future<void> forceReinitialize() async {
    _isInitialized = false;
    await ensureInitialized();
  }

  /// Check if the database service is initialized
  static bool get isInitialized => _isInitialized;

  /// Get the database instance (for testing purposes)
  static Database? get database => _database;

  /// Set the database instance (for testing purposes)
  static void setDatabase(Database? db) {
    _database = db;
  }
}

/// Exception thrown when database initialization fails
class DatabaseInitializationException implements Exception {
  final String message;
  const DatabaseInitializationException(this.message);

  @override
  String toString() => 'DatabaseInitializationException: $message';
}
