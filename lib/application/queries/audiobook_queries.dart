import 'package:equatable/equatable.dart';

/// Query for getting all audiobooks
class GetAudiobooksQuery extends Equatable {
  final int? limit;
  final int? offset;
  final String? searchQuery;
  final String? genre;
  final String? author;
  final String? narrator;
  final bool? isCompleted;
  final bool? isFavorite;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksQuery({
    this.limit,
    this.offset,
    this.searchQuery,
    this.genre,
    this.author,
    this.narrator,
    this.isCompleted,
    this.isFavorite,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [
    limit, offset, searchQuery, genre, author, narrator,
    isCompleted, isFavorite, sortBy, sortOrder,
  ];
}

/// Query for getting a single audiobook
class GetAudiobookQuery extends Equatable {
  final String id;

  const GetAudiobookQuery({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Query for searching audiobooks
class SearchAudiobooksQuery extends Equatable {
  final String query;
  final int? limit;
  final int? offset;
  final Map<String, dynamic>? filters;

  const SearchAudiobooksQuery({
    required this.query,
    this.limit,
    this.offset,
    this.filters,
  });

  @override
  List<Object?> get props => [query, limit, offset, filters];
}

/// Query for getting audiobook recommendations
class GetRecommendationsQuery extends Equatable {
  final String userId;
  final int? limit;
  final String? basedOn;

  const GetRecommendationsQuery({
    required this.userId,
    this.limit,
    this.basedOn,
  });

  @override
  List<Object?> get props => [userId, limit, basedOn];
}

/// Query for getting audiobooks by genre
class GetAudiobooksByGenreQuery extends Equatable {
  final String genre;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByGenreQuery({
    required this.genre,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [genre, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by author
class GetAudiobooksByAuthorQuery extends Equatable {
  final String author;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByAuthorQuery({
    required this.author,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [author, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by narrator
class GetAudiobooksByNarratorQuery extends Equatable {
  final String narrator;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByNarratorQuery({
    required this.narrator,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [narrator, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by series
class GetAudiobooksBySeriesQuery extends Equatable {
  final String series;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksBySeriesQuery({
    required this.series,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [series, limit, offset, sortBy, sortOrder];
}

/// Query for getting completed audiobooks
class GetCompletedAudiobooksQuery extends Equatable {
  final String? userId;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetCompletedAudiobooksQuery({
    this.userId,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [userId, limit, offset, sortBy, sortOrder];
}

/// Query for getting favorite audiobooks
class GetFavoriteAudiobooksQuery extends Equatable {
  final String? userId;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetFavoriteAudiobooksQuery({
    this.userId,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [userId, limit, offset, sortBy, sortOrder];
}

/// Query for getting recently played audiobooks
class GetRecentlyPlayedAudiobooksQuery extends Equatable {
  final String? userId;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetRecentlyPlayedAudiobooksQuery({
    this.userId,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [userId, limit, offset, sortBy, sortOrder];
}

/// Query for getting trending audiobooks
class GetTrendingAudiobooksQuery extends Equatable {
  final int? limit;
  final int? offset;
  final String? timePeriod;
  final String? genre;

  const GetTrendingAudiobooksQuery({
    this.limit,
    this.offset,
    this.timePeriod,
    this.genre,
  });

  @override
  List<Object?> get props => [limit, offset, timePeriod, genre];
}

/// Query for getting popular audiobooks
class GetPopularAudiobooksQuery extends Equatable {
  final int? limit;
  final int? offset;
  final String? timePeriod;
  final String? genre;

  const GetPopularAudiobooksQuery({
    this.limit,
    this.offset,
    this.timePeriod,
    this.genre,
  });

  @override
  List<Object?> get props => [limit, offset, timePeriod, genre];
}

/// Query for getting new releases
class GetNewReleasesQuery extends Equatable {
  final int? limit;
  final int? offset;
  final String? genre;
  final String? author;

  const GetNewReleasesQuery({
    this.limit,
    this.offset,
    this.genre,
    this.author,
  });

  @override
  List<Object?> get props => [limit, offset, genre, author];
}

/// Query for getting audiobooks by rating
class GetAudiobooksByRatingQuery extends Equatable {
  final double minRating;
  final double? maxRating;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByRatingQuery({
    required this.minRating,
    this.maxRating,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [minRating, maxRating, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by duration
class GetAudiobooksByDurationQuery extends Equatable {
  final Duration minDuration;
  final Duration? maxDuration;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByDurationQuery({
    required this.minDuration,
    this.maxDuration,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [minDuration, maxDuration, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by year
class GetAudiobooksByYearQuery extends Equatable {
  final int year;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByYearQuery({
    required this.year,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [year, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by language
class GetAudiobooksByLanguageQuery extends Equatable {
  final String language;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByLanguageQuery({
    required this.language,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [language, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by publisher
class GetAudiobooksByPublisherQuery extends Equatable {
  final String publisher;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByPublisherQuery({
    required this.publisher,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [publisher, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by ISBN
class GetAudiobooksByIsbnQuery extends Equatable {
  final String isbn;
  final int? limit;
  final int? offset;

  const GetAudiobooksByIsbnQuery({
    required this.isbn,
    this.limit,
    this.offset,
  });

  @override
  List<Object?> get props => [isbn, limit, offset];
}

/// Query for getting audiobooks by tags
class GetAudiobooksByTagsQuery extends Equatable {
  final List<String> tags;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByTagsQuery({
    required this.tags,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [tags, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by local status
class GetAudiobooksByLocalStatusQuery extends Equatable {
  final bool isLocal;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByLocalStatusQuery({
    required this.isLocal,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [isLocal, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by play count
class GetAudiobooksByPlayCountQuery extends Equatable {
  final int minPlayCount;
  final int? maxPlayCount;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByPlayCountQuery({
    required this.minPlayCount,
    this.maxPlayCount,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [minPlayCount, maxPlayCount, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by last played date
class GetAudiobooksByLastPlayedQuery extends Equatable {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByLastPlayedQuery({
    this.fromDate,
    this.toDate,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [fromDate, toDate, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by creation date
class GetAudiobooksByCreationDateQuery extends Equatable {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByCreationDateQuery({
    this.fromDate,
    this.toDate,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [fromDate, toDate, limit, offset, sortBy, sortOrder];
}

/// Query for getting audiobooks by update date
class GetAudiobooksByUpdateDateQuery extends Equatable {
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? limit;
  final int? offset;
  final String? sortBy;
  final String? sortOrder;

  const GetAudiobooksByUpdateDateQuery({
    this.fromDate,
    this.toDate,
    this.limit,
    this.offset,
    this.sortBy,
    this.sortOrder,
  });

  @override
  List<Object?> get props => [fromDate, toDate, limit, offset, sortBy, sortOrder];
}
