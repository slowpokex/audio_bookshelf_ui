import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../blocs/audiobook/audiobook_bloc.dart';
import '../blocs/audio_player/audio_player_bloc.dart';
import '../blocs/audio_player/audio_player_event.dart';
import '../../domain/entities/audiobook.dart';

class AudiobookDetailsPage extends StatefulWidget {
  final String audiobookId;

  const AudiobookDetailsPage({
    super.key,
    required this.audiobookId,
  });

  @override
  State<AudiobookDetailsPage> createState() => _AudiobookDetailsPageState();
}

class _AudiobookDetailsPageState extends State<AudiobookDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<AudiobookBloc>().add(LoadAudiobookEvent(id: widget.audiobookId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AudiobookBloc, AudiobookState>(
        builder: (context, state) {
          if (state is AudiobookLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AudiobookDetailLoadedState) {
            return _buildContent(context, state.audiobook);
          } else if (state is AudiobookErrorState) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, Audiobook audiobook) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: audiobook.hasCoverImage
                ? Image.file(
                    File(audiobook.coverImagePath!),
                    fit: BoxFit.cover,
                  )
                : Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.audiotrack,
                      size: 100,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  audiobook.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  audiobook.displayAuthor,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          context.read<AudioPlayerBloc>().add(PlayAudiobookEvent(audiobook));
                          context.pushNamed('audio-player');
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Play'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (audiobook.description != null) ...[
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audiobook.description!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 24),
                _buildMetadataSection(context, audiobook),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataSection(BuildContext context, Audiobook audiobook) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (audiobook.genre != null) _buildMetadataItem(context, 'Genre', audiobook.genre!),
        if (audiobook.year != null) _buildMetadataItem(context, 'Year', audiobook.year.toString()),
        if (audiobook.duration != null)
          _buildMetadataItem(context, 'Duration', _formatDuration(audiobook.duration!)),
      ],
    );
  }

  Widget _buildMetadataItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return '${hours}h ${minutes}m';
  }
}
