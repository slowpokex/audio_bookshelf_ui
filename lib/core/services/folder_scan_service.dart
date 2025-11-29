import 'dart:io';
import 'package:path/path.dart' as path;
import 'metadata_storage_service.dart';

/// Service for scanning folders and detecting audio files
class FolderScanService {
  static const List<String> _supportedAudioFormats = [
    'mp3', 'm4a', 'm4b', 'aac', 'flac', 'ogg', 'wav'
  ];

  static const List<String> _supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'webp'
  ];

  /// Maximum number of parallel file processing tasks
  static const int _maxParallelTasks = 10;

  /// Scans a folder for audio files and returns information about each file.
  /// Uses parallel processing for improved performance on large directories.
  static Future<List<AudioFileInfo>> scanFolderForAudioFiles(String folderPath) async {
    final directory = Directory(folderPath);

    if (!await directory.exists()) {
      throw Exception('Folder does not exist: $folderPath');
    }

    // Collect all audio files first (fast operation)
    final audioFilePaths = <File>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final extension = path.extension(entity.path).toLowerCase();
        if (extension.isNotEmpty && _supportedAudioFormats.contains(extension.substring(1))) {
          audioFilePaths.add(entity);
        }
      }
    }

    if (audioFilePaths.isEmpty) {
      return [];
    }

    // Process files in parallel batches for better performance
    final List<AudioFileInfo> audioFiles = [];
    
    // Process in batches to avoid overwhelming the system
    for (int i = 0; i < audioFilePaths.length; i += _maxParallelTasks) {
      final end = (i + _maxParallelTasks > audioFilePaths.length) 
          ? audioFilePaths.length 
          : i + _maxParallelTasks;
      final batch = audioFilePaths.sublist(i, end);
      
      // Process batch in parallel
      final futures = batch.map((file) => _createAudioFileInfo(file));
      final results = await Future.wait(futures);
      
      // Filter out nulls and add to result
      audioFiles.addAll(results.whereType<AudioFileInfo>());
    }

    return audioFiles;
  }

  /// Creates AudioFileInfo from a file
  static Future<AudioFileInfo?> _createAudioFileInfo(File file) async {
    try {
      final stat = await file.stat();
      final fileName = path.basename(file.path);
      final extension = path.extension(file.path).substring(1).toLowerCase();
      
      // Check for stored metadata first
      final storedMetadata = await MetadataStorageService.getMetadata(file.path);
      
      if (storedMetadata != null) {
        // Use stored metadata
        return AudioFileInfo(
          filePath: file.path,
          fileName: fileName,
          fileSize: stat.size,
          fileFormat: extension,
          duration: _estimateDuration(stat.size, extension),
          title: storedMetadata.title,
          author: storedMetadata.author,
          album: storedMetadata.album,
          year: storedMetadata.year,
          genre: storedMetadata.genre,
          trackNumber: storedMetadata.trackNumber,
          isSelected: true, // Default to selected
        );
      } else {
        // Extract basic metadata from filename
        final metadata = _extractMetadataFromFilename(fileName);
        
        return AudioFileInfo(
          filePath: file.path,
          fileName: fileName,
          fileSize: stat.size,
          fileFormat: extension,
          duration: _estimateDuration(stat.size, extension),
          title: metadata['title'] ?? _cleanFilename(fileName),
          author: metadata['author'],
          album: metadata['album'],
          year: metadata['year'],
          genre: metadata['genre'],
          trackNumber: metadata['trackNumber'],
          isSelected: true, // Default to selected
        );
      }
    } catch (e) {
      print('Error creating audio file info for ${file.path}: $e');
      return null;
    }
  }

  /// Extracts metadata from filename using common patterns
  static Map<String, dynamic> _extractMetadataFromFilename(String fileName) {
    final Map<String, dynamic> metadata = {};
    
    // Remove file extension
    final nameWithoutExt = path.basenameWithoutExtension(fileName);
    
    // Common patterns:
    // "Author - Title"
    // "Author - Album - Title"
    // "TrackNumber - Title"
    // "Author - Title (Year)"
    // "Author - Album - TrackNumber - Title"
    
    final parts = nameWithoutExt.split(' - ');
    if (parts.length >= 2) {
      metadata['author'] = parts[0].trim();
      
      if (parts.length == 2) {
        // "Author - Title" or "Author - Title (Year)"
        final titlePart = parts[1].trim();
        final yearMatch = RegExp(r'\((\d{4})\)').firstMatch(titlePart);
        if (yearMatch != null) {
          metadata['title'] = titlePart.replaceAll(RegExp(r'\s*\(\d{4}\)'), '').trim();
          metadata['year'] = int.tryParse(yearMatch.group(1)!);
        } else {
          metadata['title'] = titlePart;
        }
      } else if (parts.length == 3) {
        // "Author - Album - Title" or "Author - Title - TrackNumber"
        if (RegExp(r'^\d+$').hasMatch(parts[2])) {
          // Track number
          metadata['title'] = parts[1].trim();
          metadata['trackNumber'] = int.tryParse(parts[2]);
        } else {
          // Album
          metadata['album'] = parts[1].trim();
          metadata['title'] = parts[2].trim();
        }
      } else if (parts.length == 4) {
        // "Author - Album - TrackNumber - Title"
        metadata['album'] = parts[1].trim();
        metadata['trackNumber'] = int.tryParse(parts[2]);
        metadata['title'] = parts[3].trim();
      }
    } else {
      // Single part - use as title
      metadata['title'] = nameWithoutExt;
    }
    
    return metadata;
  }

  /// Cleans filename for use as title
  static String _cleanFilename(String fileName) {
    return path.basenameWithoutExtension(fileName)
        .replaceAll('_', ' ')
        .replaceAll('-', ' ')
        .trim();
  }

  /// Estimates duration based on file size and format
  static Duration _estimateDuration(int fileSize, String format) {
    final bytesPerSecond = _getEstimatedBitrate(format) * 1000 / 8;
    final seconds = fileSize / bytesPerSecond;
    return Duration(seconds: seconds.round());
  }

  /// Gets estimated bitrate for audio format
  static int _getEstimatedBitrate(String format) {
    switch (format.toLowerCase()) {
      case 'mp3':
        return 128; // 128 kbps
      case 'm4a':
      case 'm4b':
        return 64; // 64 kbps
      case 'aac':
        return 128; // 128 kbps
      case 'flac':
        return 1000; // 1000 kbps
      case 'ogg':
        return 128; // 128 kbps
      case 'wav':
        return 1400; // 1400 kbps
      default:
        return 128;
    }
  }

  /// Looks for cover images in the same folder as audio files
  static Future<List<String>> findCoverImages(String folderPath) async {
    final List<String> coverImages = [];
    final directory = Directory(folderPath);

    if (!await directory.exists()) {
      return coverImages;
    }

    await for (final entity in directory.list(recursive: false)) {
      if (entity is File) {
        final extension = path.extension(entity.path).substring(1).toLowerCase();
        if (_supportedImageFormats.contains(extension)) {
          coverImages.add(entity.path);
        }
      }
    }

    return coverImages;
  }

  /// Validates if a folder contains audio files
  static Future<bool> hasAudioFiles(String folderPath) async {
    final directory = Directory(folderPath);
    
    if (!await directory.exists()) {
      return false;
    }

    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) {
        final extension = path.extension(entity.path).substring(1).toLowerCase();
        if (_supportedAudioFormats.contains(extension)) {
          return true;
        }
      }
    }

    return false;
  }

  /// Saves metadata for an audio file
  static Future<void> saveMetadata(String filePath, AudioFileInfo fileInfo) async {
    final metadata = AudioFileMetadata(
      title: fileInfo.title,
      author: fileInfo.author,
      album: fileInfo.album,
      year: fileInfo.year,
      genre: fileInfo.genre,
      trackNumber: fileInfo.trackNumber,
      lastModified: DateTime.now(),
    );
    
    await MetadataStorageService.storeMetadata(filePath, metadata);
  }

  /// Gets all stored metadata for a folder
  static Future<Map<String, AudioFileMetadata>> getStoredMetadata(String folderPath) async {
    return await MetadataStorageService.getAllMetadata(folderPath);
  }
}

/// Information about an audio file found in a folder
class AudioFileInfo {
  final String filePath;
  final String fileName;
  final int fileSize;
  final String fileFormat;
  final Duration duration;
  final String title;
  final String? author;
  final String? album;
  final int? year;
  final String? genre;
  final int? trackNumber;
  bool isSelected;

  AudioFileInfo({
    required this.filePath,
    required this.fileName,
    required this.fileSize,
    required this.fileFormat,
    required this.duration,
    required this.title,
    this.author,
    this.album,
    this.year,
    this.genre,
    this.trackNumber,
    this.isSelected = true,
  });

  /// Creates a copy with updated values
  AudioFileInfo copyWith({
    String? title,
    String? author,
    String? album,
    int? year,
    String? genre,
    int? trackNumber,
    bool? isSelected,
  }) {
    return AudioFileInfo(
      filePath: filePath,
      fileName: fileName,
      fileSize: fileSize,
      fileFormat: fileFormat,
      duration: duration,
      title: title ?? this.title,
      author: author ?? this.author,
      album: album ?? this.album,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  /// Formats file size for display
  String get formattedFileSize {
    if (fileSize <= 0) return '0B';
    
    const int bytesPerKilobyte = 1024;
    const int bytesPerMegabyte = bytesPerKilobyte * 1024;
    const int bytesPerGigabyte = bytesPerMegabyte * 1024;
    const int decimalPlaces = 1;
    
    if (fileSize < bytesPerKilobyte) {
      return '${fileSize}B';
    } else if (fileSize < bytesPerMegabyte) {
      return '${(fileSize / bytesPerKilobyte).toStringAsFixed(decimalPlaces)}KB';
    } else if (fileSize < bytesPerGigabyte) {
      return '${(fileSize / bytesPerMegabyte).toStringAsFixed(decimalPlaces)}MB';
    } else {
      return '${(fileSize / bytesPerGigabyte).toStringAsFixed(decimalPlaces)}GB';
    }
  }

  /// Formats duration for display
  String get formattedDuration {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}
