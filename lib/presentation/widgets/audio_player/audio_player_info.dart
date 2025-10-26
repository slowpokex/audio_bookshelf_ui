import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../presentation/blocs/audio_player/audio_player_bloc.dart';
import '../../../presentation/blocs/audio_player/audio_player_event.dart';
import '../../../presentation/blocs/audio_player/audio_player_state.dart';

/// Audio player info widget showing current audiobook details
class AudioPlayerInfo extends StatelessWidget {
  const AudioPlayerInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (!state.hasCurrentAudiobook) {
          return const SizedBox.shrink();
        }

        final audiobook = state.currentAudiobook!;

        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Cover image
              _buildCoverImage(context, audiobook),
              const SizedBox(width: 16),
              
              // Audiobook info
              Expanded(
                child: _buildAudiobookInfo(context, audiobook, state),
              ),
              
              // Play button
              _buildPlayButton(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Build cover image
  Widget _buildCoverImage(BuildContext context, audiobook) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: audiobook.hasCoverImage
            ? Image.asset(
                audiobook.coverImagePath!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultCover(context);
                },
              )
            : _buildDefaultCover(context),
      ),
    );
  }

  /// Build default cover when no image is available
  Widget _buildDefaultCover(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.audiotrack,
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }

  /// Build audiobook info
  Widget _buildAudiobookInfo(BuildContext context, audiobook, AudioPlayerState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title and Author - Clickable for navigation
        InkWell(
          onTap: () => _navigateToFullPlayer(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                audiobook.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              
              // Author
              Text(
                audiobook.displayAuthor,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        
        // Progress info - Always show progress bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  state.formattedCurrentPosition,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  ' / ',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  state.formattedTotalDuration,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            // Progress percentage
            Text(
              '${(state.progressPercentage * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        
        // Enhanced Progress Slider - Always visible and interactive
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            thumbColor: Theme.of(context).colorScheme.primary,
            overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: state.progressPercentage.clamp(0.0, 1.0),
            onChanged: (value) {
              // This will be called during dragging
              final newPosition = Duration(
                milliseconds: (state.totalDuration.inMilliseconds * value).round(),
              );
              context.read<AudioPlayerBloc>().add(SeekEvent(newPosition));
            },
            onChangeEnd: (value) {
              // This will be called when dragging ends
              final newPosition = Duration(
                milliseconds: (state.totalDuration.inMilliseconds * value).round(),
              );
              context.read<AudioPlayerBloc>().add(SeekEvent(newPosition));
              // Provide haptic feedback
              HapticFeedback.lightImpact();
            },
          ),
        ),
        
      ],
    );
  }

  /// Build play button
  Widget _buildPlayButton(BuildContext context, AudioPlayerState state) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
      child: IconButton(
        onPressed: state.isLoadingState ? null : () {
          context.read<AudioPlayerBloc>().add(const TogglePlayPauseEvent());
        },
        icon: Icon(
          state.isPlaying ? Icons.pause : Icons.play_arrow,
          color: Colors.white,
        ),
        iconSize: 24,
      ),
    );
  }

  /// Navigate to full player
  void _navigateToFullPlayer(BuildContext context) {
    context.go('/audio-player');
  }
}
