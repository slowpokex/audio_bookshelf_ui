import 'dart:async';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import '../utils/app_logger.dart';
import '../errors/exceptions.dart';
import '../../domain/entities/audiobook.dart';
import 'background_audio_service.dart';

/// Audio player service for handling audiobook playback
class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  late AudioPlayer _audioPlayer;
  late AudioSession _audioSession;
  late BackgroundAudioService _backgroundAudioService;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<SequenceState?>? _sequenceStateSubscription;

  // Current playing audiobook
  Audiobook? _currentAudiobook;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  PlayerState _playerState = PlayerState(false, ProcessingState.idle);
  double _playbackSpeed = 1.0;
  bool _isInitialized = false;

  // Stream controllers for state updates
  final StreamController<Audiobook?> _currentAudiobookController = StreamController.broadcast();
  final StreamController<Duration> _positionController = StreamController.broadcast();
  final StreamController<Duration> _durationController = StreamController.broadcast();
  final StreamController<PlayerState> _playerStateController = StreamController.broadcast();
  final StreamController<double> _playbackSpeedController = StreamController.broadcast();
  final StreamController<String?> _errorController = StreamController.broadcast();

  // Getters
  Audiobook? get currentAudiobook => _currentAudiobook;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  PlayerState get playerState => _playerState;
  double get playbackSpeed => _playbackSpeed;
  bool get isInitialized => _isInitialized;
  bool get isPlaying => _playerState.playing;
  bool get isPaused => !_playerState.playing && _playerState.processingState == ProcessingState.ready;
  bool get isStopped => _playerState.processingState == ProcessingState.idle;

  // Streams
  Stream<Audiobook?> get currentAudiobookStream => _currentAudiobookController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<double> get playbackSpeedStream => _playbackSpeedController.stream;
  Stream<String?> get errorStream => _errorController.stream;

  /// Initialize the audio player service
  Future<void> initialize() async {
    if (_isInitialized) {
      AppLogger.logDebug('AudioPlayerService already initialized');
      return;
    }

    try {
      AppLogger.logAudioOperation('initialize', 'audio_player_service');

      // Initialize background audio service with error handling
      try {
        _backgroundAudioService = BackgroundAudioService.instance;
        await _backgroundAudioService.initialize();
      } catch (e) {
        AppLogger.logDebug('Background audio service initialization failed, continuing without it', data: {
          'error': e.toString(),
        });
        // Continue without background service if it fails
      }

      // Initialize audio session
      _audioSession = await AudioSession.instance;
      await _audioSession.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));

      // Initialize audio player
      _audioPlayer = AudioPlayer();

      // Set up listeners
      _setupListeners();

      _isInitialized = true;
      AppLogger.logAudioOperation('initialize', 'audio_player_service', duration: 0);
    } catch (e) {
      AppLogger.logAudioError('initialize', 'audio_player_service', e.toString(), StackTrace.current);
      // Don't throw to prevent app crash, just log the error and mark as not initialized
      _isInitialized = false;
      AppLogger.logDebug('AudioPlayerService initialization failed, audio features may not work', data: {
        'error': e.toString(),
      });
    }
  }

  /// Set up audio player listeners
  void _setupListeners() {
    // Position updates with throttling
    _positionSubscription = _audioPlayer.positionStream.listen(
      (position) {
        _currentPosition = position;
        _positionController.add(position);
        _updateProgress();
        
        // Update background service with position (throttled)
        _updateBackgroundServicePositionThrottled();
      },
      onError: (error) {
        AppLogger.logAudioError('position_stream', 'audio_player_service', error.toString(), StackTrace.current);
        _errorController.add(error);
      },
    );

    // Duration updates
    _durationSubscription = _audioPlayer.durationStream.listen(
      (duration) {
        _totalDuration = duration ?? Duration.zero;
        _durationController.add(_totalDuration);
      },
      onError: (error) {
        AppLogger.logAudioError('duration_stream', 'audio_player_service', error.toString(), StackTrace.current);
        _errorController.add(error);
      },
    );

    // Player state updates
    _playerStateSubscription = _audioPlayer.playerStateStream.listen(
      (state) {
        _playerState = state;
        _playerStateController.add(state);
        _handlePlayerStateChange(state);
      },
      onError: (error) {
        AppLogger.logAudioError('player_state_stream', 'audio_player_service', error.toString(), StackTrace.current);
        _errorController.add(error);
      },
    );

    // Sequence state updates (for playlists)
    _sequenceStateSubscription = _audioPlayer.sequenceStateStream.listen(
      (sequenceState) {
        _handleSequenceStateChange(sequenceState);
      },
      onError: (error) {
        AppLogger.logAudioError('sequence_state_stream', 'audio_player_service', error.toString(), StackTrace.current);
        _errorController.add(error);
      },
    );
  }

  /// Handle player state changes
  void _handlePlayerStateChange(PlayerState state) {
    AppLogger.logDebug('Player state changed: $state');
    
    if (state.playing) {
      _onPlaybackStarted();
    } else if (state.processingState == ProcessingState.ready) {
      _onPlaybackPaused();
    } else if (state.processingState == ProcessingState.idle) {
      _onPlaybackStopped();
    } else if (state.processingState == ProcessingState.completed) {
      _onPlaybackCompleted();
    } else if (state.processingState == ProcessingState.loading) {
      AppLogger.logDebug('Audio loading...');
    } else if (state.processingState == ProcessingState.buffering) {
      AppLogger.logDebug('Audio buffering...');
    }
  }

  /// Handle sequence state changes
  void _handleSequenceStateChange(SequenceState sequenceState) {
    // Handle playlist or chapter changes
    AppLogger.logDebug('Sequence state changed: ${sequenceState.currentIndex}');
  }

  /// Play an audiobook
  Future<void> playAudiobook(Audiobook audiobook) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      AppLogger.logAudioOperation('play_audiobook', 'audio_player_service', extra: {'audiobook_id': audiobook.id});

      if (audiobook.audioFilePath == null || audiobook.audioFilePath!.isEmpty) {
        throw AudioPlaybackException(
          message: 'Audiobook has no audio file path',
          timestamp: DateTime.now(),
        );
      }

      // Stop current playback if any
      if (_currentAudiobook != null) {
        await stop();
      }

      // Set current audiobook
      _currentAudiobook = audiobook;
      _currentAudiobookController.add(audiobook);

      // Create audio source with error handling
      AudioSource audioSource;
      try {
        if (audiobook.isLocal && audiobook.localPath != null) {
          audioSource = AudioSource.uri(Uri.file(audiobook.localPath!));
        } else {
          audioSource = AudioSource.uri(Uri.parse(audiobook.audioFilePath!));
        }

        // Set audio source
        await _audioPlayer.setAudioSource(audioSource);
      } catch (e) {
        AppLogger.logError('Failed to set audio source', StackTrace.current, context: {
          'audiobook_id': audiobook.id,
          'audio_file_path': audiobook.audioFilePath,
          'is_local': audiobook.isLocal,
          'local_path': audiobook.localPath,
        });
        throw AudioPlaybackException(
          message: 'Failed to load audio file: ${e.toString()}',
          timestamp: DateTime.now(),
          stackTrace: StackTrace.current,
        );
      }

      // Resume from last position if available
      if (audiobook.currentPosition != null && audiobook.currentPosition!.inMilliseconds > 0) {
        await seek(audiobook.currentPosition!);
      }

      // Start background service with error handling
      try {
        await _backgroundAudioService.startService();

        // Update metadata for notification
        await _backgroundAudioService.updateMetadata(
          title: audiobook.title,
          artist: audiobook.displayAuthor,
          album: audiobook.series ?? 'Audiobook',
          duration: audiobook.duration ?? Duration.zero,
        );
      } catch (e) {
        AppLogger.logDebug('Background service operations failed, continuing without notification', data: {
          'error': e.toString(),
        });
        // Continue without background service if it fails
      }

      // Start playback
      await _audioPlayer.play();

      AppLogger.logAudioOperation('play_audiobook', 'audio_player_service', duration: 0);
    } catch (e) {
      AppLogger.logAudioError('play_audiobook', 'audio_player_service', e.toString(), StackTrace.current);
      throw AudioPlaybackException(
        message: 'Failed to play audiobook: $e',
        timestamp: DateTime.now(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Resume playback
  Future<void> play() async {
    if (!_isInitialized) return;

    try {
      AppLogger.logAudioOperation('play', 'audio_player_service');
      await _audioPlayer.play();
    } catch (e) {
      AppLogger.logAudioError('play', 'audio_player_service', e.toString(), StackTrace.current);
      throw AudioPlaybackException(
        message: 'Failed to resume playback: $e',
        timestamp: DateTime.now(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (!_isInitialized) return;

    try {
      AppLogger.logAudioOperation('pause', 'audio_player_service');
      await _audioPlayer.pause();
    } catch (e) {
      AppLogger.logAudioError('pause', 'audio_player_service', e.toString(), StackTrace.current);
      throw AudioPlaybackException(
        message: 'Failed to pause playback: $e',
        timestamp: DateTime.now(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Stop playback
  Future<void> stop() async {
    if (!_isInitialized) return;

    try {
      AppLogger.logAudioOperation('stop', 'audio_player_service');
      await _audioPlayer.stop();
      
      // Stop background service
      await _backgroundAudioService.stopService();
      
      _currentAudiobook = null;
      _currentAudiobookController.add(null);
    } catch (e) {
      AppLogger.logAudioError('stop', 'audio_player_service', e.toString(), StackTrace.current);
      throw AudioPlaybackException(
        message: 'Failed to stop playback: $e',
        timestamp: DateTime.now(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    if (!_isInitialized) return;

    try {
      AppLogger.logAudioOperation('seek', 'audio_player_service', extra: {'position_ms': position.inMilliseconds});
      await _audioPlayer.seek(position);
    } catch (e) {
      AppLogger.logAudioError('seek', 'audio_player_service', e.toString(), StackTrace.current);
      throw AudioPlaybackException(
        message: 'Failed to seek to position: $e',
        timestamp: DateTime.now(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    if (!_isInitialized) return;

    try {
      // Clamp speed between 0.25x and 3.0x
      speed = speed.clamp(0.25, 3.0);
      
      AppLogger.logAudioOperation('set_playback_speed', 'audio_player_service', extra: {'speed': speed});
      await _audioPlayer.setSpeed(speed);
      _playbackSpeed = speed;
      _playbackSpeedController.add(speed);
    } catch (e) {
      AppLogger.logAudioError('set_playback_speed', 'audio_player_service', e.toString(), StackTrace.current);
      throw AudioPlaybackException(
        message: 'Failed to set playback speed: $e',
        timestamp: DateTime.now(),
        stackTrace: StackTrace.current,
      );
    }
  }

  /// Skip forward by a specified duration
  Future<void> skipForward({Duration duration = const Duration(seconds: 30)}) async {
    final newPosition = _currentPosition + duration;
    final maxPosition = _totalDuration;
    
    if (newPosition < maxPosition) {
      await seek(newPosition);
    } else {
      await seek(maxPosition);
    }
  }

  /// Skip backward by a specified duration
  Future<void> skipBackward({Duration duration = const Duration(seconds: 30)}) async {
    final newPosition = _currentPosition - duration;
    const minPosition = Duration.zero;
    
    if (newPosition > minPosition) {
      await seek(newPosition);
    } else {
      await seek(minPosition);
    }
  }

  /// Update progress (called periodically)
  void _updateProgress() {
    if (_currentAudiobook != null) {
      // This would typically update the database with current progress
      // For now, we'll just log it
      AppLogger.logDebug('Progress update: ${_currentPosition.inSeconds}s / ${_totalDuration.inSeconds}s');
    }
  }


  /// Update background service with position only (for frequent updates)
  void _updateBackgroundServicePosition() {
    if (_currentAudiobook != null) {
      _backgroundAudioService.updatePosition(
        position: _currentPosition,
        duration: _totalDuration,
      );
    }
  }

  // Throttling for background service updates
  DateTime? _lastBackgroundUpdate;
  static const Duration _backgroundUpdateInterval = Duration(milliseconds: 1000);

  /// Update background service with position (throttled)
  void _updateBackgroundServicePositionThrottled() {
    final now = DateTime.now();
    if (_lastBackgroundUpdate == null || 
        now.difference(_lastBackgroundUpdate!) >= _backgroundUpdateInterval) {
      _updateBackgroundServicePosition();
      _lastBackgroundUpdate = now;
    }
  }

  /// Handle playback started
  void _onPlaybackStarted() {
    AppLogger.logAudioOperation('playback_started', 'audio_player_service', extra: {
      'audiobook_id': _currentAudiobook?.id,
      'position': _currentPosition.inSeconds,
    });
  }

  /// Handle playback paused
  void _onPlaybackPaused() {
    AppLogger.logAudioOperation('playback_paused', 'audio_player_service', extra: {
      'audiobook_id': _currentAudiobook?.id,
      'position': _currentPosition.inSeconds,
    });
  }

  /// Handle playback stopped
  void _onPlaybackStopped() {
    AppLogger.logAudioOperation('playback_stopped', 'audio_player_service', extra: {
      'audiobook_id': _currentAudiobook?.id,
    });
  }

  /// Handle playback completed
  void _onPlaybackCompleted() {
    AppLogger.logAudioOperation('playback_completed', 'audio_player_service', extra: {
      'audiobook_id': _currentAudiobook?.id,
    });
    
    // Reset current audiobook
    _currentAudiobook = null;
    _currentAudiobookController.add(null);
  }

  /// Get current progress as percentage (0.0 to 1.0)
  double get progressPercentage {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  /// Get remaining time
  Duration get remainingTime {
    return _totalDuration - _currentPosition;
  }

  /// Check if audiobook is currently playing
  bool isAudiobookPlaying(String audiobookId) {
    return _currentAudiobook?.id == audiobookId && isPlaying;
  }

  /// Dispose of resources
  Future<void> dispose() async {
    AppLogger.logDebug('Disposing AudioPlayerService');
    
    await _positionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _sequenceStateSubscription?.cancel();
    
    await _audioPlayer.dispose();
    
    // Dispose background service
    await _backgroundAudioService.dispose();
    
    await _currentAudiobookController.close();
    await _positionController.close();
    await _durationController.close();
    await _playerStateController.close();
    await _playbackSpeedController.close();
    await _errorController.close();
    
    _isInitialized = false;
  }
}
