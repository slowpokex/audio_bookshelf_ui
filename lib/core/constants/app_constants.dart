/// Application constants and configuration values
class AppConstants {
  // App Information
  static const String appName = 'Audio Bookshelf UI';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Local-first audiobook management platform';
  
  // Supported Audio Formats
  static const List<String> supportedAudioFormats = [
    'mp3',
    'aac',
    'flac',
    'm4b',
    'ogg',
    'wav',
  ];
  
  // Supported Image Formats
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];
  
  // Performance Constants
  static const int maxConcurrentOperations = 10;
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration progressSaveInterval = Duration(seconds: 30);
  
  // Local Storage
  static const String localDatabaseName = 'audiobookshelf.db';
  static const int localDatabaseVersion = 1;
  static const String localStoragePath = 'audiobookshelf_data';
  
  // Accessibility
  static const double minTouchTargetSize = 44.0;
  static const double maxFontScale = 2.0;
  static const double minContrastRatio = 4.5;
  
  // AI Agent Configuration
  static const Duration agentTimeout = Duration(minutes: 5);
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 1);
  
  // Security
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(hours: 1);
  static const Duration sessionTimeout = Duration(days: 30);
  
  // File Management
  static const int maxFileSize = 2 * 1024 * 1024 * 1024; // 2GB
  static const int maxLibrarySize = 10000; // 10,000 books
  static const Duration fileValidationTimeout = Duration(seconds: 10);
  
  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetryCount = 3;
  static const double retryBackoffMultiplier = 2.0;
  static const String apiBaseUrl = 'https://api.audiobookshelf.org';
  static const String apiKey = 'your-api-key-here';
  
  // UI Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const double borderRadius = 8.0;
  static const double elevation = 4.0;
  
  // Localization
  static const List<String> supportedLocales = ['en', 'ru'];
  static const String defaultLocale = 'en';
  
  // Community Features
  static const String githubRepository = 'https://github.com/audiobookshelf/ui';
  static const String communityForum = 'https://forum.audiobookshelf.org';
  static const String documentationUrl = 'https://docs.audiobookshelf.org';
  
  // Privacy
  static const Duration dataRetentionPeriod = Duration(days: 1095); // 3 years
  static const bool analyticsEnabled = true;
  static const bool crashReportingEnabled = true;
  
  // Performance Monitoring
  static const Duration metricsCollectionInterval = Duration(minutes: 1);
  static const int maxMetricsHistory = 1000;
  static const Duration performanceThreshold = Duration(milliseconds: 100);
}
