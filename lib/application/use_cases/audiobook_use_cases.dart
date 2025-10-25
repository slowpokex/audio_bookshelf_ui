import 'package:equatable/equatable.dart';
import '../../domain/entities/audiobook.dart';
import '../../core/utils/result.dart';

/// Use case for getting all audiobooks
class GetAudiobooksUseCase {
  final AudiobookRepository _repository;

  GetAudiobooksUseCase(this._repository);

  Future<Result<List<Audiobook>>> call(GetAudiobooksParams params) async {
    try {
      final audiobooks = await _repository.getAudiobooks(
        limit: params.limit,
        offset: params.offset,
        searchQuery: params.searchQuery,
        genre: params.genre,
        author: params.author,
        narrator: params.narrator,
        isCompleted: params.isCompleted,
        isFavorite: params.isFavorite,
        sortBy: params.sortBy,
        sortOrder: params.sortOrder,
      );
      return Result.success(audiobooks);
    } catch (e) {
      return Result.failure('Failed to get audiobooks: ${e.toString()}');
    }
  }
}

/// Use case for getting a single audiobook
class GetAudiobookUseCase {
  final AudiobookRepository _repository;

  GetAudiobookUseCase(this._repository);

  Future<Result<Audiobook>> call(GetAudiobookParams params) async {
    try {
      final audiobook = await _repository.getAudiobookById(params.id);
      if (audiobook == null) {
        return Result.failure('Audiobook not found');
      }
      return Result.success(audiobook);
    } catch (e) {
      return Result.failure('Failed to get audiobook: ${e.toString()}');
    }
  }
}

/// Use case for creating a new audiobook
class CreateAudiobookUseCase {
  final AudiobookRepository _repository;

  CreateAudiobookUseCase(this._repository);

  Future<Result<Audiobook>> call(CreateAudiobookParams params) async {
    try {
      final audiobook = Audiobook.create(
        title: params.title,
        author: params.author,
        narrator: params.narrator,
        description: params.description,
        genre: params.genre,
        year: params.year,
        isbn: params.isbn,
        publisher: params.publisher,
        language: params.language,
        duration: params.duration,
        coverImagePath: params.coverImagePath,
        audioFilePath: params.audioFilePath,
        tags: params.tags,
        series: params.series,
        seriesOrder: params.seriesOrder,
        seriesId: params.seriesId,
        metadata: params.metadata,
        isLocal: params.isLocal,
        localPath: params.localPath,
      );
      
      final createdAudiobook = await _repository.createAudiobook(audiobook);
      return Result.success(createdAudiobook);
    } catch (e) {
      return Result.failure('Failed to create audiobook: ${e.toString()}');
    }
  }
}

/// Use case for updating an audiobook
class UpdateAudiobookUseCase {
  final AudiobookRepository _repository;

  UpdateAudiobookUseCase(this._repository);

  Future<Result<Audiobook>> call(UpdateAudiobookParams params) async {
    try {
      final existingAudiobook = await _repository.getAudiobookById(params.id);
      if (existingAudiobook == null) {
        return Result.failure('Audiobook not found');
      }

      final updatedAudiobook = existingAudiobook.copyWith(
        title: params.title,
        author: params.author,
        narrator: params.narrator,
        description: params.description,
        genre: params.genre,
        year: params.year,
        isbn: params.isbn,
        publisher: params.publisher,
        language: params.language,
        duration: params.duration,
        coverImagePath: params.coverImagePath,
        audioFilePath: params.audioFilePath,
        tags: params.tags,
        series: params.series,
        seriesOrder: params.seriesOrder,
        seriesId: params.seriesId,
        metadata: params.metadata,
        isLocal: params.isLocal,
        localPath: params.localPath,
      );

      final result = await _repository.updateAudiobook(updatedAudiobook);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to update audiobook: ${e.toString()}');
    }
  }
}

/// Use case for deleting an audiobook
class DeleteAudiobookUseCase {
  final AudiobookRepository _repository;

  DeleteAudiobookUseCase(this._repository);

  Future<Result<void>> call(DeleteAudiobookParams params) async {
    try {
      final existingAudiobook = await _repository.getAudiobookById(params.id);
      if (existingAudiobook == null) {
        return Result.failure('Audiobook not found');
      }

      await _repository.deleteAudiobook(params.id);
      return Result.success(null);
    } catch (e) {
      return Result.failure('Failed to delete audiobook: ${e.toString()}');
    }
  }
}

/// Use case for marking an audiobook as favorite
class ToggleFavoriteUseCase {
  final AudiobookRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  Future<Result<Audiobook>> call(ToggleFavoriteParams params) async {
    try {
      final audiobook = await _repository.getAudiobookById(params.id);
      if (audiobook == null) {
        return Result.failure('Audiobook not found');
      }

      final updatedAudiobook = audiobook.copyWith(
        isFavorite: !audiobook.isFavorite,
        updatedAt: DateTime.now(),
      );
      final result = await _repository.updateAudiobook(updatedAudiobook);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to toggle favorite: ${e.toString()}');
    }
  }
}

/// Use case for rating an audiobook
class RateAudiobookUseCase {
  final AudiobookRepository _repository;

  RateAudiobookUseCase(this._repository);

  Future<Result<Audiobook>> call(RateAudiobookParams params) async {
    try {
      final audiobook = await _repository.getAudiobookById(params.id);
      if (audiobook == null) {
        return Result.failure('Audiobook not found');
      }

      final updatedAudiobook = audiobook.copyWith(
        rating: params.rating,
        updatedAt: DateTime.now(),
      );
      final result = await _repository.updateAudiobook(updatedAudiobook);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to rate audiobook: ${e.toString()}');
    }
  }
}

/// Use case for searching audiobooks
class SearchAudiobooksUseCase {
  final AudiobookRepository _repository;

  SearchAudiobooksUseCase(this._repository);

  Future<Result<List<Audiobook>>> call(SearchAudiobooksParams params) async {
    try {
      final audiobooks = await _repository.searchAudiobooks(
        query: params.query,
        limit: params.limit,
        offset: params.offset,
        filters: params.filters,
      );
      return Result.success(audiobooks);
    } catch (e) {
      return Result.failure('Failed to search audiobooks: ${e.toString()}');
    }
  }
}

/// Use case for getting audiobook recommendations
class GetRecommendationsUseCase {
  final AudiobookRepository _repository;

  GetRecommendationsUseCase(this._repository);

  Future<Result<List<Audiobook>>> call(GetRecommendationsParams params) async {
    try {
      final recommendations = await _repository.getRecommendations(
        userId: params.userId,
        limit: params.limit,
        basedOn: params.basedOn,
      );
      return Result.success(recommendations);
    } catch (e) {
      return Result.failure('Failed to get recommendations: ${e.toString()}');
    }
  }
}

// Parameter classes
class GetAudiobooksParams extends Equatable {
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

  const GetAudiobooksParams({
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

class GetAudiobookParams extends Equatable {
  final String id;

  const GetAudiobookParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class CreateAudiobookParams extends Equatable {
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

  const CreateAudiobookParams({
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

class UpdateAudiobookParams extends Equatable {
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

  const UpdateAudiobookParams({
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

class DeleteAudiobookParams extends Equatable {
  final String id;

  const DeleteAudiobookParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class ToggleFavoriteParams extends Equatable {
  final String id;

  const ToggleFavoriteParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class RateAudiobookParams extends Equatable {
  final String id;
  final double rating;

  const RateAudiobookParams({
    required this.id,
    required this.rating,
  });

  @override
  List<Object?> get props => [id, rating];
}

class SearchAudiobooksParams extends Equatable {
  final String query;
  final int? limit;
  final int? offset;
  final Map<String, dynamic>? filters;

  const SearchAudiobooksParams({
    required this.query,
    this.limit,
    this.offset,
    this.filters,
  });

  @override
  List<Object?> get props => [query, limit, offset, filters];
}

class GetRecommendationsParams extends Equatable {
  final String userId;
  final int? limit;
  final String? basedOn;

  const GetRecommendationsParams({
    required this.userId,
    this.limit,
    this.basedOn,
  });

  @override
  List<Object?> get props => [userId, limit, basedOn];
}

/// Repository interface for audiobooks
abstract class AudiobookRepository {
  Future<List<Audiobook>> getAudiobooks({
    int? limit,
    int? offset,
    String? searchQuery,
    String? genre,
    String? author,
    String? narrator,
    bool? isCompleted,
    bool? isFavorite,
    String? sortBy,
    String? sortOrder,
  });

  Future<Audiobook?> getAudiobookById(String id);
  Future<Audiobook> createAudiobook(Audiobook audiobook);
  Future<Audiobook> updateAudiobook(Audiobook audiobook);
  Future<void> deleteAudiobook(String id);
  Future<List<Audiobook>> searchAudiobooks({
    required String query,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  });
  Future<List<Audiobook>> getRecommendations({
    required String userId,
    int? limit,
    String? basedOn,
  });
}
