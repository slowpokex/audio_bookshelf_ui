import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app.dart';
import 'core/utils/app_logger.dart';
import 'core/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize database service first
  AppLogger.logAppLifecycle('Starting database service initialization');
  try {
    await DatabaseService.initialize();
    AppLogger.logDatabaseOperation('initialize', 'database_service', duration: 0);
    AppLogger.logAppLifecycle('Database service initialization completed successfully');
  } catch (e) {
    // Log the error but don't crash the app
    AppLogger.logDatabaseError('initialize', 'database_service', e.toString(), StackTrace.current);
    AppLogger.logAppLifecycle('Database initialization failed', data: {'error': e.toString()});
    // Try to force re-initialization
    try {
      AppLogger.logAppLifecycle('Attempting force re-initialization');
      await DatabaseService.forceReinitialize();
      AppLogger.logDatabaseOperation('force_reinitialize', 'database_service', duration: 0);
      AppLogger.logAppLifecycle('Database service re-initialization completed successfully');
    } catch (reinitError) {
      AppLogger.logDatabaseError('force_reinitialize', 'database_service', reinitError.toString(), StackTrace.current);
      AppLogger.logAppLifecycle('Database re-initialization also failed', data: {'error': reinitError.toString()});
    }
  }
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Log application startup
  AppLogger.logAppLifecycle('Audio Bookshelf UI starting...');

  runApp(const AudioBookshelfApp());
}