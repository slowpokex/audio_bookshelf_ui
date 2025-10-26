import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Progress entity representing reading/listening progress
class Progress extends Equatable {
  final String id;
  final String userId;
  final String audiobookId;
  final Duration currentPosition;
  final Duration totalDuration;
  final double progressPercentage;
  final DateTime lastUpdatedAt;
  final DateTime createdAt;
  final bool isCompleted;
  final List<Bookmark> bookmarks;
  final Map<String, dynamic> metadata;

  const Progress({
    required this.id,
    required this.userId,
    required this.audiobookId,
    required this.currentPosition,
    required this.totalDuration,
    required this.progressPercentage,
    required this.lastUpdatedAt,
    required this.createdAt,
    this.isCompleted = false,
    this.bookmarks = const [],
    this.metadata = const {},
  });

  /// Creates a new progress with updated fields
  Progress copyWith({
    String? id,
    String? userId,
    String? audiobookId,
    Duration? currentPosition,
    Duration? totalDuration,
    double? progressPercentage,
    DateTime? lastUpdatedAt,
    DateTime? createdAt,
    bool? isCompleted,
    List<Bookmark>? bookmarks,
    Map<String, dynamic>? metadata,
  }) {
    return Progress(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      audiobookId: audiobookId ?? this.audiobookId,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
      bookmarks: bookmarks ?? this.bookmarks,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates progress from JSON
  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'] as String,
      userId: json['userId'] as String,
      audiobookId: json['audiobookId'] as String,
      currentPosition: Duration(milliseconds: json['currentPosition'] as int),
      totalDuration: Duration(milliseconds: json['totalDuration'] as int),
      progressPercentage: (json['progressPercentage'] as num).toDouble(),
      lastUpdatedAt: DateTime.parse(json['lastUpdatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      bookmarks: (json['bookmarks'] as List?)
          ?.map((bookmark) => Bookmark.fromJson(bookmark as Map<String, dynamic>))
          .toList() ?? [],
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  /// Converts progress to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'audiobookId': audiobookId,
      'currentPosition': currentPosition.inMilliseconds,
      'totalDuration': totalDuration.inMilliseconds,
      'progressPercentage': progressPercentage,
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'isCompleted': isCompleted,
      'bookmarks': bookmarks.map((bookmark) => bookmark.toJson()).toList(),
      'metadata': metadata,
    };
  }

  /// Creates a new progress with default values
  factory Progress.create({
    required String userId,
    required String audiobookId,
    required Duration totalDuration,
  }) {
    final now = DateTime.now();
    return Progress(
      id: const Uuid().v4(),
      userId: userId,
      audiobookId: audiobookId,
      currentPosition: Duration.zero,
      totalDuration: totalDuration,
      progressPercentage: 0.0,
      lastUpdatedAt: now,
      createdAt: now,
    );
  }

  /// Updates progress position
  Progress updatePosition(Duration newPosition) {
    final newPercentage = totalDuration.inMilliseconds > 0 
        ? (newPosition.inMilliseconds / totalDuration.inMilliseconds * 100).clamp(0.0, 100.0)
        : 0.0;
    
    final isCompleted = newPercentage >= 95.0; // Consider 95% as completed
    
    return copyWith(
      currentPosition: newPosition,
      progressPercentage: newPercentage,
      isCompleted: isCompleted,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Adds a bookmark
  Progress addBookmark(Bookmark bookmark) {
    return copyWith(
      bookmarks: [...bookmarks, bookmark],
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Removes a bookmark
  Progress removeBookmark(String bookmarkId) {
    return copyWith(
      bookmarks: bookmarks.where((b) => b.id != bookmarkId).toList(),
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Updates progress metadata
  Progress updateMetadata(Map<String, dynamic> newMetadata) {
    final updatedMetadata = Map<String, dynamic>.from(metadata);
    updatedMetadata.addAll(newMetadata);
    
    return copyWith(
      metadata: updatedMetadata,
      lastUpdatedAt: DateTime.now(),
    );
  }

  /// Gets remaining duration
  Duration get remainingDuration {
    if (isCompleted) return Duration.zero;
    return totalDuration - currentPosition;
  }

  /// Gets formatted current position
  String get formattedCurrentPosition {
    final hours = currentPosition.inHours;
    final minutes = currentPosition.inMinutes % 60;
    final seconds = currentPosition.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Gets formatted total duration
  String get formattedTotalDuration {
    final hours = totalDuration.inHours;
    final minutes = totalDuration.inMinutes % 60;
    final seconds = totalDuration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Gets formatted remaining duration
  String get formattedRemainingDuration {
    final hours = remainingDuration.inHours;
    final minutes = remainingDuration.inMinutes % 60;
    final seconds = remainingDuration.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    audiobookId,
    currentPosition,
    totalDuration,
    progressPercentage,
    lastUpdatedAt,
    createdAt,
    isCompleted,
    bookmarks,
    metadata,
  ];
}

/// Bookmark entity for marking specific positions in audiobooks
class Bookmark extends Equatable {
  final String id;
  final String progressId;
  final Duration position;
  final String? title;
  final String? note;
  final DateTime createdAt;
  final Map<String, dynamic> metadata;

  const Bookmark({
    required this.id,
    required this.progressId,
    required this.position,
    this.title,
    this.note,
    required this.createdAt,
    this.metadata = const {},
  });

  /// Creates a bookmark from JSON
  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as String,
      progressId: json['progressId'] as String,
      position: Duration(milliseconds: json['position'] as int),
      title: json['title'] as String?,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  /// Converts bookmark to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progressId': progressId,
      'position': position.inMilliseconds,
      'title': title,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Creates a new bookmark
  factory Bookmark.create({
    required String progressId,
    required Duration position,
    String? title,
    String? note,
  }) {
    return Bookmark(
      id: const Uuid().v4(),
      progressId: progressId,
      position: position,
      title: title,
      note: note,
      createdAt: DateTime.now(),
    );
  }

  /// Gets formatted position
  String get formattedPosition {
    final hours = position.inHours;
    final minutes = position.inMinutes % 60;
    final seconds = position.inSeconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  @override
  List<Object?> get props => [
    id,
    progressId,
    position,
    title,
    note,
    createdAt,
    metadata,
  ];
}
