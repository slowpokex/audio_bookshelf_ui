import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;

/// Service for storing and retrieving local metadata for audio files
class MetadataStorageService {
  static const String _metadataFileName = 'metadata.json';
  
  /// Stores metadata for an audio file
  static Future<void> storeMetadata(String audioFilePath, AudioFileMetadata metadata) async {
    try {
      final metadataDir = path.dirname(audioFilePath);
      final metadataFile = File(path.join(metadataDir, _metadataFileName));
      
      // Read existing metadata or create new map
      Map<String, dynamic> allMetadata = {};
      if (await metadataFile.exists()) {
        final content = await metadataFile.readAsString();
        allMetadata = jsonDecode(content);
      }
      
      // Store metadata for this specific file
      final relativePath = path.basename(audioFilePath);
      allMetadata[relativePath] = metadata.toJson();
      
      // Write back to file
      await metadataFile.writeAsString(jsonEncode(allMetadata));
    } catch (e) {
      throw Exception('Failed to store metadata: $e');
    }
  }
  
  /// Retrieves metadata for an audio file
  static Future<AudioFileMetadata?> getMetadata(String audioFilePath) async {
    try {
      final metadataDir = path.dirname(audioFilePath);
      final metadataFile = File(path.join(metadataDir, _metadataFileName));
      
      if (!await metadataFile.exists()) {
        return null;
      }
      
      final content = await metadataFile.readAsString();
      final allMetadata = jsonDecode(content);
      
      final relativePath = path.basename(audioFilePath);
      if (allMetadata.containsKey(relativePath)) {
        return AudioFileMetadata.fromJson(allMetadata[relativePath]);
      }
      
      return null;
    } catch (e) {
      print('Failed to retrieve metadata: $e');
      return null;
    }
  }
  
  /// Removes metadata for an audio file
  static Future<void> removeMetadata(String audioFilePath) async {
    try {
      final metadataDir = path.dirname(audioFilePath);
      final metadataFile = File(path.join(metadataDir, _metadataFileName));
      
      if (!await metadataFile.exists()) {
        return;
      }
      
      final content = await metadataFile.readAsString();
      final allMetadata = jsonDecode(content);
      
      final relativePath = path.basename(audioFilePath);
      allMetadata.remove(relativePath);
      
      if (allMetadata.isEmpty) {
        // Remove metadata file if no metadata left
        await metadataFile.delete();
      } else {
        // Write back updated metadata
        await metadataFile.writeAsString(jsonEncode(allMetadata));
      }
    } catch (e) {
      throw Exception('Failed to remove metadata: $e');
    }
  }
  
  /// Gets all metadata for files in a directory
  static Future<Map<String, AudioFileMetadata>> getAllMetadata(String directoryPath) async {
    try {
      final metadataFile = File(path.join(directoryPath, _metadataFileName));
      
      if (!await metadataFile.exists()) {
        return {};
      }
      
      final content = await metadataFile.readAsString();
      final allMetadata = jsonDecode(content);
      
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
