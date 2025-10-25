import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Playlist entity representing a collection of audiobooks
class Playlist extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? coverImagePath;
  final List<String> audiobookIds;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPublic;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayedAt;
  final Duration? totalDuration;
  final Map<String, dynamic> metadata;
  final List<PlaylistTag> tags;

  const Playlist({
    required this.id,
    required this.name,
    this.description,
    this.coverImagePath,
    this.audiobookIds = const [],
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.isPublic = false,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
    this.totalDuration,
    this.metadata = const {},
    this.tags = const [],
  });

  /// Creates a new playlist with updated fields
  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    String? coverImagePath,
    List<String>? audiobookIds,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPublic,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayedAt,
    Duration? totalDuration,
    Map<String, dynamic>? metadata,
    List<PlaylistTag>? tags,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      audiobookIds: audiobookIds ?? this.audiobookIds,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPublic: isPublic ?? this.isPublic,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      totalDuration: totalDuration ?? this.totalDuration,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
    );
  }

  /// Creates a playlist from JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImagePath: json['coverImagePath'] as String?,
      audiobookIds: List<String>.from(json['audiobookIds'] as List? ?? []),
      userId: json['userId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isPublic: json['isPublic'] as bool? ?? false,
      isFavorite: json['isFavorite'] as bool? ?? false,
      playCount: json['playCount'] as int? ?? 0,
      lastPlayedAt: json['lastPlayedAt'] != null 
          ? DateTime.parse(json['lastPlayedAt'] as String) 
          : null,
      totalDuration: json['totalDuration'] != null 
          ? Duration(milliseconds: json['totalDuration'] as int) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      tags: (json['tags'] as List?)
          ?.map((tag) => PlaylistTag.fromJson(tag as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  /// Converts playlist to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverImagePath': coverImagePath,
      'audiobookIds': audiobookIds,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isPublic': isPublic,
      'isFavorite': isFavorite,
      'playCount': playCount,
      'lastPlayedAt': lastPlayedAt?.toIso8601String(),
      'totalDuration': totalDuration?.inMilliseconds,
      'metadata': metadata,
      'tags': tags.map((tag) => tag.toJson()).toList(),
    };
  }

  /// Creates a new playlist with default values
  factory Playlist.create({
    required String name,
    required String userId,
    String? description,
    bool isPublic = false,
  }) {
    final now = DateTime.now();
    return Playlist(
      id: const Uuid().v4(),
      name: name,
      description: description,
      userId: userId,
      createdAt: now,
      updatedAt: now,
      isPublic: isPublic,
    );
  }

  /// Adds an audiobook to the playlist
  Playlist addAudiobook(String audiobookId) {
    if (audiobookIds.contains(audiobookId)) return this;
    
    return copyWith(
      audiobookIds: [...audiobookIds, audiobookId],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes an audiobook from the playlist
  Playlist removeAudiobook(String audiobookId) {
    return copyWith(
      audiobookIds: audiobookIds.where((id) => id != audiobookId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Reorders audiobooks in the playlist
  Playlist reorderAudiobooks(List<String> newOrder) {
    return copyWith(
      audiobookIds: newOrder,
      updatedAt: DateTime.now(),
    );
  }

  /// Updates playlist metadata
  Playlist updateMetadata(Map<String, dynamic> newMetadata) {
    final updatedMetadata = Map<String, dynamic>.from(metadata);
    updatedMetadata.addAll(newMetadata);
    
    return copyWith(
      metadata: updatedMetadata,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a tag to the playlist
  Playlist addTag(PlaylistTag tag) {
    if (tags.any((t) => t.id == tag.id)) return this;
    
    return copyWith(
      tags: [...tags, tag],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a tag from the playlist
  Playlist removeTag(String tagId) {
    return copyWith(
      tags: tags.where((t) => t.id != tagId).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Updates playlist play count
  Playlist incrementPlayCount() {
    return copyWith(
      playCount: playCount + 1,
      lastPlayedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Gets the number of audiobooks in the playlist
  int get audiobookCount => audiobookIds.length;

  /// Gets the playlist's cover image or default
  String get coverImageOrDefault => coverImagePath ?? 'assets/images/default_playlist.png';

  /// Checks if the playlist is empty
  bool get isEmpty => audiobookIds.isEmpty;

  /// Checks if the playlist has audiobooks
  bool get isNotEmpty => audiobookIds.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    coverImagePath,
    audiobookIds,
    userId,
    createdAt,
    updatedAt,
    isPublic,
    isFavorite,
    playCount,
    lastPlayedAt,
    totalDuration,
    metadata,
    tags,
  ];
}

/// Playlist tag entity
class PlaylistTag extends Equatable {
  final String id;
  final String name;
  final String color;
  final DateTime createdAt;

  const PlaylistTag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });

  /// Creates a playlist tag from JSON
  factory PlaylistTag.fromJson(Map<String, dynamic> json) {
    return PlaylistTag(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Converts playlist tag to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a new playlist tag
  factory PlaylistTag.create({
    required String name,
    required String color,
  }) {
    return PlaylistTag(
      id: const Uuid().v4(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, color, createdAt];
}
