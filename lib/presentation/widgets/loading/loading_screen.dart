import 'package:flutter/material.dart';
import 'dart:io';
import 'animated_books_logo.dart';
import 'simple_animated_logo.dart';
import 'loading_indicator.dart';

/// A beautiful loading screen with animated logo and smooth transitions
class LoadingScreen extends StatefulWidget {
  const LoadingScreen({
    super.key,
    this.onLoadingComplete,
    this.loadingDuration = const Duration(seconds: 3),
    this.showProgress = true,
  });

  final VoidCallback? onLoadingComplete;
  final Duration loadingDuration;
  final bool showProgress;

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _progressController;

  late Animation<double> _logoAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
  }

  void _initializeAnimations() {
    // Logo entrance animation
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );

    // Fade animation for text
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );

    // Scale animation for the entire screen
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    );

    // Progress animation
    _progressController = AnimationController(
      duration: widget.loadingDuration,
      vsync: this,
    );
    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );
  }

  void _startLoadingSequence() async {
    // Start logo animation
    _logoController.forward();
    
    // Wait a bit then start fade animation
    await Future.delayed(const Duration(milliseconds: 400));
    _fadeController.forward();
    
    // Start progress animation
    _progressController.forward();
    
    // Complete loading after duration
    await Future.delayed(widget.loadingDuration);
    
    if (mounted) {
      // Start exit animation
      _scaleController.forward();
      
      // Wait for exit animation to complete
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Call completion callback
      widget.onLoadingComplete?.call();
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoAnimation,
        _fadeAnimation,
        _scaleAnimation,
        _progressAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 - (_scaleAnimation.value * 0.1),
          child: Opacity(
            opacity: 1.0 - _scaleAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF1A1A1A),
                          const Color(0xFF2D2D2D),
                          const Color(0xFF1A1A1A),
                        ]
                      : [
                          const Color(0xFFF8F9FA),
                          const Color(0xFFE9ECEF),
                          const Color(0xFFF8F9FA),
                        ],
                ),
              ),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo section
                        Transform.scale(
                          scale: _logoAnimation.value,
                          child: Platform.isAndroid || Platform.isIOS
                              ? const SimpleAnimatedLogo(
                                  size: 120,
                                  showAnimation: true,
                                )
                              : const AnimatedBooksLogo(
                                  size: 120,
                                  showAnimation: true,
                                ),
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // App name with fade animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Audio Bookshelf',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w300,
                              letterSpacing: 2.0,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Subtitle with fade animation
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Your Personal Audio Library',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: isDark ? Colors.white70 : Colors.black54,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 60),
                        
                        // Loading indicator
                        if (widget.showProgress)
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                LoadingIndicator(
                                  progress: _progressAnimation.value,
                                  size: 200,
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Loading your library...',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: isDark ? Colors.white60 : Colors.black45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
