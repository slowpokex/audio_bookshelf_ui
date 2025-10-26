import 'package:equatable/equatable.dart';
import '../../domain/entities/progress.dart';
import '../../core/utils/result.dart';

/// Use case for getting user's progress for an audiobook
class GetProgressUseCase {
  final ProgressRepository _repository;

  GetProgressUseCase(this._repository);

  Future<Result<Progress?>> call(GetProgressParams params) async {
    try {
      final progress = await _repository.getProgressByUserAndAudiobook(
        params.userId,
        params.audiobookId,
      );
      return Result.success(progress);
    } catch (e) {
      return Result.failure('Failed to get progress: ${e.toString()}');
    }
  }
}

/// Use case for creating progress for an audiobook
class CreateProgressUseCase {
  final ProgressRepository _repository;

  CreateProgressUseCase(this._repository);

  Future<Result<Progress>> call(CreateProgressParams params) async {
    try {
      final progress = Progress.create(
        userId: params.userId,
        audiobookId: params.audiobookId,
        totalDuration: params.totalDuration,
      );
      
      final createdProgress = await _repository.createProgress(progress);
      return Result.success(createdProgress);
    } catch (e) {
      return Result.failure('Failed to create progress: ${e.toString()}');
    }
  }
}

/// Use case for updating progress position
class UpdateProgressPositionUseCase {
  final ProgressRepository _repository;

  UpdateProgressPositionUseCase(this._repository);

  Future<Result<Progress>> call(UpdateProgressPositionParams params) async {
    try {
      final existingProgress = await _repository.getProgressByUserAndAudiobook(
        params.userId,
        params.audiobookId,
      );
      
      if (existingProgress == null) {
        return Result.failure('Progress not found');
      }

      final updatedProgress = existingProgress.updatePosition(params.newPosition);
      final result = await _repository.updateProgress(updatedProgress);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to update progress position: ${e.toString()}');
    }
  }
}

/// Use case for adding a bookmark
class AddBookmarkUseCase {
  final ProgressRepository _repository;

  AddBookmarkUseCase(this._repository);

  Future<Result<Progress>> call(AddBookmarkParams params) async {
    try {
      final existingProgress = await _repository.getProgressByUserAndAudiobook(
        params.userId,
        params.audiobookId,
      );
      
      if (existingProgress == null) {
        return Result.failure('Progress not found');
      }

      final bookmark = Bookmark.create(
        progressId: existingProgress.id,
        position: params.position,
        title: params.title,
        note: params.note,
      );

      final updatedProgress = existingProgress.addBookmark(bookmark);
      final result = await _repository.updateProgress(updatedProgress);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to add bookmark: ${e.toString()}');
    }
  }
}

/// Use case for removing a bookmark
class RemoveBookmarkUseCase {
  final ProgressRepository _repository;

  RemoveBookmarkUseCase(this._repository);

  Future<Result<Progress>> call(RemoveBookmarkParams params) async {
    try {
      final existingProgress = await _repository.getProgressByUserAndAudiobook(
        params.userId,
        params.audiobookId,
      );
      
      if (existingProgress == null) {
        return Result.failure('Progress not found');
      }

      final updatedProgress = existingProgress.removeBookmark(params.bookmarkId);
      final result = await _repository.updateProgress(updatedProgress);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to remove bookmark: ${e.toString()}');
    }
  }
}

/// Use case for getting all progress for a user
class GetUserProgressUseCase {
  final ProgressRepository _repository;

  GetUserProgressUseCase(this._repository);

  Future<Result<List<Progress>>> call(GetUserProgressParams params) async {
    try {
      final progressList = await _repository.getProgressByUser(
        params.userId,
        limit: params.limit,
        offset: params.offset,
        isCompleted: params.isCompleted,
      );
      return Result.success(progressList);
    } catch (e) {
      return Result.failure('Failed to get user progress: ${e.toString()}');
    }
  }
}

/// Use case for getting reading statistics
class GetReadingStatsUseCase {
  final ProgressRepository _repository;

  GetReadingStatsUseCase(this._repository);

  Future<Result<ReadingStats>> call(GetReadingStatsParams params) async {
    try {
      final stats = await _repository.getReadingStats(
        params.userId,
        startDate: params.startDate,
        endDate: params.endDate,
      );
      return Result.success(stats);
    } catch (e) {
      return Result.failure('Failed to get reading statistics: ${e.toString()}');
    }
  }
}

/// Use case for syncing progress across devices
class SyncProgressUseCase {
  final ProgressRepository _repository;

  SyncProgressUseCase(this._repository);

  Future<Result<List<Progress>>> call(SyncProgressParams params) async {
    try {
      final syncedProgress = await _repository.syncProgress(
        params.userId,
        params.lastSyncAt,
      );
      return Result.success(syncedProgress);
    } catch (e) {
      return Result.failure('Failed to sync progress: ${e.toString()}');
    }
  }
}

// Parameter classes
class GetProgressParams extends Equatable {
  final String userId;
  final String audiobookId;

  const GetProgressParams({
    required this.userId,
    required this.audiobookId,
  });

  @override
  List<Object?> get props => [userId, audiobookId];
}

class CreateProgressParams extends Equatable {
  final String userId;
  final String audiobookId;
  final Duration totalDuration;

  const CreateProgressParams({
    required this.userId,
    required this.audiobookId,
    required this.totalDuration,
  });

  @override
  List<Object?> get props => [userId, audiobookId, totalDuration];
}

class UpdateProgressPositionParams extends Equatable {
  final String userId;
  final String audiobookId;
  final Duration newPosition;

  const UpdateProgressPositionParams({
    required this.userId,
    required this.audiobookId,
    required this.newPosition,
  });

  @override
  List<Object?> get props => [userId, audiobookId, newPosition];
}

class AddBookmarkParams extends Equatable {
  final String userId;
  final String audiobookId;
  final Duration position;
  final String? title;
  final String? note;

  const AddBookmarkParams({
    required this.userId,
    required this.audiobookId,
    required this.position,
    this.title,
    this.note,
  });

  @override
  List<Object?> get props => [userId, audiobookId, position, title, note];
}

class RemoveBookmarkParams extends Equatable {
  final String userId;
  final String audiobookId;
  final String bookmarkId;

  const RemoveBookmarkParams({
    required this.userId,
    required this.audiobookId,
    required this.bookmarkId,
  });

  @override
  List<Object?> get props => [userId, audiobookId, bookmarkId];
}

class GetUserProgressParams extends Equatable {
  final String userId;
  final int? limit;
  final int? offset;
  final bool? isCompleted;

  const GetUserProgressParams({
    required this.userId,
    this.limit,
    this.offset,
    this.isCompleted,
  });

  @override
  List<Object?> get props => [userId, limit, offset, isCompleted];
}

class GetReadingStatsParams extends Equatable {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetReadingStatsParams({
    required this.userId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class SyncProgressParams extends Equatable {
  final String userId;
  final DateTime? lastSyncAt;

  const SyncProgressParams({
    required this.userId,
    this.lastSyncAt,
  });

  @override
  List<Object?> get props => [userId, lastSyncAt];
}

/// Reading statistics model
class ReadingStats extends Equatable {
  final String userId;
  final int totalBooksRead;
  final int totalHoursListened;
  final double averageRating;
  final Duration totalListeningTime;
  final int completedBooks;
  final int inProgressBooks;
  final List<String> favoriteGenres;
  final List<String> favoriteAuthors;
  final List<String> favoriteNarrators;
  final Map<String, int> booksByMonth;
  final Map<String, int> hoursByMonth;
  final DateTime? lastReadDate;
  final DateTime? firstReadDate;

  const ReadingStats({
    required this.userId,
    required this.totalBooksRead,
    required this.totalHoursListened,
    required this.averageRating,
    required this.totalListeningTime,
    required this.completedBooks,
    required this.inProgressBooks,
    required this.favoriteGenres,
    required this.favoriteAuthors,
    required this.favoriteNarrators,
    required this.booksByMonth,
    required this.hoursByMonth,
    this.lastReadDate,
    this.firstReadDate,
  });

  @override
  List<Object?> get props => [
    userId, totalBooksRead, totalHoursListened, averageRating, totalListeningTime,
    completedBooks, inProgressBooks, favoriteGenres, favoriteAuthors,
    favoriteNarrators, booksByMonth, hoursByMonth, lastReadDate, firstReadDate,
  ];
}

/// Repository interface for progress
abstract class ProgressRepository {
  Future<Progress?> getProgressByUserAndAudiobook(String userId, String audiobookId);
  Future<Progress> createProgress(Progress progress);
  Future<Progress> updateProgress(Progress progress);
  Future<void> deleteProgress(String id);
  Future<List<Progress>> getProgressByUser(
    String userId, {
    int? limit,
    int? offset,
    bool? isCompleted,
  });
  Future<ReadingStats> getReadingStats(
    String userId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Progress>> syncProgress(
    String userId,
    DateTime? lastSyncAt,
  );
}
