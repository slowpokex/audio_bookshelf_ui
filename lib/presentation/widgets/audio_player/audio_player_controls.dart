import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/audio_player/audio_player_bloc.dart';
import '../../../presentation/blocs/audio_player/audio_player_event.dart';
import '../../../presentation/blocs/audio_player/audio_player_state.dart';

/// Audio player controls widget with comprehensive controls
class AudioPlayerControls extends StatefulWidget {
  const AudioPlayerControls({super.key});

  @override
  State<AudioPlayerControls> createState() => _AudioPlayerControlsState();
}

class _AudioPlayerControlsState extends State<AudioPlayerControls> {
  bool _isDragging = false;
  double _dragValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (!state.hasCurrentAudiobook) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Progress bar with enhanced features
              _buildProgressBar(context, state),
              const SizedBox(height: 16),
              
              // Main controls with accessibility
              _buildMainControls(context, state),
              const SizedBox(height: 16),
              
              // Secondary controls
              _buildSecondaryControls(context, state),
              const SizedBox(height: 8),
              
              // Chapter navigation (if available)
              _buildChapterNavigation(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Build enhanced progress bar with better interaction
  Widget _buildProgressBar(BuildContext context, AudioPlayerState state) {
    // Ensure we have valid duration
    if (state.totalDuration.inMilliseconds == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            const Text(
              'Loading...',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${state.totalDuration}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
            Text(
              'Position: ${state.currentPosition}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    final currentValue = _isDragging ? _dragValue : state.progressPercentage;
    final currentPosition = _isDragging 
        ? Duration(milliseconds: (_dragValue * state.totalDuration.inMilliseconds).round())
        : state.currentPosition;
    final remainingTime = state.totalDuration - currentPosition;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Time display matching the image design - current time on left, remaining on right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Current time (left side)
              Semantics(
                label: 'Current position: ${_formatDuration(currentPosition)}',
                child: Text(
                  _formatDuration(currentPosition),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
              // Remaining time (right side, negative format like in the image)
              Semantics(
                label: 'Remaining time: ${_formatDuration(remainingTime)}',
                child: Text(
                  '-${_formatDuration(remainingTime)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress slider with modern design matching the image
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              trackHeight: 3,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              thumbColor: Colors.white, // White thumb like in the image
              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: currentValue.clamp(0.0, 1.0),
              onChanged: (value) {
                setState(() {
                  _isDragging = true;
                  _dragValue = value;
                });
              },
              onChangeEnd: (value) {
                setState(() {
                  _isDragging = false;
                });
                final position = Duration(
                  milliseconds: (value * state.totalDuration.inMilliseconds).round(),
                );
                context.read<AudioPlayerBloc>().add(SeekEvent(position));
                // Provide haptic feedback
                HapticFeedback.lightImpact();
              },
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Quick seek buttons
          _buildQuickSeekButtons(context, state),
        ],
      ),
    );
  }

  /// Build quick seek buttons for common time intervals
  Widget _buildQuickSeekButtons(BuildContext context, AudioPlayerState state) {
    if (state.totalDuration.inMilliseconds == 0) return const SizedBox.shrink();
    
    final seekIntervals = [
      {'label': '10s', 'duration': const Duration(seconds: 10), 'icon': Icons.replay_10},
      {'label': '30s', 'duration': const Duration(seconds: 30), 'icon': Icons.replay_30},
      {'label': '1m', 'duration': const Duration(minutes: 1), 'icon': Icons.fast_rewind},
      {'label': '5m', 'duration': const Duration(minutes: 5), 'icon': Icons.skip_previous},
    ];
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: seekIntervals.map((interval) {
          return _buildQuickSeekButton(
            context,
            state,
            interval['label'] as String,
            interval['duration'] as Duration,
            interval['icon'] as IconData,
          );
        }).toList(),
      ),
    );
  }

  /// Build individual quick seek button
  Widget _buildQuickSeekButton(
    BuildContext context,
    AudioPlayerState state,
    String label,
    Duration duration,
    IconData icon,
  ) {
    return Semantics(
      label: 'Seek $label',
      button: true,
      child: InkWell(
        onTap: () {
          final newPosition = state.currentPosition + duration;
          final clampedPosition = Duration(
            milliseconds: newPosition.inMilliseconds.clamp(
              0,
              state.totalDuration.inMilliseconds,
            ),
          );
          context.read<AudioPlayerBloc>().add(SeekEvent(clampedPosition));
          HapticFeedback.lightImpact();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Format duration to HH:MM:SS or MM:SS format
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

  /// Build main controls with enhanced accessibility and visual feedback
  Widget _buildMainControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Previous/Chapter button
        _buildControlButton(
          context: context,
          icon: Icons.skip_previous,
          tooltip: 'Previous Chapter',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipBackwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 32,
        ),
        
        // Skip backward 30 seconds
        _buildControlButton(
          context: context,
          icon: Icons.replay_30,
          tooltip: 'Skip Backward 30s',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipBackwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 28,
        ),
        
        // Play/Pause button with enhanced styling
        _buildPlayPauseButton(context, state),
        
        // Skip forward 30 seconds
        _buildControlButton(
          context: context,
          icon: Icons.forward_30,
          tooltip: 'Skip Forward 30s',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 28,
        ),
        
        // Next/Chapter button
        _buildControlButton(
          context: context,
          icon: Icons.skip_next,
          tooltip: 'Next Chapter',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 32,
        ),
      ],
    );
  }

  /// Build individual control button with accessibility
  Widget _buildControlButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required double size,
  }) {
    return Semantics(
      label: tooltip,
      button: true,
      enabled: onPressed != null,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent, // Transparent background like in the image
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(
            icon,
            color: onPressed != null 
                ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7) // Muted color like in the image
                : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          iconSize: size,
          tooltip: tooltip,
        ),
      ),
    );
  }

  /// Build enhanced play/pause button
  Widget _buildPlayPauseButton(BuildContext context, AudioPlayerState state) {
    return Semantics(
      label: state.isPlaying ? 'Pause' : 'Play',
      button: true,
      enabled: !state.isLoadingState,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white, // White circle like in the image
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: state.isLoadingState ? null : () {
              context.read<AudioPlayerBloc>().add(const TogglePlayPauseEvent());
              HapticFeedback.mediumImpact();
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black, // Black icon like in the image
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build secondary controls with enhanced features
  Widget _buildSecondaryControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Playback speed control
        _buildSpeedControl(context, state),
        
        // Volume control (placeholder for future implementation)
        _buildVolumeControl(context, state),
        
        // Sleep timer
        _buildSleepTimerControl(context, state),
        
        // Stop button
        _buildControlButton(
          context: context,
          icon: Icons.stop,
          tooltip: 'Stop Playback',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const StopPlaybackEvent());
            HapticFeedback.lightImpact();
          },
          size: 32,
        ),
      ],
    );
  }

  /// Build enhanced speed control
  Widget _buildSpeedControl(BuildContext context, AudioPlayerState state) {
    return Semantics(
      label: 'Playback Speed: ${state.formattedPlaybackSpeed}',
      button: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.speed,
              size: 18,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              state.formattedPlaybackSpeed,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 4),
            PopupMenuButton<double>(
              onSelected: (speed) {
                context.read<AudioPlayerBloc>().add(SetPlaybackSpeedEvent(speed));
                HapticFeedback.lightImpact();
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 0.5, child: Text('0.5x')),
                const PopupMenuItem(value: 0.75, child: Text('0.75x')),
                const PopupMenuItem(value: 1.0, child: Text('1.0x')),
                const PopupMenuItem(value: 1.25, child: Text('1.25x')),
                const PopupMenuItem(value: 1.5, child: Text('1.5x')),
                const PopupMenuItem(value: 2.0, child: Text('2.0x')),
                const PopupMenuItem(value: 3.0, child: Text('3.0x')),
              ],
              child: Icon(
                Icons.arrow_drop_down,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// Build volume control (placeholder)
  Widget _buildVolumeControl(BuildContext context, AudioPlayerState state) {
    return Semantics(
      label: 'Volume Control',
      button: true,
      child: IconButton(
        onPressed: () {
          // TODO: Implement volume control
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Volume control coming soon')),
          );
        },
        icon: const Icon(Icons.volume_up),
        tooltip: 'Volume Control',
      ),
    );
  }

  /// Build sleep timer control
  Widget _buildSleepTimerControl(BuildContext context, AudioPlayerState state) {
    return Semantics(
      label: 'Sleep Timer',
      button: true,
      child: IconButton(
        onPressed: () {
          _showSleepTimerDialog(context);
        },
        icon: const Icon(Icons.timer),
        tooltip: 'Sleep Timer',
      ),
    );
  }

  /// Build chapter navigation
  Widget _buildChapterNavigation(BuildContext context, AudioPlayerState state) {
    // This would be implemented when chapter data is available
    return const SizedBox.shrink();
  }

  /// Show sleep timer dialog
  void _showSleepTimerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sleep Timer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Set a timer to stop playback automatically'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.timer_off),
              title: const Text('Off'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement sleep timer off
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_10),
              title: const Text('10 minutes'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement 10 minute timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('30 minutes'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement 30 minute timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('1 hour'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Implement 1 hour timer
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
