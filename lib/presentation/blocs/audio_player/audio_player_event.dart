import 'package:equatable/equatable.dart';
import '../../../domain/entities/audiobook.dart';

/// Base class for all audio player events
abstract class AudioPlayerEvent extends Equatable {
  const AudioPlayerEvent();

  @override
  List<Object?> get props => [];
}

/// Event to play an audiobook
class PlayAudiobookEvent extends AudioPlayerEvent {
  final Audiobook audiobook;

  const PlayAudiobookEvent(this.audiobook);

  @override
  List<Object?> get props => [audiobook];
}

/// Event to resume playback
class ResumePlaybackEvent extends AudioPlayerEvent {
  const ResumePlaybackEvent();
}

/// Event to pause playback
class PausePlaybackEvent extends AudioPlayerEvent {
  const PausePlaybackEvent();
}

/// Event to stop playback
class StopPlaybackEvent extends AudioPlayerEvent {
  const StopPlaybackEvent();
}

/// Event to seek to a specific position
class SeekEvent extends AudioPlayerEvent {
  final Duration position;

  const SeekEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to set playback speed
class SetPlaybackSpeedEvent extends AudioPlayerEvent {
  final double speed;

  const SetPlaybackSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// Event to skip forward
class SkipForwardEvent extends AudioPlayerEvent {
  final Duration duration;

  const SkipForwardEvent({this.duration = const Duration(seconds: 30)});

  @override
  List<Object?> get props => [duration];
}

/// Event to skip backward
class SkipBackwardEvent extends AudioPlayerEvent {
  final Duration duration;

  const SkipBackwardEvent({this.duration = const Duration(seconds: 30)});

  @override
  List<Object?> get props => [duration];
}

/// Event to skip forward 10 seconds
class SkipForward10Event extends AudioPlayerEvent {
  const SkipForward10Event();
}

/// Event to skip backward 10 seconds
class SkipBackward10Event extends AudioPlayerEvent {
  const SkipBackward10Event();
}

/// Event to toggle play/pause
class TogglePlayPauseEvent extends AudioPlayerEvent {
  const TogglePlayPauseEvent();
}

/// Event to update current position (internal)
class UpdatePositionEvent extends AudioPlayerEvent {
  final Duration position;

  const UpdatePositionEvent(this.position);

  @override
  List<Object?> get props => [position];
}

/// Event to update duration (internal)
class UpdateDurationEvent extends AudioPlayerEvent {
  final Duration duration;

  const UpdateDurationEvent(this.duration);

  @override
  List<Object?> get props => [duration];
}

/// Event to update player state (internal)
class UpdatePlayerStateEvent extends AudioPlayerEvent {
  final AudioPlaybackState state;

  const UpdatePlayerStateEvent(this.state);

  @override
  List<Object?> get props => [state];
}

/// Event to handle player error
class PlayerErrorEvent extends AudioPlayerEvent {
  final String error;

  const PlayerErrorEvent(this.error);

  @override
  List<Object?> get props => [error];
}

/// Event to clear error
class ClearErrorEvent extends AudioPlayerEvent {
  const ClearErrorEvent();
}

/// Event to initialize audio player
class InitializeAudioPlayerEvent extends AudioPlayerEvent {
  const InitializeAudioPlayerEvent();
}

/// Event to dispose audio player
class DisposeAudioPlayerEvent extends AudioPlayerEvent {
  const DisposeAudioPlayerEvent();
}

class UpdateCurrentAudiobookEvent extends AudioPlayerEvent {
  final Audiobook? audiobook;
  
  const UpdateCurrentAudiobookEvent(this.audiobook);
  
  @override
  List<Object?> get props => [audiobook];
}

/// Event to update playback speed (internal)
class UpdatePlaybackSpeedEvent extends AudioPlayerEvent {
  final double speed;

  const UpdatePlaybackSpeedEvent(this.speed);

  @override
  List<Object?> get props => [speed];
}

/// Player state enum
enum AudioPlaybackState {
  stopped,
  playing,
  paused,
  loading,
  buffering,
  completed,
  error,
}
