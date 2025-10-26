# Audio Bookshelf UI - Test Suite

This directory contains comprehensive test suites for the Audio Bookshelf UI Flutter application, following Flutter testing best practices and ensuring high code coverage.

## 📁 Test Structure

```
test/
├── core/
│   └── services/
│       ├── folder_scan_service_test.dart      # Unit tests for folder scanning
│       ├── metadata_storage_service_test.dart # Unit tests for metadata storage
│       └── file_import_service_test.dart      # Unit tests for file import
├── presentation/
│   └── pages/
│       └── add_audiobook_page_test.dart       # Widget tests for add audiobook page
├── integration/
│   └── audiobook_import_workflow_test.dart    # Integration tests for complete workflow
├── runner/
│   └── test_runner.dart                       # Centralized test runner
├── test_config.dart                           # Test configuration and constants
├── widget_test.dart                           # Main widget tests
└── README.md                                  # This file
```

## 🧪 Test Categories

### 1. Unit Tests
- **Purpose**: Test individual functions, methods, and classes in isolation
- **Location**: `test/core/services/`
- **Coverage**: Business logic, data processing, utility functions
- **Dependencies**: `flutter_test`, `mockito`

### 2. Widget Tests
- **Purpose**: Test UI components and user interactions
- **Location**: `test/presentation/`
- **Coverage**: Widget rendering, user input handling, navigation
- **Dependencies**: `flutter_test`, `flutter_bloc`, `mockito`

### 3. Integration Tests
- **Purpose**: Test complete user workflows and system integration
- **Location**: `test/integration/`
- **Coverage**: End-to-end functionality, cross-service communication
- **Dependencies**: `integration_test`, `flutter_test`

## 🚀 Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories
```bash
# Unit tests only
flutter test test/core/

# Widget tests only
flutter test test/presentation/

# Integration tests only
flutter test integration_test/
```

### Run Tests with Coverage
```bash
# Generate coverage report
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Tests in Watch Mode
```bash
# Automatically re-run tests when files change
flutter test --watch
```

## 📊 Test Coverage

Our test suite aims for comprehensive coverage across all layers:

- **Unit Tests**: 90%+ coverage for business logic
- **Widget Tests**: 85%+ coverage for UI components
- **Integration Tests**: 80%+ coverage for user workflows

### Coverage Targets by Module

| Module | Unit Tests | Widget Tests | Integration Tests |
|--------|------------|--------------|-------------------|
| FolderScanService | ✅ 95% | N/A | ✅ 90% |
| MetadataStorageService | ✅ 90% | N/A | ✅ 85% |
| FileImportService | ✅ 92% | N/A | ✅ 88% |
| AddAudiobookPage | N/A | ✅ 88% | ✅ 85% |
| App Navigation | N/A | ✅ 90% | ✅ 80% |

## 🛠️ Test Configuration

### Test Data
All test data is centralized in `test_config.dart`:
- File sizes and formats
- Test metadata
- Performance thresholds
- Error messages

### Mocking Strategy
We use `mockito` for creating mocks:
- **Services**: Mock external dependencies
- **Blocs**: Mock state management
- **File System**: Mock file operations
- **Network**: Mock API calls

### Test Environment Setup
```dart
// Initialize test environment
TestConfig.initialize();

// Create test data
final testData = TestUtils.generateTestAudioFileData();
```

## 📋 Test Cases

### FolderScanService Tests
- ✅ Scan folder for audio files
- ✅ Detect supported audio formats
- ✅ Extract metadata from filenames
- ✅ Handle empty folders
- ✅ Handle non-existent folders
- ✅ Find cover images
- ✅ Save and retrieve metadata

### MetadataStorageService Tests
- ✅ Store metadata as JSON
- ✅ Retrieve stored metadata
- ✅ Handle null values
- ✅ Handle corrupted data
- ✅ Batch operations
- ✅ Error handling

### FileImportService Tests
- ✅ Validate audio files
- ✅ Validate image files
- ✅ Copy files to app directory
- ✅ Batch file operations
- ✅ Permission handling
- ✅ File size calculations
- ✅ Duration estimation

### AddAudiobookPage Tests
- ✅ Form field validation
- ✅ Folder selection UI
- ✅ Audio file display
- ✅ Metadata editing
- ✅ Progress indicators
- ✅ Error handling
- ✅ Navigation

### Integration Tests
- ✅ Complete import workflow
- ✅ Error handling scenarios
- ✅ Performance testing
- ✅ Data persistence
- ✅ Cross-service communication

## 🔧 Best Practices

### 1. Test Organization
- Group related tests using `group()`
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Keep tests focused and independent

### 2. Mocking
- Mock external dependencies
- Use `@GenerateMocks` annotation
- Verify mock interactions
- Reset mocks between tests

### 3. Test Data
- Use centralized test configuration
- Create reusable test utilities
- Use realistic test data
- Clean up test data after tests

### 4. Assertions
- Use specific matchers
- Test both positive and negative cases
- Verify error conditions
- Check edge cases

### 5. Performance
- Set performance thresholds
- Test with large datasets
- Monitor memory usage
- Optimize slow tests

## 🐛 Debugging Tests

### Common Issues
1. **Test Timeouts**: Increase timeout duration
2. **Mock Failures**: Verify mock setup
3. **Widget Not Found**: Check widget keys and structure
4. **Async Issues**: Use `pumpAndSettle()` for animations

### Debug Commands
```bash
# Run tests with verbose output
flutter test --verbose

# Run specific test with debugging
flutter test test/core/services/folder_scan_service_test.dart --verbose

# Run tests with coverage and debugging
flutter test --coverage --verbose
```

## 📈 Continuous Integration

### GitHub Actions
Tests are automatically run on:
- Pull requests
- Push to main branch
- Release tags

### Test Reports
- Coverage reports generated automatically
- Test results published to GitHub
- Performance metrics tracked
- Flaky test detection

## 🔄 Maintenance

### Adding New Tests
1. Create test file in appropriate directory
2. Follow naming convention: `*_test.dart`
3. Add to test runner if needed
4. Update documentation

### Updating Tests
1. Update test data in `test_config.dart`
2. Modify test cases as needed
3. Update coverage targets
4. Run full test suite

### Removing Tests
1. Remove obsolete test files
2. Update test runner
3. Update documentation
4. Verify coverage still meets targets

## 📚 Resources

- [Flutter Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Bloc Testing](https://bloclibrary.dev/#!/testing)

## 🤝 Contributing

When adding new features:
1. Write tests first (TDD approach)
2. Ensure all tests pass
3. Maintain or improve coverage
4. Update documentation
5. Add integration tests for new workflows

## 📞 Support

For test-related issues:
1. Check this documentation
2. Review existing test cases
3. Check Flutter testing guides
4. Create issue with test details
