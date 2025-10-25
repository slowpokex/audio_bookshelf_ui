import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/audiobook.dart';
import '../../../application/use_cases/audiobook_use_cases.dart';

/// Events for the audiobook bloc
abstract class AudiobookEvent extends Equatable {
  const AudiobookEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load audiobooks
class LoadAudiobooksEvent extends AudiobookEvent {
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

  const LoadAudiobooksEvent({
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

/// Event to load a single audiobook
class LoadAudiobookEvent extends AudiobookEvent {
  final String id;

  const LoadAudiobookEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to create an audiobook
class CreateAudiobookEvent extends AudiobookEvent {
  final CreateAudiobookParams params;

  const CreateAudiobookEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Event to update an audiobook
class UpdateAudiobookEvent extends AudiobookEvent {
  final UpdateAudiobookParams params;

  const UpdateAudiobookEvent({required this.params});

  @override
  List<Object?> get props => [params];
}

/// Event to delete an audiobook
class DeleteAudiobookEvent extends AudiobookEvent {
  final String id;

  const DeleteAudiobookEvent({required this.id});

  @override
  List<Object?> get props => [id];
}

/// Event to toggle favorite status
class ToggleFavoriteEvent extends AudiobookEvent {
  final String id;

  const ToggleFavoriteEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// Event to rate an audiobook
class RateAudiobookEvent extends AudiobookEvent {
  final String id;
  final double rating;

  const RateAudiobookEvent(this.id, this.rating);

  @override
  List<Object?> get props => [id, rating];
}

/// Event to search audiobooks
class SearchAudiobooksEvent extends AudiobookEvent {
  final String query;
  final int? limit;
  final int? offset;
  final Map<String, dynamic>? filters;

  const SearchAudiobooksEvent({
    required this.query,
    this.limit,
    this.offset,
    this.filters,
  });

  @override
  List<Object?> get props => [query, limit, offset, filters];
}

/// Event to get recommendations
class GetRecommendationsEvent extends AudiobookEvent {
  final String userId;
  final int? limit;
  final String? basedOn;

  const GetRecommendationsEvent({
    required this.userId,
    this.limit,
    this.basedOn,
  });

  @override
  List<Object?> get props => [userId, limit, basedOn];
}

/// States for the audiobook bloc
abstract class AudiobookState extends Equatable {
  const AudiobookState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AudiobookInitialState extends AudiobookState {}

/// Loading state
class AudiobookLoadingState extends AudiobookState {}

/// Loaded state
class AudiobookLoadedState extends AudiobookState {
  final List<Audiobook> audiobooks;

  const AudiobookLoadedState({required this.audiobooks});

  @override
  List<Object?> get props => [audiobooks];
}

/// Single audiobook loaded state
class AudiobookDetailLoadedState extends AudiobookState {
  final Audiobook audiobook;

  const AudiobookDetailLoadedState({required this.audiobook});

  @override
  List<Object?> get props => [audiobook];
}

/// Error state
class AudiobookErrorState extends AudiobookState {
  final String message;

  const AudiobookErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Success state for operations
class AudiobookSuccessState extends AudiobookState {
  final String message;

  const AudiobookSuccessState({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Bloc for managing audiobook state
class AudiobookBloc extends Bloc<AudiobookEvent, AudiobookState> {
  final GetAudiobooksUseCase _getAudiobooksUseCase;
  final GetAudiobookUseCase _getAudiobookUseCase;
  final CreateAudiobookUseCase _createAudiobookUseCase;
  final UpdateAudiobookUseCase _updateAudiobookUseCase;
  final DeleteAudiobookUseCase _deleteAudiobookUseCase;
  final ToggleFavoriteUseCase _toggleFavoriteUseCase;
  final RateAudiobookUseCase _rateAudiobookUseCase;
  final SearchAudiobooksUseCase _searchAudiobooksUseCase;
  final GetRecommendationsUseCase _getRecommendationsUseCase;

  AudiobookBloc({
    required GetAudiobooksUseCase getAudiobooksUseCase,
    required GetAudiobookUseCase getAudiobookUseCase,
    required CreateAudiobookUseCase createAudiobookUseCase,
    required UpdateAudiobookUseCase updateAudiobookUseCase,
    required DeleteAudiobookUseCase deleteAudiobookUseCase,
    required ToggleFavoriteUseCase toggleFavoriteUseCase,
    required RateAudiobookUseCase rateAudiobookUseCase,
    required SearchAudiobooksUseCase searchAudiobooksUseCase,
    required GetRecommendationsUseCase getRecommendationsUseCase,
  }) : _getAudiobooksUseCase = getAudiobooksUseCase,
       _getAudiobookUseCase = getAudiobookUseCase,
       _createAudiobookUseCase = createAudiobookUseCase,
       _updateAudiobookUseCase = updateAudiobookUseCase,
       _deleteAudiobookUseCase = deleteAudiobookUseCase,
       _toggleFavoriteUseCase = toggleFavoriteUseCase,
       _rateAudiobookUseCase = rateAudiobookUseCase,
       _searchAudiobooksUseCase = searchAudiobooksUseCase,
       _getRecommendationsUseCase = getRecommendationsUseCase,
       super(AudiobookInitialState()) {
    on<LoadAudiobooksEvent>(_onLoadAudiobooks);
    on<LoadAudiobookEvent>(_onLoadAudiobook);
    on<CreateAudiobookEvent>(_onCreateAudiobook);
    on<UpdateAudiobookEvent>(_onUpdateAudiobook);
    on<DeleteAudiobookEvent>(_onDeleteAudiobook);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<RateAudiobookEvent>(_onRateAudiobook);
    on<SearchAudiobooksEvent>(_onSearchAudiobooks);
    on<GetRecommendationsEvent>(_onGetRecommendations);
  }

  Future<void> _onLoadAudiobooks(
    LoadAudiobooksEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    try {
      final result = await _getAudiobooksUseCase.call(GetAudiobooksParams(
        limit: event.limit,
        offset: event.offset,
        searchQuery: event.searchQuery,
        genre: event.genre,
        author: event.author,
        narrator: event.narrator,
        isCompleted: event.isCompleted,
        isFavorite: event.isFavorite,
        sortBy: event.sortBy,
        sortOrder: event.sortOrder,
      ));

      if (result.isSuccess) {
        emit(AudiobookLoadedState(audiobooks: result.data!));
      } else {
        emit(AudiobookErrorState(message: result.failureMessage!));
      }
    } catch (e) {
      emit(AudiobookErrorState(message: 'Failed to get audiobooks: $e'));
    }
  }

  Future<void> _onLoadAudiobook(
    LoadAudiobookEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    final result = await _getAudiobookUseCase.call(GetAudiobookParams(id: event.id));

    if (result.isSuccess) {
      emit(AudiobookDetailLoadedState(audiobook: result.data!));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onCreateAudiobook(
    CreateAudiobookEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    final result = await _createAudiobookUseCase.call(event.params);

    if (result.isSuccess) {
      emit(AudiobookSuccessState(message: 'Audiobook created successfully'));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onUpdateAudiobook(
    UpdateAudiobookEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    final result = await _updateAudiobookUseCase.call(event.params);

    if (result.isSuccess) {
      emit(AudiobookSuccessState(message: 'Audiobook updated successfully'));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onDeleteAudiobook(
    DeleteAudiobookEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    final result = await _deleteAudiobookUseCase.call(DeleteAudiobookParams(id: event.id));

    if (result.isSuccess) {
      emit(AudiobookSuccessState(message: 'Audiobook deleted successfully'));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    final result = await _toggleFavoriteUseCase.call(ToggleFavoriteParams(id: event.id));

    if (result.isSuccess) {
      emit(AudiobookSuccessState(message: 'Favorite status updated'));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onRateAudiobook(
    RateAudiobookEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    final result = await _rateAudiobookUseCase.call(RateAudiobookParams(
      id: event.id,
      rating: event.rating,
    ));

    if (result.isSuccess) {
      emit(AudiobookSuccessState(message: 'Rating updated'));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onSearchAudiobooks(
    SearchAudiobooksEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    final result = await _searchAudiobooksUseCase.call(SearchAudiobooksParams(
      query: event.query,
      limit: event.limit,
      offset: event.offset,
      filters: event.filters,
    ));

    if (result.isSuccess) {
      emit(AudiobookLoadedState(audiobooks: result.data!));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }

  Future<void> _onGetRecommendations(
    GetRecommendationsEvent event,
    Emitter<AudiobookState> emit,
  ) async {
    emit(AudiobookLoadingState());

    final result = await _getRecommendationsUseCase.call(GetRecommendationsParams(
      userId: event.userId,
      limit: event.limit,
      basedOn: event.basedOn,
    ));

    if (result.isSuccess) {
      emit(AudiobookLoadedState(audiobooks: result.data!));
    } else {
      emit(AudiobookErrorState(message: result.failureMessage!));
    }
  }
}
