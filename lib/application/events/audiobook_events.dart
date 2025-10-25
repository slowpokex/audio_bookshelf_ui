import 'package:equatable/equatable.dart';
import '../../domain/entities/audiobook.dart';

/// Base class for all audiobook events
abstract class AudiobookEvent extends Equatable {
  final String audiobookId;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const AudiobookEvent({
    required this.audiobookId,
    required this.timestamp,
    this.metadata = const {},
  });

  @override
  List<Object?> get props => [audiobookId, timestamp, metadata];
}

/// Event fired when an audiobook is created
class AudiobookCreatedEvent extends AudiobookEvent {
  final Audiobook audiobook;

  const AudiobookCreatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.audiobook,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, audiobook];
}

/// Event fired when an audiobook is updated
class AudiobookUpdatedEvent extends AudiobookEvent {
  final Audiobook audiobook;
  final Map<String, dynamic> changes;

  const AudiobookUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.audiobook,
    required this.changes,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, audiobook, changes];
}

/// Event fired when an audiobook is deleted
class AudiobookDeletedEvent extends AudiobookEvent {
  const AudiobookDeletedEvent({
    required super.audiobookId,
    required super.timestamp,
    super.metadata,
  });
}

/// Event fired when an audiobook is marked as favorite
class AudiobookFavoritedEvent extends AudiobookEvent {
  final bool isFavorite;

  const AudiobookFavoritedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.isFavorite,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, isFavorite];
}

/// Event fired when an audiobook is rated
class AudiobookRatedEvent extends AudiobookEvent {
  final double rating;
  final double previousRating;

  const AudiobookRatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.rating,
    required this.previousRating,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, rating, previousRating];
}

/// Event fired when an audiobook is played
class AudiobookPlayedEvent extends AudiobookEvent {
  final Duration position;
  final Duration duration;

  const AudiobookPlayedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.position,
    required this.duration,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, position, duration];
}

/// Event fired when an audiobook is paused
class AudiobookPausedEvent extends AudiobookEvent {
  final Duration position;
  final Duration duration;

  const AudiobookPausedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.position,
    required this.duration,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, position, duration];
}

/// Event fired when an audiobook is stopped
class AudiobookStoppedEvent extends AudiobookEvent {
  final Duration position;
  final Duration duration;

  const AudiobookStoppedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.position,
    required this.duration,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, position, duration];
}

/// Event fired when an audiobook is completed
class AudiobookCompletedEvent extends AudiobookEvent {
  final Duration totalDuration;
  final DateTime completedAt;

  const AudiobookCompletedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.totalDuration,
    required this.completedAt,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, totalDuration, completedAt];
}

/// Event fired when an audiobook's progress is updated
class AudiobookProgressUpdatedEvent extends AudiobookEvent {
  final Duration currentPosition;
  final Duration totalDuration;
  final double progressPercentage;

  const AudiobookProgressUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.currentPosition,
    required this.totalDuration,
    required this.progressPercentage,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, currentPosition, totalDuration, progressPercentage];
}

/// Event fired when an audiobook's metadata is updated
class AudiobookMetadataUpdatedEvent extends AudiobookEvent {
  final Map<String, dynamic> newMetadata;
  final Map<String, dynamic> previousMetadata;

  const AudiobookMetadataUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.newMetadata,
    required this.previousMetadata,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, newMetadata, previousMetadata];
}

/// Event fired when an audiobook's tags are updated
class AudiobookTagsUpdatedEvent extends AudiobookEvent {
  final List<String> newTags;
  final List<String> previousTags;

  const AudiobookTagsUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.newTags,
    required this.previousTags,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, newTags, previousTags];
}

/// Event fired when an audiobook's series information is updated
class AudiobookSeriesUpdatedEvent extends AudiobookEvent {
  final String? series;
  final int? seriesOrder;
  final String? seriesId;
  final String? previousSeries;
  final int? previousSeriesOrder;
  final String? previousSeriesId;

  const AudiobookSeriesUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    this.series,
    this.seriesOrder,
    this.seriesId,
    this.previousSeries,
    this.previousSeriesOrder,
    this.previousSeriesId,
    super.metadata,
  });

  @override
  List<Object?> get props => [
    ...super.props, series, seriesOrder, seriesId,
    previousSeries, previousSeriesOrder, previousSeriesId,
  ];
}

/// Event fired when an audiobook's cover image is updated
class AudiobookCoverUpdatedEvent extends AudiobookEvent {
  final String newCoverPath;
  final String? previousCoverPath;

  const AudiobookCoverUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.newCoverPath,
    this.previousCoverPath,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, newCoverPath, previousCoverPath];
}

/// Event fired when an audiobook's audio file is updated
class AudiobookAudioUpdatedEvent extends AudiobookEvent {
  final String newAudioPath;
  final String? previousAudioPath;

  const AudiobookAudioUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.newAudioPath,
    this.previousAudioPath,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, newAudioPath, previousAudioPath];
}

/// Event fired when an audiobook's local status is updated
class AudiobookLocalStatusUpdatedEvent extends AudiobookEvent {
  final bool isLocal;
  final String? localPath;
  final bool previousIsLocal;
  final String? previousLocalPath;

  const AudiobookLocalStatusUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.isLocal,
    this.localPath,
    required this.previousIsLocal,
    this.previousLocalPath,
    super.metadata,
  });

  @override
  List<Object?> get props => [
    ...super.props, isLocal, localPath, previousIsLocal, previousLocalPath,
  ];
}

/// Event fired when an audiobook's completion status is updated
class AudiobookCompletionStatusUpdatedEvent extends AudiobookEvent {
  final bool isCompleted;
  final bool previousIsCompleted;

  const AudiobookCompletionStatusUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.isCompleted,
    required this.previousIsCompleted,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, isCompleted, previousIsCompleted];
}

/// Event fired when an audiobook's play count is updated
class AudiobookPlayCountUpdatedEvent extends AudiobookEvent {
  final int playCount;
  final int previousPlayCount;

  const AudiobookPlayCountUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.playCount,
    required this.previousPlayCount,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, playCount, previousPlayCount];
}

/// Event fired when an audiobook's last played timestamp is updated
class AudiobookLastPlayedUpdatedEvent extends AudiobookEvent {
  final DateTime lastPlayedAt;
  final DateTime? previousLastPlayedAt;

  const AudiobookLastPlayedUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.lastPlayedAt,
    this.previousLastPlayedAt,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, lastPlayedAt, previousLastPlayedAt];
}

/// Event fired when an audiobook's current position is updated
class AudiobookCurrentPositionUpdatedEvent extends AudiobookEvent {
  final Duration currentPosition;
  final Duration previousCurrentPosition;

  const AudiobookCurrentPositionUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.currentPosition,
    required this.previousCurrentPosition,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, currentPosition, previousCurrentPosition];
}

/// Event fired when an audiobook's duration is updated
class AudiobookDurationUpdatedEvent extends AudiobookEvent {
  final Duration duration;
  final Duration previousDuration;

  const AudiobookDurationUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.duration,
    required this.previousDuration,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, duration, previousDuration];
}

/// Event fired when an audiobook's language is updated
class AudiobookLanguageUpdatedEvent extends AudiobookEvent {
  final String language;
  final String? previousLanguage;

  const AudiobookLanguageUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.language,
    this.previousLanguage,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, language, previousLanguage];
}

/// Event fired when an audiobook's publisher is updated
class AudiobookPublisherUpdatedEvent extends AudiobookEvent {
  final String publisher;
  final String? previousPublisher;

  const AudiobookPublisherUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.publisher,
    this.previousPublisher,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, publisher, previousPublisher];
}

/// Event fired when an audiobook's ISBN is updated
class AudiobookIsbnUpdatedEvent extends AudiobookEvent {
  final String isbn;
  final String? previousIsbn;

  const AudiobookIsbnUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.isbn,
    this.previousIsbn,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, isbn, previousIsbn];
}

/// Event fired when an audiobook's year is updated
class AudiobookYearUpdatedEvent extends AudiobookEvent {
  final int year;
  final int? previousYear;

  const AudiobookYearUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.year,
    this.previousYear,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, year, previousYear];
}

/// Event fired when an audiobook's genre is updated
class AudiobookGenreUpdatedEvent extends AudiobookEvent {
  final String genre;
  final String? previousGenre;

  const AudiobookGenreUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.genre,
    this.previousGenre,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, genre, previousGenre];
}

/// Event fired when an audiobook's narrator is updated
class AudiobookNarratorUpdatedEvent extends AudiobookEvent {
  final String narrator;
  final String? previousNarrator;

  const AudiobookNarratorUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.narrator,
    this.previousNarrator,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, narrator, previousNarrator];
}

/// Event fired when an audiobook's author is updated
class AudiobookAuthorUpdatedEvent extends AudiobookEvent {
  final String author;
  final String previousAuthor;

  const AudiobookAuthorUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.author,
    required this.previousAuthor,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, author, previousAuthor];
}

/// Event fired when an audiobook's title is updated
class AudiobookTitleUpdatedEvent extends AudiobookEvent {
  final String title;
  final String previousTitle;

  const AudiobookTitleUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.title,
    required this.previousTitle,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, title, previousTitle];
}

/// Event fired when an audiobook's description is updated
class AudiobookDescriptionUpdatedEvent extends AudiobookEvent {
  final String description;
  final String? previousDescription;

  const AudiobookDescriptionUpdatedEvent({
    required super.audiobookId,
    required super.timestamp,
    required this.description,
    this.previousDescription,
    super.metadata,
  });

  @override
  List<Object?> get props => [...super.props, description, previousDescription];
}
