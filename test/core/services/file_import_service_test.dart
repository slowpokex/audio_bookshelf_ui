import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_bookshelf_ui/core/services/file_import_service.dart';

void main() {
  group('FileImportService', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('file_import_test');
    });

    tearDown(() {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    group('validateAudioFile', () {
      test('should validate valid audio file', () async {
        // Arrange
        final audioFile = File('${tempDir.path}/test.mp3');
        // Create a file with proper MP3 header for testing (ID3 tag)
        final mp3Header = List<int>.from([0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        final content = mp3Header + List.filled(1024, 0x00); // 1KB+ content
        await audioFile.writeAsBytes(content);

        // Act
        final result = await FileImportService.validateAudioFile(audioFile.path);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.error, isNull);
        expect(result.fileSize, greaterThan(1000)); // Should be larger than 1KB
      });

      test('should reject non-audio file', () async {
        // Arrange
        final textFile = File('${tempDir.path}/test.txt');
        await textFile.writeAsString('text content' * 1000); // Make it much larger than 1KB

        // Act
        final result = await FileImportService.validateAudioFile(textFile.path);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('Unsupported audio format'));
      });

      test('should reject non-existent file', () async {
        // Act
        final result = await FileImportService.validateAudioFile('${tempDir.path}/nonexistent.mp3');

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('File does not exist'));
      });

      test('should reject empty file', () async {
        // Arrange
        final emptyFile = File('${tempDir.path}/empty.mp3');
        await emptyFile.writeAsString('');

        // Act
        final result = await FileImportService.validateAudioFile(emptyFile.path);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('File is too small'));
      });
    });

    group('validateImageFile', () {
      test('should validate valid image file', () async {
        // Arrange
        final imageFile = File('${tempDir.path}/test.jpg');
        // Create a file with proper JPEG header for testing
        final jpegHeader = List<int>.from([0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01]);
        final content = jpegHeader + List.filled(1024, 0x00); // 1KB+ content
        await imageFile.writeAsBytes(content);

        // Act
        final result = await FileImportService.validateImageFile(imageFile.path);

        // Assert
        expect(result.isValid, isTrue);
        expect(result.error, isNull);
        expect(result.fileSize, greaterThan(1000)); // Should be larger than 1KB
      });

      test('should reject non-image file', () async {
        // Arrange
        final textFile = File('${tempDir.path}/test.txt');
        await textFile.writeAsString('text content' * 1000);

        // Act
        final result = await FileImportService.validateImageFile(textFile.path);

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, isNotNull);
        expect(result.error, contains('Unsupported image format'));
      });
    });

    group('copyFileToAppDirectory', () {
      test('should copy file to app directory', () async {
        // Arrange
        final sourceFile = File('${tempDir.path}/source.mp3');
        final mp3Header = List<int>.from([0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        final content = mp3Header + List.filled(1000, 0x00);
        await sourceFile.writeAsBytes(content);
        final destinationDir = Directory('${tempDir.path}/destination');

        // Act
        final result = await FileImportService.copyFileToAppDirectory(
          sourceFile.path,
          destinationDir.path,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('source.mp3'));
        
        final copiedFile = File(result);
        expect(copiedFile.existsSync(), isTrue);
        final copiedContent = await copiedFile.readAsBytes();
        expect(copiedContent, equals(content));
      });

      test('should create destination directory if it does not exist', () async {
        // Arrange
        final sourceFile = File('${tempDir.path}/source.mp3');
        final mp3Header = List<int>.from([0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        final content = mp3Header + List.filled(1000, 0x00);
        await sourceFile.writeAsBytes(content);
        final destinationDir = Directory('${tempDir.path}/new/destination');

        // Act
        final result = await FileImportService.copyFileToAppDirectory(
          sourceFile.path,
          destinationDir.path,
        );

        // Assert
        expect(destinationDir.existsSync(), isTrue);
        expect(result, isNotNull);
      });

      test('should throw exception when source file does not exist', () async {
        // Arrange
        final destinationDir = Directory('${tempDir.path}/destination');

        // Act & Assert
        expect(
          () => FileImportService.copyFileToAppDirectory(
            '${tempDir.path}/nonexistent.mp3',
            destinationDir.path,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('copyFolderFilesToAppDirectory', () {
      test('should copy multiple files to app directory', () async {
        // Arrange
        final sourceDir = Directory('${tempDir.path}/source');
        sourceDir.createSync();
        
        final file1 = File('${sourceDir.path}/file1.mp3');
        final file2 = File('${sourceDir.path}/file2.mp3');
        await file1.writeAsString('content1' * 1000);
        await file2.writeAsString('content2' * 1000);
        
        final destinationDir = Directory('${tempDir.path}/destination');

        // Act
        final results = await FileImportService.copyFolderFilesToAppDirectory(
          sourceDir.path,
          destinationDir.path,
          [file1.path, file2.path],
        );

        // Assert
        expect(results, hasLength(2));
        expect(results.every((path) => path.contains('file')), isTrue);
        
        for (final result in results) {
          final copiedFile = File(result);
          expect(copiedFile.existsSync(), isTrue);
        }
      });

      test('should handle empty file list', () async {
        // Arrange
        final destinationDir = Directory('${tempDir.path}/destination');

        // Act
        final results = await FileImportService.copyFolderFilesToAppDirectory(
          tempDir.path,
          destinationDir.path,
          [],
        );

        // Assert
        expect(results, isEmpty);
      });
    });

    group('validateMultipleAudioFiles', () {
      test('should validate multiple valid audio files', () async {
        // Arrange
        final file1 = File('${tempDir.path}/file1.mp3');
        final file2 = File('${tempDir.path}/file2.m4a');
        final mp3Header = List<int>.from([0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        final m4aHeader = List<int>.from([0x00, 0x00, 0x00, 0x20, 0x66, 0x74, 0x79, 0x70, 0x4D, 0x34, 0x41, 0x20]);
        await file1.writeAsBytes(mp3Header + List.filled(1024, 0x00));
        await file2.writeAsBytes(m4aHeader + List.filled(1024, 0x00));

        // Act
        final results = await FileImportService.validateMultipleAudioFiles([
          file1.path,
          file2.path,
        ]);

        // Assert
        expect(results, hasLength(2));
        expect(results.every((result) => result.isValid), isTrue);
      });

      test('should identify invalid files in mixed list', () async {
        // Arrange
        final validFile = File('${tempDir.path}/valid.mp3');
        final invalidFile = File('${tempDir.path}/invalid.txt');
        final mp3Header = List<int>.from([0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        await validFile.writeAsBytes(mp3Header + List.filled(1024, 0x00));
        await invalidFile.writeAsString('content' * 1000);

        // Act
        final results = await FileImportService.validateMultipleAudioFiles([
          validFile.path,
          invalidFile.path,
        ]);

        // Assert
        expect(results, hasLength(2));
        expect(results[0].isValid, isTrue);
        expect(results[1].isValid, isFalse);
      });
    });

    group('getTotalFileSize', () {
      test('should calculate total file size', () async {
        // Arrange
        final file1 = File('${tempDir.path}/file1.mp3');
        final file2 = File('${tempDir.path}/file2.mp3');
        await file1.writeAsString('content1' * 1000); // Much larger than 1KB
        await file2.writeAsString('content2' * 1000); // Much larger than 1KB

        // Act
        final totalSize = await FileImportService.getTotalFileSize([
          file1.path,
          file2.path,
        ]);

        // Assert
        expect(totalSize, greaterThan(2000)); // Should be much larger than 1KB
      });

      test('should return 0 for empty list', () async {
        // Act
        final totalSize = await FileImportService.getTotalFileSize([]);

        // Assert
        expect(totalSize, equals(0));
      });
    });

    group('estimateTotalDuration', () {
      test('should estimate total duration for multiple files', () async {
        // Arrange
        final file1 = File('${tempDir.path}/file1.mp3');
        final file2 = File('${tempDir.path}/file2.mp3');
        final mp3Header = List<int>.from([0x49, 0x44, 0x33, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00]);
        await file1.writeAsBytes(mp3Header + List.filled(1024000, 0x00)); // 1MB
        await file2.writeAsBytes(mp3Header + List.filled(2048000, 0x00)); // 2MB

        // Act
        final totalDuration = FileImportService.estimateTotalDuration([file1.path, file2.path], ['mp3', 'mp3']);

        // Assert
        expect(totalDuration, isA<Duration>());
        expect(totalDuration.inSeconds, greaterThan(0));
      });

      test('should return zero duration for empty list', () {
        // Act
        final totalDuration = FileImportService.estimateTotalDuration([], ['mp3']);

        // Assert
        expect(totalDuration, equals(Duration.zero));
      });
    });

    group('estimateAudioDuration', () {
      test('should estimate duration for MP3 file', () {
        // Arrange
        const fileSize = 1024000; // 1MB
        const format = 'mp3';

        // Act
        final duration = FileImportService.estimateAudioDuration(fileSize, format);

        // Assert
        expect(duration, isA<Duration>());
        expect(duration.inSeconds, greaterThan(0));
      });

      test('should estimate duration for M4A file', () {
        // Arrange
        const fileSize = 2048000; // 2MB
        const format = 'm4a';

        // Act
        final duration = FileImportService.estimateAudioDuration(fileSize, format);

        // Assert
        expect(duration, isA<Duration>());
        expect(duration.inSeconds, greaterThan(0));
      });

      test('should return estimated duration for unsupported format', () {
        // Arrange
        const fileSize = 1024000; // 1MB
        const format = 'unknown';

        // Act
        final duration = FileImportService.estimateAudioDuration(fileSize, format);

        // Assert
        // Should use default bitrate of 128 kbps
        expect(duration, greaterThan(Duration.zero));
        expect(duration.inSeconds, greaterThan(0));
      });
    });

    group('getAudiobooksDirectory', () {
      test('should return audiobooks directory path', () async {
        // Act
        final directory = await FileImportService.getAudiobooksDirectory();

        // Assert
        expect(directory, isNotNull);
        expect(directory, isA<String>());
        expect(directory, contains('audiobooks'));
      });
    });

    group('getCoversDirectory', () {
      test('should return covers directory path', () async {
        // Act
        final directory = await FileImportService.getCoversDirectory();

        // Assert
        expect(directory, isNotNull);
        expect(directory, isA<String>());
        expect(directory, contains('covers'));
      });
    });

    group('hasStoragePermissions', () {
      test('should check storage permissions', () async {
        // Act
        final hasPermissions = await FileImportService.hasStoragePermissions();

        // Assert
        expect(hasPermissions, isA<bool>());
      });
    });

    group('requestPermissions', () {
      test('should request storage permissions', () async {
        // Act
        final granted = await FileImportService.requestPermissions();

        // Assert
        expect(granted, isA<bool>());
      });
    });

    group('getPermissionErrorMessage', () {
      test('should return permission error message', () {
        // Act
        final message = FileImportService.getPermissionErrorMessage();

        // Assert
        expect(message, isNotNull);
        expect(message, isA<String>());
        expect(message, isNotEmpty);
      });
    });
  });

  group('AudioFileValidationResult', () {
    test('should create valid result', () {
      // Arrange & Act
      final result = AudioFileValidationResult(
        isValid: true,
        fileSize: 1024,
      );

      // Assert
      expect(result.isValid, isTrue);
      expect(result.fileSize, equals(1024));
      expect(result.error, isNull);
    });

    test('should create invalid result with error', () {
      // Arrange & Act
      final result = AudioFileValidationResult(
        isValid: false,
        error: 'Test error message',
      );

      // Assert
      expect(result.isValid, isFalse);
      expect(result.error, equals('Test error message'));
      expect(result.fileSize, isNull);
    });
  });
}
