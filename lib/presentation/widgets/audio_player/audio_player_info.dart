import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import '../../../presentation/blocs/audio_player/audio_player_bloc.dart';
import '../../../presentation/blocs/audio_player/audio_player_event.dart';
import '../../../presentation/blocs/audio_player/audio_player_state.dart';
import '../../../presentation/pages/expanded_audio_player_page.dart';

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
              // Cover image - Tappable area
              _buildTappableCoverImage(context, audiobook),
              const SizedBox(width: 16),
              
              // Audiobook info - Tappable area
              Expanded(
                child: _buildTappableAudiobookInfo(context, audiobook, state),
              ),
              
              // Play button - Not tappable for expansion
              _buildPlayButton(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Build tappable cover image
  Widget _buildTappableCoverImage(BuildContext context, audiobook) {
    return Semantics(
      label: 'Audiobook cover image',
      hint: 'Tap to open expanded player',
      button: true,
      child: GestureDetector(
        onTap: () => _navigateToExpandedPlayer(context),
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
      ),
    );
  }

  /// Build default cover when no image is available
  Widget _buildDefaultCover(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      child: Icon(
        Icons.audiotrack,
        color: Theme.of(context).colorScheme.primary,
        size: 30,
      ),
    );
  }

  /// Build tappable audiobook info (excluding slider)
  Widget _buildTappableAudiobookInfo(BuildContext context, audiobook, AudioPlayerState state) {
    return Semantics(
      label: 'Audiobook information',
      hint: 'Tap to open expanded player',
      button: true,
      child: GestureDetector(
        onTap: () => _navigateToExpandedPlayer(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title and Author - Tappable area
            Column(
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
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 4),
            
            // Progress info - Show time without percentage (tappable)
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
            const SizedBox(height: 8),
            
            // Enhanced Progress Slider - NOT tappable for expansion
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 4,
                activeTrackColor: Theme.of(context).colorScheme.primary,
                inactiveTrackColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                thumbColor: Theme.of(context).colorScheme.primary,
                overlayColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
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
        ),
      ),
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

  /// Navigate to expanded player
  void _navigateToExpandedPlayer(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ExpandedAudioPlayerPage(),
        fullscreenDialog: true,
      ),
    );
  }
}
