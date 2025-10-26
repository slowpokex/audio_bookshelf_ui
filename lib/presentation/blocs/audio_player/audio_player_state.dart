import 'package:equatable/equatable.dart';
import '../../../domain/entities/audiobook.dart';
import 'audio_player_event.dart';

/// Audio player state
class AudioPlayerState extends Equatable {
  final Audiobook? currentAudiobook;
  final Duration currentPosition;
  final Duration totalDuration;
  final AudioPlaybackState playerState;
  final double playbackSpeed;
  final bool isInitialized;
  final String? error;
  final bool isLoading;

  const AudioPlayerState({
    this.currentAudiobook,
    this.currentPosition = Duration.zero,
    this.totalDuration = Duration.zero,
    this.playerState = AudioPlaybackState.stopped,
    this.playbackSpeed = 1.0,
    this.isInitialized = false,
    this.error,
    this.isLoading = false,
  });

  /// Create initial state
  const AudioPlayerState.initial() : this();

  /// Create loading state
  const AudioPlayerState.loading() : this(isLoading: true);

  /// Create error state
  const AudioPlayerState.error(String error) : this(error: error);

  /// Copy with new values
  AudioPlayerState copyWith({
    Audiobook? currentAudiobook,
    Duration? currentPosition,
    Duration? totalDuration,
    AudioPlaybackState? playerState,
    double? playbackSpeed,
    bool? isInitialized,
    String? error,
    bool? isLoading,
  }) {
    return AudioPlayerState(
      currentAudiobook: currentAudiobook ?? this.currentAudiobook,
      currentPosition: currentPosition ?? this.currentPosition,
      totalDuration: totalDuration ?? this.totalDuration,
      playerState: playerState ?? this.playerState,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Get progress percentage (0.0 to 1.0)
  double get progressPercentage {
    if (totalDuration.inMilliseconds == 0) return 0.0;
    return currentPosition.inMilliseconds / totalDuration.inMilliseconds;
  }

  /// Get remaining time
  Duration get remainingTime {
    return totalDuration - currentPosition;
  }

  /// Check if currently playing
  bool get isPlaying => playerState == AudioPlaybackState.playing;

  /// Check if paused
  bool get isPaused => playerState == AudioPlaybackState.paused;

  /// Check if stopped
  bool get isStopped => playerState == AudioPlaybackState.stopped;

  /// Check if loading
  bool get isLoadingState => playerState == AudioPlaybackState.loading || playerState == AudioPlaybackState.buffering;

  /// Check if completed
  bool get isCompleted => playerState == AudioPlaybackState.completed;

  /// Check if has error
  bool get hasError => error != null;

  /// Check if has current audiobook
  bool get hasCurrentAudiobook => currentAudiobook != null;

  /// Get formatted current position
  String get formattedCurrentPosition {
    return _formatDuration(currentPosition);
  }

  /// Get formatted total duration
  String get formattedTotalDuration {
    return _formatDuration(totalDuration);
  }

  /// Format duration to show hours when longer than 60 minutes
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  /// Get formatted remaining time
  String get formattedRemainingTime {
    return '-${_formatDuration(remainingTime)}';
  }

  /// Get formatted playback speed
  String get formattedPlaybackSpeed {
    return '${playbackSpeed}x';
  }

  @override
  List<Object?> get props => [
        currentAudiobook,
        currentPosition,
        totalDuration,
        playerState,
        playbackSpeed,
        isInitialized,
        error,
        isLoading,
      ];
}
