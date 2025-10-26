import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../core/services/audio_player_service.dart';
import '../../../core/utils/app_logger.dart';
import '../../../domain/entities/audiobook.dart';
import 'audio_player_event.dart';
import 'audio_player_state.dart';

/// Audio player bloc for managing audio playback state
class AudioPlayerBloc extends Bloc<AudioPlayerEvent, AudioPlayerState> {
  final AudioPlayerService _audioPlayerService;
  StreamSubscription<Audiobook?>? _currentAudiobookSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<double>? _playbackSpeedSubscription;
  StreamSubscription<String?>? _errorSubscription;

  // Performance optimization - removed debouncing for immediate updates

  AudioPlayerBloc({
    required AudioPlayerService audioPlayerService,
  })  : _audioPlayerService = audioPlayerService,
        super(const AudioPlayerState.initial()) {
    
    // Register event handlers
    on<InitializeAudioPlayerEvent>(_onInitializeAudioPlayer);
    on<DisposeAudioPlayerEvent>(_onDisposeAudioPlayer);
    on<PlayAudiobookEvent>(_onPlayAudiobook);
    on<ResumePlaybackEvent>(_onResumePlayback);
    on<PausePlaybackEvent>(_onPausePlayback);
    on<StopPlaybackEvent>(_onStopPlayback);
    on<SeekEvent>(_onSeek);
    on<SetPlaybackSpeedEvent>(_onSetPlaybackSpeed);
    on<SkipForwardEvent>(_onSkipForward);
    on<SkipBackwardEvent>(_onSkipBackward);
    on<SkipForward10Event>(_onSkipForward10);
    on<SkipBackward10Event>(_onSkipBackward10);
    on<TogglePlayPauseEvent>(_onTogglePlayPause);
    on<UpdatePositionEvent>(_onUpdatePosition);
    on<UpdateDurationEvent>(_onUpdateDuration);
    on<UpdatePlayerStateEvent>(_onUpdatePlayerState);
    on<PlayerErrorEvent>(_onPlayerError);
    on<ClearErrorEvent>(_onClearError);
    on<UpdateCurrentAudiobookEvent>(_onUpdateCurrentAudiobook);

    // Initialize the audio player service
    add(const InitializeAudioPlayerEvent());
  }

  /// Initialize audio player
  Future<void> _onInitializeAudioPlayer(
    InitializeAudioPlayerEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      
      await _audioPlayerService.initialize();
      
      // Set up stream subscriptions
      _setupStreamSubscriptions(emit);
      
      emit(state.copyWith(
        isInitialized: true,
        isLoading: false,
      ));
      
      AppLogger.logDebug('AudioPlayerBloc initialized');
    } catch (e) {
      AppLogger.logError('Failed to initialize AudioPlayerBloc', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(
        error: 'Failed to initialize audio player: ${e.toString()}',
        isLoading: false,
      ));
    }
  }

  /// Dispose audio player
  Future<void> _onDisposeAudioPlayer(
    DisposeAudioPlayerEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _currentAudiobookSubscription?.cancel();
      await _positionSubscription?.cancel();
      await _durationSubscription?.cancel();
      await _playerStateSubscription?.cancel();
      await _playbackSpeedSubscription?.cancel();
      await _errorSubscription?.cancel();
      
      await _audioPlayerService.dispose();
      
      emit(const AudioPlayerState.initial());
      
      AppLogger.logDebug('AudioPlayerBloc disposed');
    } catch (e) {
      AppLogger.logError('Failed to dispose AudioPlayerBloc', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Set up stream subscriptions
  void _setupStreamSubscriptions(Emitter<AudioPlayerState> emit) {
    // Current audiobook subscription
    _currentAudiobookSubscription = _audioPlayerService.currentAudiobookStream.listen(
      (audiobook) async {
        if (!isClosed) {
          add(UpdateCurrentAudiobookEvent(audiobook));
        }
      },
      onError: (error) async {
        if (!isClosed) {
          add(PlayerErrorEvent(error.toString()));
        }
      },
    );

    // Position subscription with immediate updates
    _positionSubscription = _audioPlayerService.positionStream.listen(
      (position) {
        if (!isClosed) {
          add(UpdatePositionEvent(position));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(PlayerErrorEvent(error.toString()));
        }
      },
    );

    // Duration subscription
    _durationSubscription = _audioPlayerService.durationStream.listen(
      (duration) {
        if (!isClosed) {
          add(UpdateDurationEvent(duration));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(PlayerErrorEvent(error.toString()));
        }
      },
    );

    // Player state subscription
    _playerStateSubscription = _audioPlayerService.playerStateStream.listen(
      (playerState) {
        // Convert just_audio PlayerState to AudioPlaybackState
        AudioPlaybackState audioPlaybackState;
        if (playerState.playing) {
          audioPlaybackState = AudioPlaybackState.playing;
        } else if (playerState.processingState == ProcessingState.ready) {
          audioPlaybackState = AudioPlaybackState.paused;
        } else if (playerState.processingState == ProcessingState.completed) {
          audioPlaybackState = AudioPlaybackState.completed;
        } else if (playerState.processingState == ProcessingState.loading || 
                   playerState.processingState == ProcessingState.buffering) {
          audioPlaybackState = AudioPlaybackState.loading;
        } else {
          audioPlaybackState = AudioPlaybackState.stopped;
        }
        if (!isClosed) {
          add(UpdatePlayerStateEvent(audioPlaybackState));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(PlayerErrorEvent(error.toString()));
        }
      },
    );

    // Playback speed subscription
    _playbackSpeedSubscription = _audioPlayerService.playbackSpeedStream.listen(
      (speed) {
        if (!isClosed) {
          emit(state.copyWith(playbackSpeed: speed));
        }
      },
      onError: (error) {
        if (!isClosed) {
          add(PlayerErrorEvent(error.toString()));
        }
      },
    );

    // Error subscription
    _errorSubscription = _audioPlayerService.errorStream.listen(
      (error) {
        if (!isClosed && error != null) {
          add(PlayerErrorEvent(error.toString()));
        }
      },
    );
  }


  /// Play audiobook
  Future<void> _onPlayAudiobook(
    PlayAudiobookEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (!isClosed) {
        emit(state.copyWith(isLoading: true, error: null));
      }
      
      await _audioPlayerService.playAudiobook(event.audiobook);
      
      if (!isClosed) {
        emit(state.copyWith(
          currentAudiobook: event.audiobook,
          isLoading: false,
        ));
      }
      
      AppLogger.logDebug('Playing audiobook: ${event.audiobook.title}');
    } catch (e) {
      AppLogger.logError('Failed to play audiobook', StackTrace.current, context: {'error': e.toString()});
      if (!isClosed) {
        emit(state.copyWith(
          error: 'Failed to play audiobook: ${e.toString()}',
          isLoading: false,
        ));
      }
    }
  }

  /// Resume playback
  Future<void> _onResumePlayback(
    ResumePlaybackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.play();
      AppLogger.logDebug('Resumed playback');
    } catch (e) {
      AppLogger.logError('Failed to resume playback', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to resume playback: ${e.toString()}'));
    }
  }

  /// Pause playback
  Future<void> _onPausePlayback(
    PausePlaybackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.pause();
      AppLogger.logDebug('Paused playback');
    } catch (e) {
      AppLogger.logError('Failed to pause playback', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to pause playback: ${e.toString()}'));
    }
  }

  /// Stop playback
  Future<void> _onStopPlayback(
    StopPlaybackEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.stop();
      emit(state.copyWith(
        currentAudiobook: null,
        currentPosition: Duration.zero,
      ));
      AppLogger.logDebug('Stopped playback');
    } catch (e) {
      AppLogger.logError('Failed to stop playback', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to stop playback: ${e.toString()}'));
    }
  }

  /// Seek to position
  Future<void> _onSeek(
    SeekEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.seek(event.position);
      AppLogger.logDebug('Seeked to position: ${event.position.inSeconds}s');
    } catch (e) {
      AppLogger.logError('Failed to seek', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to seek: ${e.toString()}'));
    }
  }

  /// Set playback speed
  Future<void> _onSetPlaybackSpeed(
    SetPlaybackSpeedEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.setPlaybackSpeed(event.speed);
      emit(state.copyWith(playbackSpeed: event.speed));
      AppLogger.logDebug('Set playback speed to: ${event.speed}x');
    } catch (e) {
      AppLogger.logError('Failed to set playback speed', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to set playback speed: ${e.toString()}'));
    }
  }

  /// Skip forward
  Future<void> _onSkipForward(
    SkipForwardEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.skipForward(duration: event.duration);
      AppLogger.logDebug('Skipped forward by: ${event.duration.inSeconds}s');
    } catch (e) {
      AppLogger.logError('Failed to skip forward', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to skip forward: ${e.toString()}'));
    }
  }

  /// Skip backward
  Future<void> _onSkipBackward(
    SkipBackwardEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.skipBackward(duration: event.duration);
      AppLogger.logDebug('Skipped backward by: ${event.duration.inSeconds}s');
    } catch (e) {
      AppLogger.logError('Failed to skip backward', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to skip backward: ${e.toString()}'));
    }
  }

  /// Skip forward 10 seconds
  Future<void> _onSkipForward10(
    SkipForward10Event event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.skipForward(duration: const Duration(seconds: 10));
      AppLogger.logDebug('Skipped forward by 10 seconds');
    } catch (e) {
      AppLogger.logError('Failed to skip forward 10 seconds', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to skip forward: ${e.toString()}'));
    }
  }

  /// Skip backward 10 seconds
  Future<void> _onSkipBackward10(
    SkipBackward10Event event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      await _audioPlayerService.skipBackward(duration: const Duration(seconds: 10));
      AppLogger.logDebug('Skipped backward by 10 seconds');
    } catch (e) {
      AppLogger.logError('Failed to skip backward 10 seconds', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to skip backward: ${e.toString()}'));
    }
  }

  /// Toggle play/pause
  Future<void> _onTogglePlayPause(
    TogglePlayPauseEvent event,
    Emitter<AudioPlayerState> emit,
  ) async {
    try {
      if (state.isPlaying) {
        add(const PausePlaybackEvent());
      } else {
        add(const ResumePlaybackEvent());
      }
    } catch (e) {
      AppLogger.logError('Failed to toggle play/pause', StackTrace.current, context: {'error': e.toString()});
      emit(state.copyWith(error: 'Failed to toggle play/pause: ${e.toString()}'));
    }
  }

  /// Update position
  void _onUpdatePosition(
    UpdatePositionEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(currentPosition: event.position));
  }

  /// Update duration
  void _onUpdateDuration(
    UpdateDurationEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(totalDuration: event.duration));
  }

  /// Update player state
  void _onUpdatePlayerState(
    UpdatePlayerStateEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(playerState: event.state));
  }

  /// Handle player error
  void _onPlayerError(
    PlayerErrorEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(error: event.error));
  }

  /// Clear error
  void _onClearError(
    ClearErrorEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(error: null));
  }

  /// Update current audiobook
  void _onUpdateCurrentAudiobook(
    UpdateCurrentAudiobookEvent event,
    Emitter<AudioPlayerState> emit,
  ) {
    emit(state.copyWith(currentAudiobook: event.audiobook));
  }

  @override
  Future<void> close() async {
    await _currentAudiobookSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _playbackSpeedSubscription?.cancel();
    await _errorSubscription?.cancel();
    
    await _audioPlayerService.dispose();
    
    return super.close();
  }
}
