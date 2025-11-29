import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Service for storing and retrieving local metadata for audio files.
/// Uses an in-memory cache to reduce file I/O operations.
///
/// **Thread Safety Note:** This service uses static mutable state for caching.
/// It is designed for single-threaded use within Flutter's main isolate.
/// If used in multiple isolates, each isolate will have its own cache instance,
/// which is the expected behavior for Dart isolates.
class MetadataStorageService {
  static const String _metadataFileName = 'metadata.json';
  
  // In-memory cache for metadata to avoid repeated file I/O.
  // Note: Safe for single-threaded use in Flutter's main isolate.
  // Each Dart isolate has its own memory, so no cross-isolate races occur.
  // Key is the directory path, value is the parsed metadata map.
  static final Map<String, Map<String, dynamic>> _metadataCache = {};
  
  // Track cache modification times to detect stale cache.
  // Same thread-safety considerations as _metadataCache.
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  /// Maximum cache age before refresh (5 minutes)
  static const Duration _maxCacheAge = Duration(minutes: 5);
  
  /// Clears the metadata cache for a specific directory or all directories.
  static void clearCache([String? directoryPath]) {
    if (directoryPath != null) {
      _metadataCache.remove(directoryPath);
      _cacheTimestamps.remove(directoryPath);
    } else {
      _metadataCache.clear();
      _cacheTimestamps.clear();
    }
  }
  
  /// Gets cached metadata for a directory, loading from disk if needed.
  static Future<Map<String, dynamic>> _getCachedMetadata(String directoryPath) async {
    final now = DateTime.now();
    final cacheTimestamp = _cacheTimestamps[directoryPath];
    
    // Check if cache is fresh
    if (cacheTimestamp != null && 
        now.difference(cacheTimestamp) < _maxCacheAge &&
        _metadataCache.containsKey(directoryPath)) {
      return _metadataCache[directoryPath]!;
    }
    
    // Load from disk
    final metadataFile = File(path.join(directoryPath, _metadataFileName));
    
    if (!await metadataFile.exists()) {
      _metadataCache[directoryPath] = {};
      _cacheTimestamps[directoryPath] = now;
      return {};
    }
    
    try {
      final content = await metadataFile.readAsString();
      final metadata = Map<String, dynamic>.from(jsonDecode(content) as Map);
      _metadataCache[directoryPath] = metadata;
      _cacheTimestamps[directoryPath] = now;
      return metadata;
    } catch (e) {
      _metadataCache[directoryPath] = {};
      _cacheTimestamps[directoryPath] = now;
      return {};
    }
  }
  
  /// Writes cached metadata to disk for a directory.
  static Future<void> _writeCacheToDisk(String directoryPath) async {
    final metadata = _metadataCache[directoryPath];
    if (metadata == null) return;
    
    final metadataFile = File(path.join(directoryPath, _metadataFileName));
    
    if (metadata.isEmpty) {
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
    } else {
      await metadataFile.writeAsString(jsonEncode(metadata));
    }
  }
  
  /// Stores metadata for an audio file.
  /// Uses cache to minimize disk writes.
  static Future<void> storeMetadata(String audioFilePath, AudioFileMetadata metadata) async {
    try {
      final metadataDir = path.dirname(audioFilePath);
      final relativePath = path.basename(audioFilePath);
      
      // Update cache
      final allMetadata = await _getCachedMetadata(metadataDir);
      allMetadata[relativePath] = metadata.toJson();
      _metadataCache[metadataDir] = allMetadata;
      _cacheTimestamps[metadataDir] = DateTime.now();
      
      // Write to disk
      await _writeCacheToDisk(metadataDir);
    } catch (e) {
      throw Exception('Failed to store metadata: $e');
    }
  }
  
  /// Retrieves metadata for an audio file.
  /// Uses cache to minimize disk reads.
  ///
  /// Returns `null` if metadata doesn't exist or cannot be read.
  /// Errors are logged but don't interrupt the calling code, as missing
  /// metadata should not prevent audio file processing.
  static Future<AudioFileMetadata?> getMetadata(String audioFilePath) async {
    try {
      final metadataDir = path.dirname(audioFilePath);
      final relativePath = path.basename(audioFilePath);
      
      final allMetadata = await _getCachedMetadata(metadataDir);
      
      if (allMetadata.containsKey(relativePath)) {
        return AudioFileMetadata.fromJson(allMetadata[relativePath]);
      }
      
      return null;
    } catch (e) {
      // Log error but return null to avoid blocking file processing.
      // Expected errors: file not found, permission denied, invalid JSON.
      // These are non-fatal and the caller should handle null metadata gracefully.
      print('MetadataStorageService.getMetadata: Failed to retrieve metadata for $audioFilePath: $e');
      return null;
    }
  }
  
  /// Removes metadata for an audio file.
  /// Uses cache to minimize disk operations.
  static Future<void> removeMetadata(String audioFilePath) async {
    try {
      final metadataDir = path.dirname(audioFilePath);
      final relativePath = path.basename(audioFilePath);
      
      final allMetadata = await _getCachedMetadata(metadataDir);
      allMetadata.remove(relativePath);
      _metadataCache[metadataDir] = allMetadata;
      _cacheTimestamps[metadataDir] = DateTime.now();
      
      // Write to disk
      await _writeCacheToDisk(metadataDir);
    } catch (e) {
      throw Exception('Failed to remove metadata: $e');
    }
  }
  
  /// Gets all metadata for files in a directory.
  /// Uses cache to minimize disk reads.
  static Future<Map<String, AudioFileMetadata>> getAllMetadata(String directoryPath) async {
    try {
      final allMetadata = await _getCachedMetadata(directoryPath);
      
      final Map<String, AudioFileMetadata> result = {};
      for (final entry in allMetadata.entries) {
        result[entry.key] = AudioFileMetadata.fromJson(entry.value);
      }
      
      return result;
    } catch (e) {
      print('Failed to get all metadata: $e');
      return {};
    }
  }
  
  /// Updates metadata for an audio file
  static Future<void> updateMetadata(String audioFilePath, AudioFileMetadata metadata) async {
    await storeMetadata(audioFilePath, metadata);
  }
  
  /// Checks if metadata exists for an audio file
  static Future<bool> hasMetadata(String audioFilePath) async {
    final metadata = await getMetadata(audioFilePath);
    return metadata != null;
  }
  
  /// Gets metadata file path for a directory
  static String getMetadataFilePath(String directoryPath) {
    return path.join(directoryPath, _metadataFileName);
  }
  
  /// Validates metadata file integrity
  static Future<bool> validateMetadataFile(String directoryPath) async {
    try {
      final metadataFile = File(getMetadataFilePath(directoryPath));
      
      if (!await metadataFile.exists()) {
        return true; // No metadata file is valid
      }
      
      final content = await metadataFile.readAsString();
      jsonDecode(content); // Try to parse JSON
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Repairs corrupted metadata file by removing it
  static Future<void> repairMetadataFile(String directoryPath) async {
    try {
      final metadataFile = File(getMetadataFilePath(directoryPath));
      if (await metadataFile.exists()) {
        await metadataFile.delete();
      }
    } catch (e) {
      throw Exception('Failed to repair metadata file: $e');
    }
  }
}

/// Metadata for an audio file
class AudioFileMetadata {
  final String title;
  final String? author;
  final String? album;
  final int? year;
  final String? genre;
  final int? trackNumber;
  final String? description;
  final String? narrator;
  final String? publisher;
  final String? language;
  final List<String> tags;
  final DateTime lastModified;

  const AudioFileMetadata({
    required this.title,
    this.author,
    this.album,
    this.year,
    this.genre,
    this.trackNumber,
    this.description,
    this.narrator,
    this.publisher,
    this.language,
    this.tags = const [],
    required this.lastModified,
  });

  /// Creates a copy with updated values
  AudioFileMetadata copyWith({
    String? title,
    String? author,
    String? album,
    int? year,
    String? genre,
    int? trackNumber,
    String? description,
    String? narrator,
    String? publisher,
    String? language,
    List<String>? tags,
    DateTime? lastModified,
  }) {
    return AudioFileMetadata(
      title: title ?? this.title,
      author: author ?? this.author,
      album: album ?? this.album,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      description: description ?? this.description,
      narrator: narrator ?? this.narrator,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      tags: tags ?? this.tags,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  /// Converts to JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'album': album,
      'year': year,
      'genre': genre,
      'trackNumber': trackNumber,
      'description': description,
      'narrator': narrator,
      'publisher': publisher,
      'language': language,
      'tags': tags,
      'lastModified': lastModified.toIso8601String(),
    };
  }

  /// Creates from JSON
  factory AudioFileMetadata.fromJson(Map<String, dynamic> json) {
    return AudioFileMetadata(
      title: json['title'] ?? '',
      author: json['author'],
      album: json['album'],
      year: json['year'],
      genre: json['genre'],
      trackNumber: json['trackNumber'],
      description: json['description'],
      narrator: json['narrator'],
      publisher: json['publisher'],
      language: json['language'],
      tags: List<String>.from(json['tags'] ?? []),
      lastModified: DateTime.parse(json['lastModified'] ?? DateTime.now().toIso8601String()),
    );
  }

  /// Checks if metadata is empty (only has title)
  bool get isEmpty {
    return author == null &&
           album == null &&
           year == null &&
           genre == null &&
           trackNumber == null &&
           description == null &&
           narrator == null &&
           publisher == null &&
           language == null &&
           tags.isEmpty;
  }

  /// Gets a summary of the metadata
  String get summary {
    final parts = <String>[title];
    
    if (author != null) parts.add('by $author');
    if (album != null) parts.add('from $album');
    if (year != null) parts.add('($year)');
    
    return parts.join(' ');
  }
}
