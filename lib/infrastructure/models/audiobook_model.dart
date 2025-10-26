import '../../domain/entities/audiobook.dart';
import 'dart:convert';

/// Data model for audiobooks used in infrastructure layer
class AudiobookModel {
  final String id;
  final String title;
  final String author;
  final String? narrator;
  final String? description;
  final String? genre;
  final int? year;
  final String? isbn;
  final String? publisher;
  final String? language;
  final Duration? duration;
  final String? coverImagePath;
  final String? audioFilePath;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isCompleted;
  final bool isFavorite;
  final double rating;
  final int playCount;
  final DateTime? lastPlayedAt;
  final Duration? currentPosition;
  final String? series;
  final int? seriesOrder;
  final String? seriesId;
  final Map<String, dynamic> metadata;
  final bool isLocal;
  final String? localPath;

  const AudiobookModel({
    required this.id,
    required this.title,
    required this.author,
    this.narrator,
    this.description,
    this.genre,
    this.year,
    this.isbn,
    this.publisher,
    this.language,
    this.duration,
    this.coverImagePath,
    this.audioFilePath,
    this.tags = const [],
    required this.createdAt,
    required this.updatedAt,
    this.isCompleted = false,
    this.isFavorite = false,
    this.rating = 0.0,
    this.playCount = 0,
    this.lastPlayedAt,
    this.currentPosition,
    this.series,
    this.seriesOrder,
    this.seriesId,
    this.metadata = const {},
    this.isLocal = false,
    this.localPath,
  });

  /// Creates an AudiobookModel from an Audiobook entity
  factory AudiobookModel.fromEntity(Audiobook audiobook) {
    return AudiobookModel(
      id: audiobook.id,
      title: audiobook.title,
      author: audiobook.author,
      narrator: audiobook.narrator,
      description: audiobook.description,
      genre: audiobook.genre,
      year: audiobook.year,
      isbn: audiobook.isbn,
      publisher: audiobook.publisher,
      language: audiobook.language,
      duration: audiobook.duration,
      coverImagePath: audiobook.coverImagePath,
      audioFilePath: audiobook.audioFilePath,
      tags: audiobook.tags,
      createdAt: audiobook.createdAt,
      updatedAt: audiobook.updatedAt,
      isCompleted: audiobook.isCompleted,
      isFavorite: audiobook.isFavorite,
      rating: audiobook.rating,
      playCount: audiobook.playCount,
      lastPlayedAt: audiobook.lastPlayedAt,
      currentPosition: audiobook.currentPosition,
      series: audiobook.series,
      seriesOrder: audiobook.seriesOrder,
      seriesId: audiobook.seriesId,
      metadata: audiobook.metadata,
      isLocal: audiobook.isLocal,
      localPath: audiobook.localPath,
    );
  }

  /// Converts an AudiobookModel to an Audiobook entity
  Audiobook toEntity() {
    return Audiobook(
      id: id,
      title: title,
      author: author,
      narrator: narrator,
      description: description,
      genre: genre,
      year: year,
      isbn: isbn,
      publisher: publisher,
      language: language,
      duration: duration,
      coverImagePath: coverImagePath,
      audioFilePath: audioFilePath,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isCompleted: isCompleted,
      isFavorite: isFavorite,
      rating: rating,
      playCount: playCount,
      lastPlayedAt: lastPlayedAt,
      currentPosition: currentPosition,
      series: series,
      seriesOrder: seriesOrder,
      seriesId: seriesId,
      metadata: metadata,
      isLocal: isLocal,
      localPath: localPath,
    );
  }

  /// Creates an AudiobookModel from JSON
  factory AudiobookModel.fromJson(Map<String, dynamic> json) {
    return AudiobookModel(
      id: json['id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      narrator: json['narrator'] as String?,
      description: json['description'] as String?,
      genre: json['genre'] as String?,
      year: json['year'] as int?,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      language: json['language'] as String?,
      duration: json['duration'] != null 
          ? Duration(milliseconds: json['duration'] as int) 
          : null,
      coverImagePath: json['cover_image_path'] as String?,
      audioFilePath: json['audio_file_path'] as String?,
      tags: List<String>.from(json['tags'] as List? ?? []),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isCompleted: json['is_completed'] as bool? ?? false,
      isFavorite: json['is_favorite'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      playCount: json['play_count'] as int? ?? 0,
      lastPlayedAt: json['last_played_at'] != null 
          ? DateTime.parse(json['last_played_at'] as String) 
          : null,
      currentPosition: json['current_position'] != null 
          ? Duration(milliseconds: json['current_position'] as int) 
          : null,
      series: json['series'] as String?,
      seriesOrder: json['series_order'] as int?,
      seriesId: json['series_id'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      isLocal: json['is_local'] as bool? ?? false,
      localPath: json['local_path'] as String?,
    );
  }

  /// Converts an AudiobookModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'narrator': narrator,
      'description': description,
      'genre': genre,
      'year': year,
      'isbn': isbn,
      'publisher': publisher,
      'language': language,
      'duration': duration?.inMilliseconds,
      'cover_image_path': coverImagePath,
      'audio_file_path': audioFilePath,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_completed': isCompleted,
      'is_favorite': isFavorite,
      'rating': rating,
      'play_count': playCount,
      'last_played_at': lastPlayedAt?.toIso8601String(),
      'current_position': currentPosition?.inMilliseconds,
      'series': series,
      'series_order': seriesOrder,
      'series_id': seriesId,
      'metadata': metadata,
      'is_local': isLocal,
      'local_path': localPath,
    };
  }

  /// Creates an AudiobookModel from a database map
  factory AudiobookModel.fromMap(Map<String, dynamic> map) {
    return AudiobookModel(
      id: map['id'] as String,
      title: map['title'] as String,
      author: map['author'] as String,
      narrator: map['narrator'] as String?,
      description: map['description'] as String?,
      genre: map['genre'] as String?,
      year: map['year'] as int?,
      isbn: map['isbn'] as String?,
      publisher: map['publisher'] as String?,
      language: map['language'] as String?,
      duration: map['duration'] != null 
          ? Duration(milliseconds: map['duration'] as int) 
          : null,
      coverImagePath: map['cover_image_path'] as String?,
      audioFilePath: map['audio_file_path'] as String?,
      tags: map['tags'] != null 
          ? List<String>.from(json.decode(map['tags'] as String))
          : const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      isCompleted: (map['is_completed'] as int) == 1,
      isFavorite: (map['is_favorite'] as int) == 1,
      rating: (map['rating'] as num).toDouble(),
      playCount: map['play_count'] as int,
      lastPlayedAt: map['last_played_at'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['last_played_at'] as int)
          : null,
      currentPosition: map['current_position'] != null 
          ? Duration(milliseconds: map['current_position'] as int)
          : null,
      series: map['series'] as String?,
      seriesOrder: map['series_order'] as int?,
      seriesId: map['series_id'] as String?,
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(json.decode(map['metadata'] as String))
          : const {},
      isLocal: (map['is_local'] as int) == 1,
      localPath: map['local_path'] as String?,
    );
  }

  /// Converts an AudiobookModel to a database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'narrator': narrator,
      'description': description,
      'genre': genre,
      'year': year,
      'isbn': isbn,
      'publisher': publisher,
      'language': language,
      'duration': duration?.inMilliseconds,
      'cover_image_path': coverImagePath,
      'audio_file_path': audioFilePath,
      'tags': json.encode(tags),
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'is_completed': isCompleted ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'rating': rating,
      'play_count': playCount,
      'last_played_at': lastPlayedAt?.millisecondsSinceEpoch,
      'current_position': currentPosition?.inMilliseconds,
      'series': series,
      'series_order': seriesOrder,
      'series_id': seriesId,
      'metadata': json.encode(metadata),
      'is_local': isLocal ? 1 : 0,
      'local_path': localPath,
    };
  }

  /// Creates a copy of the AudiobookModel with updated fields
  AudiobookModel copyWith({
    String? id,
    String? title,
    String? author,
    String? narrator,
    String? description,
    String? genre,
    int? year,
    String? isbn,
    String? publisher,
    String? language,
    Duration? duration,
    String? coverImagePath,
    String? audioFilePath,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isCompleted,
    bool? isFavorite,
    double? rating,
    int? playCount,
    DateTime? lastPlayedAt,
    Duration? currentPosition,
    String? series,
    int? seriesOrder,
    String? seriesId,
    Map<String, dynamic>? metadata,
    bool? isLocal,
    String? localPath,
  }) {
    return AudiobookModel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      narrator: narrator ?? this.narrator,
      description: description ?? this.description,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      language: language ?? this.language,
      duration: duration ?? this.duration,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      audioFilePath: audioFilePath ?? this.audioFilePath,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      currentPosition: currentPosition ?? this.currentPosition,
      series: series ?? this.series,
      seriesOrder: seriesOrder ?? this.seriesOrder,
      seriesId: seriesId ?? this.seriesId,
      metadata: metadata ?? this.metadata,
      isLocal: isLocal ?? this.isLocal,
      localPath: localPath ?? this.localPath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AudiobookModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AudiobookModel(id: $id, title: $title, author: $author)';
  }
}
