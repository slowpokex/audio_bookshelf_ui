import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:ui';
import 'dart:io';
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

class _AudioPlayerViewState extends State<_AudioPlayerView>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  double _seekStartX = 0.0;
  Duration _seekStartPosition = Duration.zero;
  bool _isSeeking = false;
  
  // Animation controllers
  late AnimationController _coverAnimationController;
  late AnimationController _controlsAnimationController;
  late AnimationController _progressAnimationController;
  
  // Animations
  late Animation<double> _coverScaleAnimation;
  late Animation<double> _controlsOpacityAnimation;
  late Animation<double> _progressOpacityAnimation;
  late Animation<Offset> _controlsSlideAnimation;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.requestFocus();
    
    // Initialize animation controllers
    _coverAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // Initialize animations
    _coverScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _coverAnimationController,
      curve: Curves.elasticOut,
    ));
    
    _controlsOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOut,
    ));
    
    _progressOpacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressAnimationController,
      curve: Curves.easeOut,
    ));
    
    _controlsSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations
    _coverAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _controlsAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _progressAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _coverAnimationController.dispose();
    _controlsAnimationController.dispose();
    _progressAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                _showKeyboardShortcutsDialog(context);
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.help_outline,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                // Add to favorites or other actions
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                // Handle menu selection
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.white,
                  size: 20,
                ),
              ),
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

            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface,
                  ],
                  stops: const [0.0, 0.3, 1.0],
                ),
              ),
              child: Column(
                children: [
                  // Cover image and info
                  Expanded(
                    flex: 3,
                    child: _buildCoverSection(context, state),
                  ),
                  
                  // Controls with glassmorphism effect
                  Expanded(
                    flex: 2,
                    child: _buildControlsSection(context, state),
                  ),
                ],
              ),
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
        HapticFeedback.lightImpact();
      },
      onDoubleTap: () {
        // Double tap to skip forward
        context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
        HapticFeedback.mediumImpact();
      },
      onLongPress: () {
        // Long press to show options
        HapticFeedback.heavyImpact();
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
            // Seek indicator with animation
            AnimatedOpacity(
              opacity: _isSeeking ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  'Seeking...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_isSeeking) const SizedBox(height: 16),
            
            // Cover image with enhanced animations
            AnimatedBuilder(
              animation: _coverScaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _coverScaleAnimation.value,
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          // Cover image
                          audiobook.hasCoverImage
                              ? Image.file(
                                  File(audiobook.coverImagePath!),
                                  fit: BoxFit.cover,
                                  width: 280,
                                  height: 280,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultCover(context);
                                  },
                                )
                              : _buildDefaultCover(context),
                          
                          // Play/Pause overlay with blur effect
                          if (state.isPlaying)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 2, sigmaY: 2),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.1),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.pause,
                                          color: Colors.white,
                                          size: 32,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            
            // Audiobook info with fade-in animation
            FadeTransition(
              opacity: _controlsOpacityAnimation,
              child: SlideTransition(
                position: _controlsSlideAnimation,
                child: Column(
                  children: [
                    Text(
                      audiobook.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
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
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          audiobook.genre!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
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
    return FadeTransition(
      opacity: _controlsOpacityAnimation,
      child: SlideTransition(
        position: _controlsSlideAnimation,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    // Progress bar with enhanced design
                    FadeTransition(
                      opacity: _progressOpacityAnimation,
                      child: _buildProgressSection(context, state),
                    ),
                    const SizedBox(height: 32),
                    
                    // Main controls with better spacing
                    _buildMainControls(context, state),
                    const SizedBox(height: 24),
                    
                    // Secondary controls
                    _buildSecondaryControls(context, state),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build progress section
  Widget _buildProgressSection(BuildContext context, AudioPlayerState state) {
    return Column(
      children: [
        // Time display with better styling
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.formattedCurrentPosition,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                state.formattedRemainingTime,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Enhanced progress slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            trackHeight: 8,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            inactiveTrackColor: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            thumbColor: Colors.white,
            overlayColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: state.progressPercentage,
            onChanged: (value) {
              final position = Duration(
                milliseconds: (value * state.totalDuration.inMilliseconds).round(),
              );
              context.read<AudioPlayerBloc>().add(SeekEvent(position));
              HapticFeedback.lightImpact();
            },
          ),
        ),
        const SizedBox(height: 16),
        
        // Quick seek buttons with modern design
        _buildQuickSeekButtons(context, state),
      ],
    );
  }

  /// Build quick seek buttons
  Widget _buildQuickSeekButtons(BuildContext context, AudioPlayerState state) {
    if (state.totalDuration.inMilliseconds == 0) return const SizedBox.shrink();
    
    final seekOptions = [
      {'label': '10s', 'duration': const Duration(seconds: 10), 'icon': Icons.replay_10},
      {'label': '30s', 'duration': const Duration(seconds: 30), 'icon': Icons.replay_30},
      {'label': '1m', 'duration': const Duration(minutes: 1), 'icon': Icons.fast_rewind},
      {'label': '5m', 'duration': const Duration(minutes: 5), 'icon': Icons.skip_previous},
    ];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: seekOptions.map((option) {
        return _buildQuickSeekButton(
          context,
          state,
          option['label'] as String,
          option['duration'] as Duration,
          option['icon'] as IconData,
        );
      }).toList(),
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
    return Material(
      color: Colors.transparent,
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
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
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

  /// Build main controls
  Widget _buildMainControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip backward with animation
        _buildAnimatedControlButton(
          context: context,
          icon: Icons.replay_30,
          tooltip: 'Skip Backward 30s',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipBackwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 32,
          isSecondary: true,
        ),
        
        // Previous chapter
        _buildAnimatedControlButton(
          context: context,
          icon: Icons.skip_previous,
          tooltip: 'Previous Chapter',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipBackwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 36,
          isSecondary: true,
        ),
        
        // Play/Pause button with enhanced styling
        _buildPlayPauseButton(context, state),
        
        // Next chapter
        _buildAnimatedControlButton(
          context: context,
          icon: Icons.skip_next,
          tooltip: 'Next Chapter',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 36,
          isSecondary: true,
        ),
        
        // Skip forward with animation
        _buildAnimatedControlButton(
          context: context,
          icon: Icons.forward_30,
          tooltip: 'Skip Forward 30s',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const SkipForwardEvent());
            HapticFeedback.lightImpact();
          },
          size: 32,
          isSecondary: true,
        ),
      ],
    );
  }

  /// Build animated control button
  Widget _buildAnimatedControlButton({
    required BuildContext context,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required double size,
    bool isSecondary = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: isSecondary ? 48 : 56,
            height: isSecondary ? 48 : 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSecondary 
                  ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                  : Theme.of(context).colorScheme.primary.withOpacity(0.1),
              border: Border.all(
                color: isSecondary
                    ? Theme.of(context).colorScheme.outline.withOpacity(0.2)
                    : Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Icon(
              icon,
              color: onPressed != null 
                  ? (isSecondary 
                      ? Theme.of(context).colorScheme.onSurface.withOpacity(0.8)
                      : Theme.of(context).colorScheme.primary)
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
              size: size,
            ),
          ),
        ),
      ),
    );
  }

  /// Build enhanced play/pause button
  Widget _buildPlayPauseButton(BuildContext context, AudioPlayerState state) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const TogglePlayPauseEvent());
            HapticFeedback.mediumImpact();
          },
          borderRadius: BorderRadius.circular(40),
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                state.isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 36,
                key: ValueKey(state.isPlaying),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build secondary controls
  Widget _buildSecondaryControls(BuildContext context, AudioPlayerState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Playback speed control
        _buildSpeedControl(context, state),
        
        // Volume control
        _buildVolumeControl(context, state),
        
        // Sleep timer
        _buildSleepTimerControl(context, state),
        
        // Stop button
        _buildAnimatedControlButton(
          context: context,
          icon: Icons.stop,
          tooltip: 'Stop Playback',
          onPressed: state.isLoadingState ? null : () {
            context.read<AudioPlayerBloc>().add(const StopPlaybackEvent());
            HapticFeedback.lightImpact();
          },
          size: 24,
          isSecondary: true,
        ),
      ],
    );
  }

  /// Build enhanced speed control
  Widget _buildSpeedControl(BuildContext context, AudioPlayerState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
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
          const SizedBox(width: 8),
          Text(
            state.formattedPlaybackSpeed,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
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
    );
  }

  /// Build volume control
  Widget _buildVolumeControl(BuildContext context, AudioPlayerState state) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: Implement volume control
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Volume control coming soon')),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Icon(
            Icons.volume_up,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            size: 20,
          ),
        ),
      ),
    );
  }

  /// Build sleep timer control
  Widget _buildSleepTimerControl(BuildContext context, AudioPlayerState state) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showSleepTimerDialog(context);
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Icon(
            Icons.timer,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
            size: 20,
          ),
        ),
      ),
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
