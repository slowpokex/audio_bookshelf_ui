import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/services/audio_player_service.dart';
import '../blocs/audio_player/audio_player_bloc.dart';
import '../blocs/audio_player/audio_player_event.dart';
import '../blocs/audio_player/audio_player_state.dart';

/// Full-screen audio player page
class AudioPlayerPage extends StatelessWidget {
  const AudioPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AudioPlayerBloc(
        audioPlayerService: AudioPlayerService(),
      ),
      child: const _AudioPlayerView(),
    );
  }
}

class _AudioPlayerView extends StatefulWidget {
  const _AudioPlayerView();

  @override
  State<_AudioPlayerView> createState() => _AudioPlayerViewState();
}

class _AudioPlayerViewState extends State<_AudioPlayerView> {
  late FocusNode _focusNode;
  double _seekStartX = 0.0;
  Duration _seekStartPosition = Duration.zero;
  bool _isSeeking = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Now Playing'),
          actions: [
            IconButton(
              onPressed: () {
                _showKeyboardShortcutsDialog(context);
              },
              icon: const Icon(Icons.help_outline),
              tooltip: 'Keyboard Shortcuts',
            ),
            IconButton(
              onPressed: () {
                // Add to favorites or other actions
              },
              icon: const Icon(Icons.favorite_border),
              tooltip: 'Add to Favorites',
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle menu selection
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'bookmark',
                  child: ListTile(
                    leading: Icon(Icons.bookmark_add),
                    title: Text('Add Bookmark'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'sleep_timer',
                  child: ListTile(
                    leading: Icon(Icons.timer),
                    title: Text('Sleep Timer'),
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: ListTile(
                    leading: Icon(Icons.share),
                    title: Text('Share'),
                  ),
                ),
              ],
            ),
          ],
        ),
        body: BlocBuilder<AudioPlayerBloc, AudioPlayerState>(
          builder: (context, state) {
            if (!state.hasCurrentAudiobook) {
              return _buildNoContent(context);
            }

            return Column(
              children: [
                // Cover image and info
                Expanded(
                  flex: 3,
                  child: _buildCoverSection(context, state),
                ),
                
                // Controls
                Expanded(
                  flex: 2,
                  child: _buildControlsSection(context, state),
                ),
              ],
            );
          },
        ),
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

  /// Build cover section with gesture controls
  Widget _buildCoverSection(BuildContext context, AudioPlayerState state) {
    final audiobook = state.currentAudiobook!;

    return GestureDetector(
      onTap: () {
        // Single tap to toggle play/pause
        context.read<AudioPlayerBloc>().add(const TogglePlayPauseEvent());
      },
      onDoubleTap: () {
        // Double tap to skip forward
        context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
      },
      onLongPress: () {
        // Long press to show options
        _showPlayerOptionsDialog(context);
      },
      onPanStart: (details) {
        // Initialize seek gesture
        _isSeeking = false;
        _seekStartX = details.globalPosition.dx;
        _seekStartPosition = state.currentPosition;
      },
      onPanUpdate: (details) {
        // Horizontal swipe for seeking
        _handleSeekGesture(context, details, state);
      },
      onPanEnd: (details) {
        // Reset seek gesture state
        _resetSeekGesture();
      },
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Seek indicator
            if (_isSeeking)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Seeking...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (_isSeeking) const SizedBox(height: 16),
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
                    ? Image.asset(
                        audiobook.coverImagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildDefaultCover(context);
                        },
                      )
                    : _buildDefaultCover(context),
              ),
            ),
            const SizedBox(height: 24),
            
            // Audiobook info
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
            
            Text(
              audiobook.displayAuthor,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
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
      ),
    );
  }

  /// Show player options dialog
  void _showPlayerOptionsDialog(BuildContext context) {
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

  /// Build controls section
  Widget _buildControlsSection(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Progress bar
          _buildProgressSection(context, state),
          const SizedBox(height: 24),
          
          // Main controls
          _buildMainControls(context, state),
          const SizedBox(height: 24),
          
          // Secondary controls
          _buildSecondaryControls(context, state),
        ],
      ),
    );
  }

  /// Build progress section
  Widget _buildProgressSection(BuildContext context, AudioPlayerState state) {
    return Column(
      children: [
        // Time display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              state.formattedCurrentPosition,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              state.formattedTotalDuration,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: state.progressPercentage,
            onChanged: (value) {
              final position = Duration(
                milliseconds: (value * state.totalDuration.inMilliseconds).round(),
              );
              context.read<AudioPlayerBloc>().add(SeekEvent(position));
            },
          ),
        ),
      ],
    );
  }

  /// Build main controls
  Widget _buildMainControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip backward
        IconButton(
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipBackwardEvent());
          },
          icon: const Icon(Icons.replay_30),
          iconSize: 32,
        ),
        
        // Play/Pause button
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: state.isLoadingState ? null : () {
              context.read<AudioPlayerBloc>().add(const TogglePlayPauseEvent());
            },
            icon: Icon(
              state.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 48,
          ),
        ),
        
        // Skip forward
        IconButton(
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
          },
          icon: const Icon(Icons.forward_30),
          iconSize: 32,
        ),
      ],
    );
  }

  /// Build secondary controls
  Widget _buildSecondaryControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Playback speed
        _buildSpeedControl(context, state),
        
        // Stop button
        IconButton(
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const StopPlaybackEvent());
          },
          icon: const Icon(Icons.stop),
          iconSize: 24,
        ),
        
        // Sleep timer
        IconButton(
          onPressed: () {
            _showSleepTimerDialog(context);
          },
          icon: const Icon(Icons.timer),
          iconSize: 24,
        ),
      ],
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
            // Add sleep timer options here
            ListTile(
              leading: const Icon(Icons.timer_off),
              title: const Text('Off'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement sleep timer off
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer_10),
              title: const Text('10 minutes'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement 10 minute timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('30 minutes'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement 30 minute timer
              },
            ),
            ListTile(
              leading: const Icon(Icons.timer),
              title: const Text('1 hour'),
              onTap: () {
                Navigator.of(context).pop();
                // Implement 1 hour timer
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

  /// Show keyboard shortcuts dialog
  void _showKeyboardShortcutsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keyboard Shortcuts'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildShortcutRow('Space', 'Play/Pause'),
              _buildShortcutRow('←', 'Skip Backward 30s'),
              _buildShortcutRow('→', 'Skip Forward 30s'),
              _buildShortcutRow('Shift + ←', 'Previous Chapter'),
              _buildShortcutRow('Shift + →', 'Next Chapter'),
              _buildShortcutRow('S', 'Stop'),
              _buildShortcutRow('F', 'Toggle Favorite'),
              _buildShortcutRow('B', 'Add Bookmark'),
              _buildShortcutRow('Esc', 'Close Player'),
              const SizedBox(height: 8),
              const Text(
                'Seek Controls:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildShortcutRow('0', 'Seek to Beginning'),
              _buildShortcutRow('1-9', 'Seek to 10%-90%'),
              _buildShortcutRow('H', 'Show This Help'),
              const SizedBox(height: 16),
              const Text(
                'Touch Gestures:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildShortcutRow('Tap Cover', 'Play/Pause'),
              _buildShortcutRow('Double Tap', 'Skip Forward'),
              _buildShortcutRow('Long Press', 'Show Options'),
              _buildShortcutRow('Swipe Left/Right', 'Seek Forward/Backward'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  /// Build shortcut row
  Widget _buildShortcutRow(String key, String action) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(action)),
        ],
      ),
    );
  }

  /// Handle keyboard events for shortcuts
  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      final bloc = context.read<AudioPlayerBloc>();
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.space:
          // Space bar to toggle play/pause
          bloc.add(const TogglePlayPauseEvent());
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit1:
          // 1 to seek to 10%
          _seekToPercentage(bloc, 0.1);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit2:
          // 2 to seek to 20%
          _seekToPercentage(bloc, 0.2);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit3:
          // 3 to seek to 30%
          _seekToPercentage(bloc, 0.3);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit4:
          // 4 to seek to 40%
          _seekToPercentage(bloc, 0.4);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit5:
          // 5 to seek to 50%
          _seekToPercentage(bloc, 0.5);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit6:
          // 6 to seek to 60%
          _seekToPercentage(bloc, 0.6);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit7:
          // 7 to seek to 70%
          _seekToPercentage(bloc, 0.7);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit8:
          // 8 to seek to 80%
          _seekToPercentage(bloc, 0.8);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit9:
          // 9 to seek to 90%
          _seekToPercentage(bloc, 0.9);
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.digit0:
          // 0 to seek to beginning
          bloc.add(SeekEvent(Duration.zero));
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.arrowLeft:
          // Left arrow to skip backward
          if (HardwareKeyboard.instance.isShiftPressed) {
            // Shift + Left for previous chapter
            bloc.add(const SkipBackwardEvent());
          } else {
            // Left for 30s backward
            bloc.add(const SkipBackwardEvent());
          }
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.arrowRight:
          // Right arrow to skip forward
          if (HardwareKeyboard.instance.isShiftPressed) {
            // Shift + Right for next chapter
            bloc.add(const SkipForwardEvent());
          } else {
            // Right for 30s forward
            bloc.add(const SkipForwardEvent());
          }
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.escape:
          // Escape to go back
          Navigator.of(context).pop();
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.keyS:
          // S to stop
          bloc.add(const StopPlaybackEvent());
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.keyF:
          // F to toggle favorite
          // TODO: Implement favorite toggle
          return KeyEventResult.handled;
          
        case LogicalKeyboardKey.keyB:
          // B to add bookmark
          // TODO: Implement bookmark
          return KeyEventResult.handled;
      }
    }
    
    return KeyEventResult.ignored;
  }

  /// Handle seek gesture for horizontal swipes
  void _handleSeekGesture(BuildContext context, DragUpdateDetails details, AudioPlayerState state) {
    if (state.totalDuration.inMilliseconds == 0) {
      return;
    }
    
    if (!_isSeeking) {
      _isSeeking = true;
      _seekStartX = details.globalPosition.dx;
      _seekStartPosition = state.currentPosition;
    }
    
    final deltaX = details.globalPosition.dx - _seekStartX;
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate seek amount based on swipe distance
    // Full screen width = 10% of total duration
    final seekRatio = (deltaX / screenWidth) * 0.1;
    final seekDuration = Duration(
      milliseconds: (state.totalDuration.inMilliseconds * seekRatio).round(),
    );
    
    final newPosition = _seekStartPosition + seekDuration;
    final clampedPosition = Duration(
      milliseconds: newPosition.inMilliseconds.clamp(
        0,
        state.totalDuration.inMilliseconds,
      ),
    );
    
    // Update position in real-time during gesture
    context.read<AudioPlayerBloc>().add(SeekEvent(clampedPosition));
  }

  /// Reset seek gesture state
  void _resetSeekGesture() {
    _isSeeking = false;
    _seekStartX = 0.0;
    _seekStartPosition = Duration.zero;
  }

  /// Seek to a specific percentage of the audiobook
  void _seekToPercentage(AudioPlayerBloc bloc, double percentage) {
    // We need to get the current state to access total duration
    // This is a limitation of the keyboard handler approach
    // In a real implementation, you might want to store the total duration
    // in a variable or use a different approach
    final state = bloc.state;
    if (state.totalDuration.inMilliseconds > 0) {
      final targetPosition = Duration(
        milliseconds: (state.totalDuration.inMilliseconds * percentage).round(),
      );
      bloc.add(SeekEvent(targetPosition));
    }
  }
}
