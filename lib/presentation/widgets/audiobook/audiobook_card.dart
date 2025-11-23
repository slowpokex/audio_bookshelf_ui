import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/entities/audiobook.dart';
import '../../blocs/audio_player/audio_player_bloc.dart';
import '../../blocs/audio_player/audio_player_event.dart';
import '../../blocs/audiobook/audiobook_bloc.dart';

/// Enhanced audiobook card widget with modern design and rich information
class AudiobookCard extends StatelessWidget {
  final Audiobook audiobook;
  final bool isGridView;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const AudiobookCard({
    super.key,
    required this.audiobook,
    this.isGridView = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (isGridView) {
      return _buildGridCard(context);
    } else {
      return _buildListCard(context);
    }
  }

  /// Build grid view card (compact)
  Widget _buildGridCard(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentlyPlaying = _isCurrentlyPlaying(context);
    
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        onLongPress: onLongPress ?? () => _showContextMenu(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover image with progress indicator
            Stack(
              children: [
                _buildCoverImage(context, height: 180),
                if (isCurrentlyPlaying)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.equalizer,
                        size: 16,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                if (audiobook.isFavorite)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                // Progress indicator overlay
                if (audiobook.isStarted)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(
                      value: audiobook.progressPercentage,
                      backgroundColor: Colors.black.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                      minHeight: 3,
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    audiobook.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Author
                  Text(
                    audiobook.author,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // Metadata row
                  Row(
                    children: [
                      if (audiobook.rating > 0) ...[
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          audiobook.rating.toStringAsFixed(1),
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (audiobook.duration != null) ...[
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _formatDuration(audiobook.duration!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build list view card (detailed)
  Widget _buildListCard(BuildContext context) {
    final theme = Theme.of(context);
    final isCurrentlyPlaying = _isCurrentlyPlaying(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap ?? () => _handleTap(context),
        onLongPress: onLongPress ?? () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Cover image
              Stack(
                children: [
                  _buildCoverImage(context, width: 80, height: 80),
                  if (isCurrentlyPlaying)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.equalizer,
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title row with favorite
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            audiobook.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (audiobook.isFavorite)
                          Icon(
                            Icons.favorite,
                            size: 18,
                            color: Colors.red,
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Author
                    Text(
                      audiobook.author,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (audiobook.narrator != null && audiobook.narrator!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Narrated by ${audiobook.narrator}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Progress bar
                    if (audiobook.isStarted)
                      Column(
                        children: [
                          LinearProgressIndicator(
                            value: audiobook.progressPercentage,
                            backgroundColor: theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                            minHeight: 4,
                            borderRadius: BorderRadius.circular(2),
                          ),
                          const SizedBox(height: 4),
                        ],
                      ),
                    // Metadata row
                    Row(
                      children: [
                        if (audiobook.rating > 0) ...[
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            audiobook.rating.toStringAsFixed(1),
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                        ],
                        if (audiobook.duration != null) ...[
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _formatDuration(audiobook.duration!),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                        if (audiobook.isStarted) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.bookmark,
                            size: 14,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${(audiobook.progressPercentage * 100).toStringAsFixed(0)}%',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              // Play button
              IconButton(
                icon: Icon(
                  isCurrentlyPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
                onPressed: () => _handlePlayPause(context),
                tooltip: isCurrentlyPlaying ? 'Pause' : 'Play',
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build cover image widget
  Widget _buildCoverImage(BuildContext context, {double? width, double? height}) {
    final theme = Theme.of(context);
    final size = Size(
      width ?? double.infinity,
      height ?? 120,
    );

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: audiobook.hasCoverImage
            ? Image.file(
                File(audiobook.coverImagePath!),
                fit: BoxFit.cover,
                width: size.width,
                height: size.height,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultCover(context, size);
                },
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) return child;
                  return AnimatedOpacity(
                    opacity: frame == null ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  );
                },
              )
            : _buildDefaultCover(context, size),
      ),
    );
  }

  /// Build default cover when no image is available
  Widget _buildDefaultCover(BuildContext context, Size size) {
    final theme = Theme.of(context);
    return Container(
      width: size.width,
      height: size.height,
      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
      child: Icon(
        Icons.library_books,
        color: theme.colorScheme.onPrimaryContainer,
        size: size.width * 0.3,
      ),
    );
  }

  /// Check if audiobook is currently playing
  bool _isCurrentlyPlaying(BuildContext context) {
    final audioPlayerState = context.watch<AudioPlayerBloc>().state;
    return audioPlayerState.currentAudiobook?.id == audiobook.id &&
           audioPlayerState.isPlaying;
  }

  /// Handle tap on card
  void _handleTap(BuildContext context) {
    context.read<AudioPlayerBloc>().add(
      PlayAudiobookEvent(audiobook),
    );
  }

  /// Handle play/pause button
  void _handlePlayPause(BuildContext context) {
    final audioPlayerState = context.read<AudioPlayerBloc>().state;
    if (audioPlayerState.currentAudiobook?.id == audiobook.id) {
      if (audioPlayerState.isPlaying) {
        context.read<AudioPlayerBloc>().add(const PausePlaybackEvent());
      } else {
        context.read<AudioPlayerBloc>().add(const ResumePlaybackEvent());
      }
    } else {
      context.read<AudioPlayerBloc>().add(
        PlayAudiobookEvent(audiobook),
      );
    }
  }

  /// Show context menu
  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildContextMenu(context),
    );
  }

  /// Build context menu
  Widget _buildContextMenu(BuildContext context) {
    final theme = Theme.of(context);
    final audioPlayerState = context.read<AudioPlayerBloc>().state;
    final isCurrentlyPlaying = audioPlayerState.currentAudiobook?.id == audiobook.id;
    
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              audiobook.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Divider(),
          // Menu items
          ListTile(
            leading: Icon(
              isCurrentlyPlaying ? Icons.pause : Icons.play_arrow,
              color: theme.colorScheme.primary,
            ),
            title: Text(isCurrentlyPlaying ? 'Pause' : 'Play'),
            onTap: () {
              Navigator.pop(context);
              _handlePlayPause(context);
            },
          ),
          ListTile(
            leading: Icon(
              audiobook.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: audiobook.isFavorite ? Colors.red : null,
            ),
            title: Text(audiobook.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
            onTap: () {
              Navigator.pop(context);
              context.read<AudiobookBloc>().add(
                ToggleFavoriteEvent(audiobook.id),
              );
            },
          ),
          if (audiobook.isStarted)
            ListTile(
              leading: Icon(
                Icons.replay,
                color: theme.colorScheme.primary,
              ),
              title: const Text('Resume from Last Position'),
              onTap: () {
                Navigator.pop(context);
                _handleTap(context);
              },
            ),
          ListTile(
            leading: Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSurface,
            ),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              context.pushNamed(
                'audiobook-details',
                pathParameters: {'id': audiobook.id},
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Delete',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () {
              Navigator.pop(context);
              _showDeleteConfirmation(context);
            },
          ),
        ],
      ),
    );
  }

  /// Show delete confirmation dialog
  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Audiobook'),
        content: Text('Are you sure you want to delete "${audiobook.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AudiobookBloc>().add(
                DeleteAudiobookEvent(id: audiobook.id),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }

  /// Format duration to readable string
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}
