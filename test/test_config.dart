import 'package:flutter_test/flutter_test.dart';

/// Test configuration for Audio Bookshelf UI
class TestConfig {
  /// Initialize test environment
  static void initialize() {
    // Set up test environment
    TestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Test data constants
  static const String testAudioFolder = 'test_audio_files';
  static const String testMetadataFolder = 'test_metadata';
  static const String testCoverImage = 'test_cover.jpg';
  
  /// Supported audio formats for testing
  static const List<String> supportedAudioFormats = [
    'mp3', 'm4a', 'm4b', 'aac', 'flac', 'ogg', 'wav'
  ];
  
  /// Supported image formats for testing
  static const List<String> supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'webp'
  ];
  
  /// Test file sizes (in bytes)
  static const int smallFileSize = 1024; // 1KB
  static const int mediumFileSize = 1024 * 1024; // 1MB
  static const int largeFileSize = 10 * 1024 * 1024; // 10MB
  
  /// Test durations
  static const Duration shortDuration = Duration(minutes: 5);
  static const Duration mediumDuration = Duration(minutes: 30);
  static const Duration longDuration = Duration(hours: 2);
  
  /// Test metadata
  static const String testTitle = 'Test Audiobook';
  static const String testAuthor = 'Test Author';
  static const String testNarrator = 'Test Narrator';
  static const String testDescription = 'Test Description';
  static const String testGenre = 'Fiction';
  static const int testYear = 2023;
  static const String testIsbn = '978-0-123456-78-9';
  static const String testPublisher = 'Test Publisher';
  static const String testLanguage = 'English';
  static const String testSeries = 'Test Series';
  static const int testSeriesOrder = 1;
  static const List<String> testTags = ['fiction', 'mystery', 'thriller'];
  
  /// Performance test thresholds
  static const int maxScanTimeMs = 5000; // 5 seconds
  static const int maxValidationTimeMs = 3000; // 3 seconds
  static const int maxImportTimeMs = 10000; // 10 seconds
  
  /// Error messages
  static const String fileNotFoundError = 'File does not exist';
  static const String unsupportedFormatError = 'Unsupported format';
  static const String emptyFileError = 'File is empty';
  static const String permissionError = 'Permission denied';
  static const String validationError = 'Validation failed';
}
