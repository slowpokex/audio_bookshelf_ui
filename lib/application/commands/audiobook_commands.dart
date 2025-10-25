import 'package:equatable/equatable.dart';

/// Command for creating a new audiobook
class CreateAudiobookCommand extends Equatable {
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
  final String? series;
  final int? seriesOrder;
  final String? seriesId;
  final Map<String, dynamic> metadata;
  final bool isLocal;
  final String? localPath;

  const CreateAudiobookCommand({
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
    this.series,
    this.seriesOrder,
    this.seriesId,
    this.metadata = const {},
    this.isLocal = false,
    this.localPath,
  });

  @override
  List<Object?> get props => [
    title, author, narrator, description, genre, year, isbn, publisher,
    language, duration, coverImagePath, audioFilePath, tags, series,
    seriesOrder, seriesId, metadata, isLocal, localPath,
  ];
}

/// Command for updating an audiobook
class UpdateAudiobookCommand extends Equatable {
  final String id;
  final String? title;
  final String? author;
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
  final List<String>? tags;
  final String? series;
  final int? seriesOrder;
  final String? seriesId;
  final Map<String, dynamic>? metadata;
  final bool? isLocal;
  final String? localPath;

  const UpdateAudiobookCommand({
    required this.id,
    this.title,
    this.author,
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
    this.tags,
    this.series,
    this.seriesOrder,
    this.seriesId,
    this.metadata,
    this.isLocal,
    this.localPath,
  });

  @override
  List<Object?> get props => [
    id, title, author, narrator, description, genre, year, isbn, publisher,
    language, duration, coverImagePath, audioFilePath, tags, series,
    seriesOrder, seriesId, metadata, isLocal, localPath,
  ];
}

/// Command for deleting an audiobook
class DeleteAudiobookCommand extends Equatable {
  final String id;

  const DeleteAudiobookCommand({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Command for marking an audiobook as favorite
class ToggleFavoriteCommand extends Equatable {
  final String id;

  const ToggleFavoriteCommand({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Command for rating an audiobook
class RateAudiobookCommand extends Equatable {
  final String id;
  final double rating;

  const RateAudiobookCommand({
    required this.id,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, rating];
}

/// Command for updating audiobook metadata
class UpdateAudiobookMetadataCommand extends Equatable {
  final String id;
  final Map<String, dynamic> metadata;

  const UpdateAudiobookMetadataCommand({
    required this.id,
    required this.metadata,
  });

  @override
  List<Object?> get props => [id, metadata];
}

/// Command for updating audiobook tags
class UpdateAudiobookTagsCommand extends Equatable {
  final String id;
  final List<String> tags;

  const UpdateAudiobookTagsCommand({
    required this.id,
    required this.tags,
  });

  @override
  List<Object?> get props => [id, tags];
}

/// Command for updating audiobook series information
class UpdateAudiobookSeriesCommand extends Equatable {
  final String id;
  final String? series;
  final int? seriesOrder;
  final String? seriesId;

  const UpdateAudiobookSeriesCommand({
    required this.id,
    this.series,
    this.seriesOrder,
    this.seriesId,
  });

  @override
  List<Object?> get props => [id, series, seriesOrder, seriesId];
}

/// Command for updating audiobook cover image
class UpdateAudiobookCoverCommand extends Equatable {
  final String id;
  final String coverImagePath;

  const UpdateAudiobookCoverCommand({
    required this.id,
    required this.coverImagePath,
  });

  @override
  List<Object?> get props => [id, coverImagePath];
}

/// Command for updating audiobook audio file
class UpdateAudiobookAudioCommand extends Equatable {
  final String id;
  final String audioFilePath;

  const UpdateAudiobookAudioCommand({
    required this.id,
    required this.audioFilePath,
  });

  @override
  List<Object?> get props => [id, audioFilePath];
}

/// Command for updating audiobook local path
class UpdateAudiobookLocalCommand extends Equatable {
  final String id;
  final String? localPath;
  final bool isLocal;

  const UpdateAudiobookLocalCommand({
    required this.id,
    this.localPath,
    required this.isLocal,
  });

  @override
  List<Object?> get props => [id, localPath, isLocal];
}

/// Command for updating audiobook completion status
class UpdateAudiobookCompletionCommand extends Equatable {
  final String id;
  final bool isCompleted;

  const UpdateAudiobookCompletionCommand({
    required this.id,
    required this.isCompleted,
  });

  @override
  List<Object?> get props => [id, isCompleted];
}

/// Command for updating audiobook play count
class UpdateAudiobookPlayCountCommand extends Equatable {
  final String id;
  final int playCount;

  const UpdateAudiobookPlayCountCommand({
    required this.id,
    required this.playCount,
  });

  @override
  List<Object?> get props => [id, playCount];
}

/// Command for updating audiobook last played timestamp
class UpdateAudiobookLastPlayedCommand extends Equatable {
  final String id;
  final DateTime lastPlayedAt;

  const UpdateAudiobookLastPlayedCommand({
    required this.id,
    required this.lastPlayedAt,
  });

  @override
  List<Object?> get props => [id, lastPlayedAt];
}

/// Command for updating audiobook current position
class UpdateAudiobookCurrentPositionCommand extends Equatable {
  final String id;
  final Duration currentPosition;

  const UpdateAudiobookCurrentPositionCommand({
    required this.id,
    required this.currentPosition,
  });

  @override
  List<Object?> get props => [id, currentPosition];
}

/// Command for updating audiobook duration
class UpdateAudiobookDurationCommand extends Equatable {
  final String id;
  final Duration duration;

  const UpdateAudiobookDurationCommand({
    required this.id,
    required this.duration,
  });

  @override
  List<Object?> get props => [id, duration];
}

/// Command for updating audiobook language
class UpdateAudiobookLanguageCommand extends Equatable {
  final String id;
  final String language;

  const UpdateAudiobookLanguageCommand({
    required this.id,
    required this.language,
  });

  @override
  List<Object?> get props => [id, language];
}

/// Command for updating audiobook publisher
class UpdateAudiobookPublisherCommand extends Equatable {
  final String id;
  final String publisher;

  const UpdateAudiobookPublisherCommand({
    required this.id,
    required this.publisher,
  });

  @override
  List<Object?> get props => [id, publisher];
}

/// Command for updating audiobook ISBN
class UpdateAudiobookIsbnCommand extends Equatable {
  final String id;
  final String isbn;

  const UpdateAudiobookIsbnCommand({
    required this.id,
    required this.isbn,
  });

  @override
  List<Object?> get props => [id, isbn];
}

/// Command for updating audiobook year
class UpdateAudiobookYearCommand extends Equatable {
  final String id;
  final int year;

  const UpdateAudiobookYearCommand({
    required this.id,
    required this.year,
  });

  @override
  List<Object?> get props => [id, year];
}

/// Command for updating audiobook genre
class UpdateAudiobookGenreCommand extends Equatable {
  final String id;
  final String genre;

  const UpdateAudiobookGenreCommand({
    required this.id,
    required this.genre,
  });

  @override
  List<Object?> get props => [id, genre];
}

/// Command for updating audiobook narrator
class UpdateAudiobookNarratorCommand extends Equatable {
  final String id;
  final String narrator;

  const UpdateAudiobookNarratorCommand({
    required this.id,
    required this.narrator,
  });

  @override
  List<Object?> get props => [id, narrator];
}

/// Command for updating audiobook author
class UpdateAudiobookAuthorCommand extends Equatable {
  final String id;
  final String author;

  const UpdateAudiobookAuthorCommand({
    required this.id,
    required this.author,
  });

  @override
  List<Object?> get props => [id, author];
}

/// Command for updating audiobook title
class UpdateAudiobookTitleCommand extends Equatable {
  final String id;
  final String title;

  const UpdateAudiobookTitleCommand({
    required this.id,
    required this.title,
  });

  @override
  List<Object?> get props => [id, title];
}

/// Command for updating audiobook description
class UpdateAudiobookDescriptionCommand extends Equatable {
  final String id;
  final String description;

  const UpdateAudiobookDescriptionCommand({
    required this.id,
    required this.description,
  });

  @override
  List<Object?> get props => [id, description];
}
