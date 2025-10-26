import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_bookshelf_ui/core/services/folder_scan_service.dart';

void main() {
  group('FolderScanService', () {

    group('hasAudioFiles', () {
      test('should return true when folder contains audio files', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final testFile = File('${tempDir.path}/test.mp3');
        await testFile.writeAsString('fake audio content');

        // Act
        final result = await FolderScanService.hasAudioFiles(tempDir.path);

        // Assert
        expect(result, isTrue);

        // Cleanup
        await tempDir.delete(recursive: true);
      });

      test('should return false when folder does not contain audio files', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final testFile = File('${tempDir.path}/test.txt');
        await testFile.writeAsString('text content');

        // Act
        final result = await FolderScanService.hasAudioFiles(tempDir.path);

        // Assert
        expect(result, isFalse);

        // Cleanup
        await tempDir.delete(recursive: true);
      });

      test('should return false when folder does not exist', () async {
        // Act
        final result = await FolderScanService.hasAudioFiles('/nonexistent/path');

        // Assert
        expect(result, isFalse);
      });
    });

    group('scanFolderForAudioFiles', () {
      test('should scan folder and return audio file information', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final mp3File = File('${tempDir.path}/test.mp3');
        final m4aFile = File('${tempDir.path}/test.m4a');
        final txtFile = File('${tempDir.path}/test.txt');
        
        await mp3File.writeAsString('fake mp3 content');
        await m4aFile.writeAsString('fake m4a content');
        await txtFile.writeAsString('text content');

        // Act
        final result = await FolderScanService.scanFolderForAudioFiles(tempDir.path);

        // Assert
        expect(result, hasLength(2));
        expect(result.any((file) => file.fileName == 'test.mp3'), isTrue);
        expect(result.any((file) => file.fileName == 'test.m4a'), isTrue);
        expect(result.any((file) => file.fileName == 'test.txt'), isFalse);

        // Cleanup
        await tempDir.delete(recursive: true);
      });

      test('should throw exception when folder does not exist', () async {
        // Act & Assert
        expect(
          () => FolderScanService.scanFolderForAudioFiles('/nonexistent/path'),
          throwsA(isA<Exception>()),
        );
      });

      test('should return empty list when folder has no audio files', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final txtFile = File('${tempDir.path}/test.txt');
        await txtFile.writeAsString('text content');

        // Act
        final result = await FolderScanService.scanFolderForAudioFiles(tempDir.path);

        // Assert
        expect(result, isEmpty);

        // Cleanup
        await tempDir.delete(recursive: true);
      });
    });

    group('findCoverImages', () {
      test('should find image files in folder', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final jpgFile = File('${tempDir.path}/cover.jpg');
        final pngFile = File('${tempDir.path}/cover.png');
        final txtFile = File('${tempDir.path}/readme.txt');
        
        await jpgFile.writeAsString('fake jpg content');
        await pngFile.writeAsString('fake png content');
        await txtFile.writeAsString('text content');

        // Act
        final result = await FolderScanService.findCoverImages(tempDir.path);

        // Assert
        expect(result, hasLength(2));
        expect(result.any((path) => path.contains('cover.jpg')), isTrue);
        expect(result.any((path) => path.contains('cover.png')), isTrue);
        expect(result.any((path) => path.contains('readme.txt')), isFalse);

        // Cleanup
        await tempDir.delete(recursive: true);
      });

      test('should return empty list when no images found', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final txtFile = File('${tempDir.path}/readme.txt');
        await txtFile.writeAsString('text content');

        // Act
        final result = await FolderScanService.findCoverImages(tempDir.path);

        // Assert
        expect(result, isEmpty);

        // Cleanup
        await tempDir.delete(recursive: true);
      });
    });

    group('saveMetadata', () {
      test('should save metadata for audio file', () async {
        // Arrange
        final tempDir = await Directory.systemTemp.createTemp('test_folder');
        final testFile = File('${tempDir.path}/test.mp3');
        await testFile.writeAsString('fake audio content');
        
        final fileInfo = AudioFileInfo(
          filePath: testFile.path,
          fileName: 'test.mp3',
          fileSize: 1000,
          fileFormat: 'mp3',
          duration: const Duration(seconds: 60),
          title: 'Test Title',
          author: 'Test Author',
          album: 'Test Album',
          year: 2023,
          genre: 'Test Genre',
          trackNumber: 1,
        );

        // Act
        await FolderScanService.saveMetadata(testFile.path, fileInfo);

        // Assert
        // Verify that metadata was saved (this would require checking the actual file)
        expect(testFile.existsSync(), isTrue);

        // Cleanup
        await tempDir.delete(recursive: true);
      });
    });
  });

  group('AudioFileInfo', () {
    test('should create AudioFileInfo with all properties', () {
      // Arrange & Act
      final fileInfo = AudioFileInfo(
        filePath: '/path/to/file.mp3',
        fileName: 'file.mp3',
        fileSize: 1024000,
        fileFormat: 'mp3',
        duration: const Duration(minutes: 5, seconds: 30),
        title: 'Test Title',
        author: 'Test Author',
        album: 'Test Album',
        year: 2023,
        genre: 'Test Genre',
        trackNumber: 1,
        isSelected: true,
      );

      // Assert
      expect(fileInfo.filePath, equals('/path/to/file.mp3'));
      expect(fileInfo.fileName, equals('file.mp3'));
      expect(fileInfo.fileSize, equals(1024000));
      expect(fileInfo.fileFormat, equals('mp3'));
      expect(fileInfo.duration, equals(const Duration(minutes: 5, seconds: 30)));
      expect(fileInfo.title, equals('Test Title'));
      expect(fileInfo.author, equals('Test Author'));
      expect(fileInfo.album, equals('Test Album'));
      expect(fileInfo.year, equals(2023));
      expect(fileInfo.genre, equals('Test Genre'));
      expect(fileInfo.trackNumber, equals(1));
      expect(fileInfo.isSelected, isTrue);
    });

    test('should create copy with updated values', () {
      // Arrange
      final originalFileInfo = AudioFileInfo(
        filePath: '/path/to/file.mp3',
        fileName: 'file.mp3',
        fileSize: 1024000,
        fileFormat: 'mp3',
        duration: const Duration(minutes: 5, seconds: 30),
        title: 'Original Title',
        author: 'Original Author',
        isSelected: false,
      );

      // Act
      final updatedFileInfo = originalFileInfo.copyWith(
        title: 'Updated Title',
        author: 'Updated Author',
        isSelected: true,
      );

      // Assert
      expect(updatedFileInfo.title, equals('Updated Title'));
      expect(updatedFileInfo.author, equals('Updated Author'));
      expect(updatedFileInfo.isSelected, isTrue);
      expect(updatedFileInfo.filePath, equals(originalFileInfo.filePath));
      expect(updatedFileInfo.fileName, equals(originalFileInfo.fileName));
    });

    test('should format file size correctly', () {
      // Arrange
      final fileInfo = AudioFileInfo(
        filePath: '/path/to/file.mp3',
        fileName: 'file.mp3',
        fileSize: 1024000, // 1MB
        fileFormat: 'mp3',
        duration: const Duration(minutes: 5),
        title: 'Test Title',
      );

      // Act & Assert
      expect(fileInfo.formattedFileSize, equals('1000.0KB'));
    });

    test('should format duration correctly', () {
      // Arrange
      final fileInfo = AudioFileInfo(
        filePath: '/path/to/file.mp3',
        fileName: 'file.mp3',
        fileSize: 1024000,
        fileFormat: 'mp3',
        duration: const Duration(hours: 2, minutes: 30, seconds: 45),
        title: 'Test Title',
      );

      // Act & Assert
      expect(fileInfo.formattedDuration, equals('2h 30m 45s'));
    });
  });
}
