import 'dart:async';
import '../utils/app_logger.dart';
import '../../presentation/blocs/audio_player/audio_player_bloc.dart';
import '../../presentation/blocs/audio_player/audio_player_event.dart';

/// Sleep timer service for automatic playback stopping
class SleepTimerService {
  static final SleepTimerService _instance = SleepTimerService._internal();
  factory SleepTimerService() => _instance;
  SleepTimerService._internal();

  Timer? _sleepTimer;
  Duration? _remainingTime;
  DateTime? _timerStartTime;
  AudioPlayerBloc? _audioPlayerBloc;
  bool _isActive = false;

  /// Initialize the sleep timer service
  void initialize(AudioPlayerBloc audioPlayerBloc) {
    _audioPlayerBloc = audioPlayerBloc;
    AppLogger.logDebug('SleepTimerService initialized');
  }

  /// Start sleep timer
  void startTimer(Duration duration) {
    if (_audioPlayerBloc == null) {
      AppLogger.logError('SleepTimerService not initialized', StackTrace.current);
      return;
    }

    // Cancel existing timer
    _sleepTimer?.cancel();

    _remainingTime = duration;
    _timerStartTime = DateTime.now();
    _isActive = true;

    _sleepTimer = Timer(duration, () {
      _onTimerComplete();
    });

    AppLogger.logDebug('Sleep timer started for ${duration.inMinutes} minutes');
  }

  /// Stop sleep timer
  void stopTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _remainingTime = null;
    _timerStartTime = null;
    _isActive = false;
    AppLogger.logDebug('Sleep timer stopped');
  }

  /// Pause sleep timer
  void pauseTimer() {
    if (_sleepTimer != null && _remainingTime != null && _timerStartTime != null) {
      _sleepTimer?.cancel();
      
      // Calculate actual remaining time based on elapsed time
      final elapsedTime = DateTime.now().difference(_timerStartTime!);
      _remainingTime = _remainingTime! - elapsedTime;
      
      // Ensure remaining time is not negative
      if (_remainingTime!.isNegative) {
        _remainingTime = Duration.zero;
      }
      
      _isActive = false;
      _timerStartTime = null;
      AppLogger.logDebug('Sleep timer paused with ${_remainingTime!.inSeconds}s remaining');
    }
  }

  /// Resume sleep timer
  void resumeTimer() {
    if (_remainingTime != null && _audioPlayerBloc != null) {
      // Don't resume if no time is left
      if (_remainingTime!.inMilliseconds <= 0) {
        AppLogger.logDebug('Sleep timer has no remaining time, completing immediately');
        _onTimerComplete();
        return;
      }
      
      _timerStartTime = DateTime.now();
      _sleepTimer = Timer(_remainingTime!, () {
        _onTimerComplete();
      });
      _isActive = true;
      AppLogger.logDebug('Sleep timer resumed with ${_remainingTime!.inSeconds}s remaining');
    }
  }

  /// Get remaining time
  Duration? get remainingTime => _remainingTime;

  /// Check if timer is active
  bool get isActive => _isActive;

  /// Check if timer is paused
  bool get isPaused => _remainingTime != null && !_isActive;

  /// Get formatted remaining time
  String get formattedRemainingTime {
    if (_remainingTime == null) return '';
    
    final hours = _remainingTime!.inHours;
    final minutes = _remainingTime!.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }

  /// Handle timer completion
  void _onTimerComplete() {
    if (_audioPlayerBloc != null) {
      _audioPlayerBloc!.add(const PausePlaybackEvent());
      AppLogger.logDebug('Sleep timer completed - playback paused');
    }
    
    _isActive = false;
    _remainingTime = null;
    _timerStartTime = null;
  }

  /// Dispose of resources
  void dispose() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _remainingTime = null;
    _timerStartTime = null;
    _isActive = false;
    _audioPlayerBloc = null;
    AppLogger.logDebug('SleepTimerService disposed');
  }
}
