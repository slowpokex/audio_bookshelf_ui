import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../blocs/audio_player/audio_player_bloc.dart';
import '../blocs/audio_player/audio_player_event.dart';
import '../blocs/audio_player/audio_player_state.dart';

/// Expanded audio player page with detailed controls
class ExpandedAudioPlayerPage extends StatelessWidget {
  const ExpandedAudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.keyboard_arrow_down),
          tooltip: 'Minimize Player',
        ),
        actions: [
          IconButton(
            onPressed: () => _showPlayerOptions(context),
            icon: const Icon(Icons.more_vert),
            tooltip: 'More Options',
          ),
        ],
      ),
      body: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
        builder: (context, state) {
          if (!state.hasCurrentAudiobook) {
            return _buildNoContent(context);
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Cover image section
                _buildCoverSection(context, state),
                
                const SizedBox(height: 32),
                
                // Audiobook info
                _buildAudiobookInfo(context, state),
                
                const SizedBox(height: 32),
                
                // Progress section
                _buildProgressSection(context, state),
                
                const SizedBox(height: 32),
                
                // Main controls
                _buildMainControls(context, state),
                
                const SizedBox(height: 24),
                
                // Secondary controls
                _buildSecondaryControls(context, state),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build no content view
  Widget _buildNoContent(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.audiotrack,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No audiobook selected',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select an audiobook to start playing',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  /// Build cover image section
  Widget _buildCoverSection(BuildContext context, AudioPlayerState state) {
    final audiobook = state.currentAudiobook!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Cover image
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: audiobook.hasCoverImage
                  ? Image.file(
                      File(audiobook.coverImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildDefaultCover(context);
                      },
                    )
                  : _buildDefaultCover(context),
            ),
          ),
        ],
      ),
    );
  }

  /// Build default cover
  Widget _buildDefaultCover(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.audiotrack,
        color: Theme.of(context).colorScheme.primary,
        size: 80,
      ),
    );
  }

  /// Build audiobook info
  Widget _buildAudiobookInfo(BuildContext context, AudioPlayerState state) {
    final audiobook = state.currentAudiobook!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Title
          Text(
            audiobook.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          
          // Author
          Text(
            audiobook.displayAuthor,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          // Genre
          if (audiobook.genre != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                audiobook.genre!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build progress section
  Widget _buildProgressSection(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Time display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.formattedCurrentPosition,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                state.formattedTotalDuration,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Progress slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              trackHeight: 6,
              activeTrackColor: Theme.of(context).colorScheme.primary,
              inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
              thumbColor: Theme.of(context).colorScheme.primary,
              overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
            ),
            child: Slider(
              value: state.progressPercentage.clamp(0.0, 1.0),
              onChanged: (value) {
                final position = Duration(
                  milliseconds: (value * state.totalDuration.inMilliseconds).round(),
                );
                context.read<AudioPlayerBloc>().add(SeekEvent(position));
              },
              onChangeEnd: (value) {
                // Provide haptic feedback
                HapticFeedback.lightImpact();
              },
            ),
          ),
          
          // Progress percentage
          const SizedBox(height: 8),
          Text(
            '${(state.progressPercentage * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build main controls
  Widget _buildMainControls(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Skip backward 10 seconds
          _buildSkipButton(
            context: context,
            icon: Icons.replay_10,
            onPressed: state.isLoadingState ? null : () {
              context.read<AudioPlayerBloc>().add(const SkipBackward10Event());
              HapticFeedback.lightImpact();
            },
            tooltip: 'Skip Backward 10s',
          ),
          
          // Play/Pause button
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: IconButton(
              onPressed: state.isLoadingState ? null : () {
                context.read<AudioPlayerBloc>().add(const TogglePlayPauseEvent());
                HapticFeedback.mediumImpact();
              },
              icon: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              iconSize: 48,
              tooltip: state.isPlaying ? 'Pause' : 'Play',
            ),
          ),
          
          // Skip forward 10 seconds
          _buildSkipButton(
            context: context,
            icon: Icons.forward_10,
            onPressed: state.isLoadingState ? null : () {
              context.read<AudioPlayerBloc>().add(const SkipForward10Event());
              HapticFeedback.lightImpact();
            },
            tooltip: 'Skip Forward 10s',
          ),
        ],
      ),
    );
  }

  /// Build skip button
  Widget _buildSkipButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        iconSize: 32,
        tooltip: tooltip,
      ),
    );
  }

  /// Build secondary controls
  Widget _buildSecondaryControls(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Playback speed
          _buildSpeedControl(context, state),
          
          // Stop button
          IconButton(
            onPressed: state.isLoadingState ? null : () {
              context.read<AudioPlayerBloc>().add(const StopPlaybackEvent());
              HapticFeedback.lightImpact();
            },
            icon: const Icon(Icons.stop),
            iconSize: 24,
            tooltip: 'Stop',
          ),
          
          // Sleep timer
          IconButton(
            onPressed: () {
              _showSleepTimerDialog(context);
            },
            icon: const Icon(Icons.timer),
            iconSize: 24,
            tooltip: 'Sleep Timer',
          ),
        ],
      ),
    );
  }

  /// Build speed control
  Widget _buildSpeedControl(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.speed, size: 20),
        const SizedBox(width: 8),
        Text(
          state.formattedPlaybackSpeed,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
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
          child: const Icon(Icons.arrow_drop_down),
        ),
      ],
    );
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

  /// Show player options
  void _showPlayerOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.bookmark_add),
              title: const Text('Add Bookmark'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement bookmark
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement favorite
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement share
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Audiobook Info'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show audiobook details
              },
            ),
          ],
        ),
      ),
    );
  }
}
