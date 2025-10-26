import '../../domain/entities/audiobook.dart';
import '../../application/use_cases/audiobook_use_cases.dart';
import '../data_sources/audiobook_local_data_source.dart';
import '../data_sources/audiobook_remote_data_source.dart';
import '../models/audiobook_model.dart';

/// Implementation of the audiobook repository
class AudiobookRepositoryImpl implements AudiobookRepository {
  final AudiobookLocalDataSource _localDataSource;
  final AudiobookRemoteDataSource _remoteDataSource;

  AudiobookRepositoryImpl({
    required AudiobookLocalDataSource localDataSource,
    required AudiobookRemoteDataSource remoteDataSource,
  }) : _localDataSource = localDataSource,
       _remoteDataSource = remoteDataSource;

  @override
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
  }) async {
    try {
      // First try to get from local data source
      final localAudiobooks = await _localDataSource.getAudiobooks(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        genre: genre,
        author: author,
        narrator: narrator,
        isCompleted: isCompleted,
        isFavorite: isFavorite,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // If we have local data, return it
      if (localAudiobooks.isNotEmpty) {
        return localAudiobooks.map((model) => model.toEntity()).toList();
      }

      // Otherwise, try to get from remote data source
      final remoteAudiobooks = await _remoteDataSource.getAudiobooks(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        genre: genre,
        author: author,
        narrator: narrator,
        isCompleted: isCompleted,
        isFavorite: isFavorite,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      // Cache the remote data locally
      for (final audiobook in remoteAudiobooks) {
        await _localDataSource.cacheAudiobook(audiobook);
      }

      return remoteAudiobooks.map((model) => model.toEntity()).toList();
    } catch (e) {
      // If remote fails, try to return local data
      final localAudiobooks = await _localDataSource.getAudiobooks(
        limit: limit,
        offset: offset,
        searchQuery: searchQuery,
        genre: genre,
        author: author,
        narrator: narrator,
        isCompleted: isCompleted,
        isFavorite: isFavorite,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      return localAudiobooks.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<Audiobook?> getAudiobookById(String id) async {
    try {
      // First try to get from local data source
      final localAudiobook = await _localDataSource.getAudiobookById(id);
      if (localAudiobook != null) {
        return localAudiobook.toEntity();
      }

      // Otherwise, try to get from remote data source
      final remoteAudiobook = await _remoteDataSource.getAudiobookById(id);
      if (remoteAudiobook != null) {
        // Cache the remote data locally
        await _localDataSource.cacheAudiobook(remoteAudiobook);
        return remoteAudiobook.toEntity();
      }

      return null;
    } catch (e) {
      // If remote fails, try to return local data
      final localAudiobook = await _localDataSource.getAudiobookById(id);
      return localAudiobook?.toEntity();
    }
  }

  @override
  Future<Audiobook> createAudiobook(Audiobook audiobook) async {
    try {
      // First try to create on remote data source
      final audiobookModel = AudiobookModel.fromEntity(audiobook);
      final createdAudiobook = await _remoteDataSource.createAudiobook(audiobookModel);
      
      // Cache the created audiobook locally
      await _localDataSource.cacheAudiobook(createdAudiobook);
      
      return createdAudiobook.toEntity();
    } catch (e) {
      // If remote fails, create locally
      final audiobookModel = AudiobookModel.fromEntity(audiobook);
      final createdAudiobook = await _localDataSource.createAudiobook(audiobookModel);
      return createdAudiobook.toEntity();
    }
  }

  @override
  Future<Audiobook> updateAudiobook(Audiobook audiobook) async {
    try {
      // First try to update on remote data source
      final audiobookModel = AudiobookModel.fromEntity(audiobook);
      final updatedAudiobook = await _remoteDataSource.updateAudiobook(audiobookModel);
      
      // Cache the updated audiobook locally
      await _localDataSource.cacheAudiobook(updatedAudiobook);
      
      return updatedAudiobook.toEntity();
    } catch (e) {
      // If remote fails, update locally
      final audiobookModel = AudiobookModel.fromEntity(audiobook);
      final updatedAudiobook = await _localDataSource.updateAudiobook(audiobookModel);
      return updatedAudiobook.toEntity();
    }
  }

  @override
  Future<void> deleteAudiobook(String id) async {
    try {
      // First try to delete from remote data source
      await _remoteDataSource.deleteAudiobook(id);
      
      // Also delete from local data source
      await _localDataSource.deleteAudiobook(id);
    } catch (e) {
      // If remote fails, delete locally
      await _localDataSource.deleteAudiobook(id);
    }
  }

  @override
  Future<List<Audiobook>> searchAudiobooks({
    required String query,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    try {
      // First try to search in local data source
      final localAudiobooks = await _localDataSource.searchAudiobooks(
        searchQuery: query,
        limit: limit,
        offset: offset,
        filters: filters,
      );

      // If we have local results, return them
      if (localAudiobooks.isNotEmpty) {
        return localAudiobooks.map((model) => model.toEntity()).toList();
      }

      // Otherwise, try to search in remote data source
      final remoteAudiobooks = await _remoteDataSource.searchAudiobooks(
        query: query,
        limit: limit,
        offset: offset,
        filters: filters,
      );

      // Cache the remote results locally
      for (final audiobook in remoteAudiobooks) {
        await _localDataSource.cacheAudiobook(audiobook);
      }

      return remoteAudiobooks.map((model) => model.toEntity()).toList();
    } catch (e) {
      // If remote fails, try to return local results
      final localAudiobooks = await _localDataSource.searchAudiobooks(
        searchQuery: query,
        limit: limit,
        offset: offset,
        filters: filters,
      );

      return localAudiobooks.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<Audiobook>> getRecommendations({
    required String userId,
    int? limit,
    String? basedOn,
  }) async {
    try {
      // First try to get recommendations from remote data source
      final remoteRecommendations = await _remoteDataSource.getRecommendations(
        userId: userId,
        limit: limit,
        basedOn: basedOn,
      );

      // Cache the recommendations locally
      for (final audiobook in remoteRecommendations) {
        await _localDataSource.cacheAudiobook(audiobook);
      }

      return remoteRecommendations.map((model) => model.toEntity()).toList();
    } catch (e) {
      // If remote fails, try to get local recommendations
      final localRecommendations = await _localDataSource.getRecommendations(
        userId: userId,
        limit: limit,
        basedOn: basedOn,
      );

      return localRecommendations.map((model) => model.toEntity()).toList();
    }
  }
}
