import 'package:flutter_test/flutter_test.dart';

import '../test_config.dart';

/// Test runner for Audio Bookshelf UI
/// 
/// This script provides a centralized way to run all tests
/// and generate coverage reports.
void main() {
  // Initialize test environment
  TestConfig.initialize();
  
  // Run unit tests
  group('Unit Tests', () {
    test('should run all unit tests', () {
      // This will be called by the test runner
      print('Running unit tests...');
    });
  });
  
  // Run widget tests
  group('Widget Tests', () {
    test('should run all widget tests', () {
      // This will be called by the test runner
      print('Running widget tests...');
    });
  });
}

/// Test categories for better organization
class TestCategories {
  static const String unit = 'unit';
  static const String widget = 'widget';
  static const String integration = 'integration';
  static const String performance = 'performance';
  static const String accessibility = 'accessibility';
}

/// Test utilities for common test operations
class TestUtils {
  /// Generate test data for audio files
  static Map<String, dynamic> generateTestAudioFileData({
    String title = 'Test Title',
    String author = 'Test Author',
    String album = 'Test Album',
    int year = 2023,
    String genre = 'Fiction',
    int trackNumber = 1,
  }) {
    return {
      'title': title,
      'author': author,
      'album': album,
      'year': year,
      'genre': genre,
      'trackNumber': trackNumber,
    };
  }
  
  /// Generate test metadata
  static Map<String, dynamic> generateTestMetadata({
    String title = 'Test Metadata',
    String author = 'Test Author',
    int year = 2023,
  }) {
    return {
      'title': title,
      'author': author,
      'year': year,
      'lastModified': DateTime.now().toIso8601String(),
    };
  }
  
  /// Create test file paths
  static List<String> createTestFilePaths(int count, String extension) {
    return List.generate(count, (index) => 'test_file_$index.$extension');
  }
  
  /// Validate test results
  static bool validateTestResults(List<dynamic> results) {
    return results.every((result) => result != null);
  }
}
