import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';
import '../../core/utils/result.dart';

/// Use case for getting user profile
class GetUserProfileUseCase {
  final UserRepository _repository;

  GetUserProfileUseCase(this._repository);

  Future<Result<User>> call(GetUserProfileParams params) async {
    try {
      final user = await _repository.getUserById(params.userId);
      if (user == null) {
        return Result.failure('User not found');
      }
      return Result.success(user);
    } catch (e) {
      return Result.failure('Failed to get user profile: ${e.toString()}');
    }
  }
}

/// Use case for updating user profile
class UpdateUserProfileUseCase {
  final UserRepository _repository;

  UpdateUserProfileUseCase(this._repository);

  Future<Result<User>> call(UpdateUserProfileParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.copyWith(
        displayName: params.displayName,
        avatarPath: params.avatarPath,
        language: params.language,
        timezone: params.timezone,
      );

      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to update user profile: ${e.toString()}');
    }
  }
}

/// Use case for updating user preferences
class UpdateUserPreferencesUseCase {
  final UserRepository _repository;

  UpdateUserPreferencesUseCase(this._repository);

  Future<Result<User>> call(UpdateUserPreferencesParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.updatePreferences(params.preferences);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to update user preferences: ${e.toString()}');
    }
  }
}

/// Use case for adding favorite genre
class AddFavoriteGenreUseCase {
  final UserRepository _repository;

  AddFavoriteGenreUseCase(this._repository);

  Future<Result<User>> call(AddFavoriteGenreParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.addFavoriteGenre(params.genre);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to add favorite genre: ${e.toString()}');
    }
  }
}

/// Use case for removing favorite genre
class RemoveFavoriteGenreUseCase {
  final UserRepository _repository;

  RemoveFavoriteGenreUseCase(this._repository);

  Future<Result<User>> call(RemoveFavoriteGenreParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.removeFavoriteGenre(params.genre);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to remove favorite genre: ${e.toString()}');
    }
  }
}

/// Use case for adding favorite author
class AddFavoriteAuthorUseCase {
  final UserRepository _repository;

  AddFavoriteAuthorUseCase(this._repository);

  Future<Result<User>> call(AddFavoriteAuthorParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.addFavoriteAuthor(params.author);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to add favorite author: ${e.toString()}');
    }
  }
}

/// Use case for removing favorite author
class RemoveFavoriteAuthorUseCase {
  final UserRepository _repository;

  RemoveFavoriteAuthorUseCase(this._repository);

  Future<Result<User>> call(RemoveFavoriteAuthorParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.removeFavoriteAuthor(params.author);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to remove favorite author: ${e.toString()}');
    }
  }
}

/// Use case for adding favorite narrator
class AddFavoriteNarratorUseCase {
  final UserRepository _repository;

  AddFavoriteNarratorUseCase(this._repository);

  Future<Result<User>> call(AddFavoriteNarratorParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.addFavoriteNarrator(params.narrator);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to add favorite narrator: ${e.toString()}');
    }
  }
}

/// Use case for removing favorite narrator
class RemoveFavoriteNarratorUseCase {
  final UserRepository _repository;

  RemoveFavoriteNarratorUseCase(this._repository);

  Future<Result<User>> call(RemoveFavoriteNarratorParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.removeFavoriteNarrator(params.narrator);
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to remove favorite narrator: ${e.toString()}');
    }
  }
}

/// Use case for updating reading statistics
class UpdateReadingStatsUseCase {
  final UserRepository _repository;

  UpdateReadingStatsUseCase(this._repository);

  Future<Result<User>> call(UpdateReadingStatsParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return const Result.failure('User not found');
      }

      final updatedUser = existingUser.updateReadingStats(
        booksRead: params.booksRead,
        hoursListened: params.hoursListened,
        averageRating: params.averageRating,
      );

      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to update reading statistics: ${e.toString()}');
    }
  }
}

/// Use case for updating user's last active timestamp
class UpdateLastActiveUseCase {
  final UserRepository _repository;

  UpdateLastActiveUseCase(this._repository);

  Future<Result<User>> call(UpdateLastActiveParams params) async {
    try {
      final existingUser = await _repository.getUserById(params.userId);
      if (existingUser == null) {
        return Result.failure('User not found');
      }

      final updatedUser = existingUser.updateLastActive();
      final result = await _repository.updateUser(updatedUser);
      return Result.success(result);
    } catch (e) {
      return Result.failure('Failed to update last active: ${e.toString()}');
    }
  }
}

// Parameter classes
class GetUserProfileParams extends Equatable {
  final String userId;

  const GetUserProfileParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final String? displayName;
  final String? avatarPath;
  final String? language;
  final String? timezone;

  const UpdateUserProfileParams({
    required this.userId,
    this.displayName,
    this.avatarPath,
    this.language,
    this.timezone,
  });

  @override
  List<Object?> get props => [userId, displayName, avatarPath, language, timezone];
}

class UpdateUserPreferencesParams extends Equatable {
  final String userId;
  final Map<String, dynamic> preferences;

  const UpdateUserPreferencesParams({
    required this.userId,
    required this.preferences,
  });

  @override
  List<Object?> get props => [userId, preferences];
}

class AddFavoriteGenreParams extends Equatable {
  final String userId;
  final String genre;

  const AddFavoriteGenreParams({
    required this.userId,
    required this.genre,
  });

  @override
  List<Object?> get props => [userId, genre];
}

class RemoveFavoriteGenreParams extends Equatable {
  final String userId;
  final String genre;

  const RemoveFavoriteGenreParams({
    required this.userId,
    required this.genre,
  });

  @override
  List<Object?> get props => [userId, genre];
}

class AddFavoriteAuthorParams extends Equatable {
  final String userId;
  final String author;

  const AddFavoriteAuthorParams({
    required this.userId,
    required this.author,
  });

  @override
  List<Object?> get props => [userId, author];
}

class RemoveFavoriteAuthorParams extends Equatable {
  final String userId;
  final String author;

  const RemoveFavoriteAuthorParams({
    required this.userId,
    required this.author,
  });

  @override
  List<Object?> get props => [userId, author];
}

class AddFavoriteNarratorParams extends Equatable {
  final String userId;
  final String narrator;

  const AddFavoriteNarratorParams({
    required this.userId,
    required this.narrator,
  });

  @override
  List<Object?> get props => [userId, narrator];
}

class RemoveFavoriteNarratorParams extends Equatable {
  final String userId;
  final String narrator;

  const RemoveFavoriteNarratorParams({
    required this.userId,
    required this.narrator,
  });

  @override
  List<Object?> get props => [userId, narrator];
}

class UpdateReadingStatsParams extends Equatable {
  final String userId;
  final int? booksRead;
  final int? hoursListened;
  final double? averageRating;

  const UpdateReadingStatsParams({
    required this.userId,
    this.booksRead,
    this.hoursListened,
    this.averageRating,
  });

  @override
  List<Object?> get props => [userId, booksRead, hoursListened, averageRating];
}

class UpdateLastActiveParams extends Equatable {
  final String userId;

  const UpdateLastActiveParams({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Repository interface for users
abstract class UserRepository {
  Future<User?> getUserById(String id);
  Future<User> updateUser(User user);
  Future<List<User>> getUsers({
    int? limit,
    int? offset,
    String? searchQuery,
  });
}
