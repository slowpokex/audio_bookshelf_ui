import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// Audiobook entity representing a single audiobook
class Audiobook extends Equatable {
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
  final int? fileSize;
  final String? fileFormat;
  final String? checksum;
  final bool isCorrupted;
  final DateTime? corruptionDetectedAt;
  final String? corruptionReason;

  const Audiobook({
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
    this.isLocal = true,
    this.localPath,
    this.fileSize,
    this.fileFormat,
    this.checksum,
    this.isCorrupted = false,
    this.corruptionDetectedAt,
    this.corruptionReason,
  });

  /// Creates a new Audiobook with a generated ID
  factory Audiobook.create({
    required String title,
    required String author,
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
    List<String> tags = const [],
    String? series,
    int? seriesOrder,
    String? seriesId,
    Map<String, dynamic> metadata = const {},
    bool isLocal = true,
    String? localPath,
    int? fileSize,
    String? fileFormat,
    String? checksum,
  }) {
    final now = DateTime.now();
    return Audiobook(
      id: const Uuid().v4(),
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
      createdAt: now,
      updatedAt: now,
      series: series,
      seriesOrder: seriesOrder,
      seriesId: seriesId,
      metadata: metadata,
      isLocal: isLocal,
      localPath: localPath,
      fileSize: fileSize,
      fileFormat: fileFormat,
      checksum: checksum,
    );
  }

  /// Creates a copy of this Audiobook with updated fields
  Audiobook copyWith({
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
    int? fileSize,
    String? fileFormat,
    String? checksum,
    bool? isCorrupted,
    DateTime? corruptionDetectedAt,
    String? corruptionReason,
  }) {
    return Audiobook(
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
      fileSize: fileSize ?? this.fileSize,
      fileFormat: fileFormat ?? this.fileFormat,
      checksum: checksum ?? this.checksum,
      isCorrupted: isCorrupted ?? this.isCorrupted,
      corruptionDetectedAt: corruptionDetectedAt ?? this.corruptionDetectedAt,
      corruptionReason: corruptionReason ?? this.corruptionReason,
    );
  }

  /// Returns the progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (duration == null || currentPosition == null) return 0.0;
    return currentPosition!.inMilliseconds / duration!.inMilliseconds;
  }

  /// Returns true if the audiobook has been started
  bool get isStarted => currentPosition != null && currentPosition!.inMilliseconds > 0;

  /// Returns true if the audiobook is currently being played
  bool get isCurrentlyPlaying => false; // This would be set by the audio service

  /// Returns the remaining time
  Duration? get remainingTime {
    if (duration == null || currentPosition == null) return null;
    return duration! - currentPosition!;
  }

  /// Returns a formatted duration string
  String get formattedDuration {
    if (duration == null) return 'Unknown';
    final hours = duration!.inHours;
    final minutes = duration!.inMinutes.remainder(60);
    final seconds = duration!.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Returns a formatted current position string
  String get formattedCurrentPosition {
    if (currentPosition == null) return '0:00';
    final minutes = currentPosition!.inMinutes;
    final seconds = currentPosition!.inSeconds.remainder(60);
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns a formatted file size string
  String get formattedFileSize {
    if (fileSize == null) return 'Unknown';
    final bytes = fileSize!;
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
  }

  /// Returns true if the audiobook is part of a series
  bool get isPartOfSeries => series != null && series!.isNotEmpty;

  /// Returns the series display name
  String get seriesDisplayName {
    if (series == null) return '';
    if (seriesOrder != null) {
      return '$series #$seriesOrder';
    }
    return series!;
  }

  /// Returns the display title with series information
  String get displayTitle {
    if (isPartOfSeries && seriesOrder != null) {
      return '$title ($series #$seriesOrder)';
    }
    return title;
  }

  /// Returns the display author
  String get displayAuthor {
    if (narrator != null && narrator!.isNotEmpty) {
      return '$author (Narrated by $narrator)';
    }
    return author;
  }

  /// Returns true if the audiobook has a cover image
  bool get hasCoverImage => coverImagePath != null && coverImagePath!.isNotEmpty;

  /// Returns true if the audiobook has an audio file
  bool get hasAudioFile => audioFilePath != null && audioFilePath!.isNotEmpty;

  /// Returns true if the audiobook is valid
  bool get isValid => title.isNotEmpty && author.isNotEmpty;

  /// Returns true if the audiobook is corrupted
  bool get isHealthy => !isCorrupted;

  /// Returns the corruption status message
  String get corruptionStatus {
    if (!isCorrupted) return 'Healthy';
    if (corruptionReason != null) return 'Corrupted: $corruptionReason';
    return 'Corrupted';
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        narrator,
        description,
        genre,
        year,
        isbn,
        publisher,
        language,
        duration,
        coverImagePath,
        audioFilePath,
        tags,
        createdAt,
        updatedAt,
        isCompleted,
        isFavorite,
        rating,
        playCount,
        lastPlayedAt,
        currentPosition,
        series,
        seriesOrder,
        seriesId,
        metadata,
        isLocal,
        localPath,
        fileSize,
        fileFormat,
        checksum,
        isCorrupted,
        corruptionDetectedAt,
        corruptionReason,
      ];
}
