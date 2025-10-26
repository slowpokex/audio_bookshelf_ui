import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation/blocs/audio_player/audio_player_bloc.dart';
import '../../../presentation/blocs/audio_player/audio_player_event.dart';
import '../../../presentation/blocs/audio_player/audio_player_state.dart';
import 'audio_player_info.dart';

/// Mini audio player widget for bottom navigation
class AudioPlayerMini extends StatelessWidget {
  const AudioPlayerMini({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
      builder: (context, state) {
        if (!state.hasCurrentAudiobook) {
          return const SizedBox.shrink();
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              top: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 0.5,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Main player info
              const AudioPlayerInfo(),
              
              // Error display
              if (state.hasError) _buildErrorBanner(context, state),
            ],
          ),
        );
      },
    );
  }

  /// Build error banner
  Widget _buildErrorBanner(BuildContext context, AudioPlayerState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.error.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              state.error!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<AudioPlayerBloc>().add(const ClearErrorEvent());
            },
            icon: const Icon(Icons.close),
            iconSize: 16,
            color: Theme.of(context).colorScheme.error,
          ),
        ],
      ),
    );
  }

}
