import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Animated logo inspired by the "BOOKS" design with stacked books forming a "B"
class AnimatedBooksLogo extends StatefulWidget {
  const AnimatedBooksLogo({
    super.key,
    this.size = 100,
    this.showAnimation = true,
    this.color,
  });

  final double size;
  final bool showAnimation;
  final Color? color;

  @override
  State<AnimatedBooksLogo> createState() => _AnimatedBooksLogoState();
}

class _AnimatedBooksLogoState extends State<AnimatedBooksLogo>
    with TickerProviderStateMixin {
  late AnimationController _stackController;
  late AnimationController _shadowController;
  late AnimationController _glowController;
  
  late Animation<double> _stackAnimation;
  late Animation<double> _shadowAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    
    if (widget.showAnimation) {
      _startAnimations();
    }
  }

  void _initializeAnimations() {
    // Stack animation - books coming together
    _stackController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _stackAnimation = CurvedAnimation(
      parent: _stackController,
      curve: Curves.elasticOut,
    );

    // Shadow animation
    _shadowController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _shadowAnimation = CurvedAnimation(
      parent: _shadowController,
      curve: Curves.easeInOut,
    );

    // Glow animation for the logo
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _stackController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _shadowController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _glowController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _stackController.dispose();
    _shadowController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logoColor = widget.color ?? (isDark ? Colors.white : Colors.black87);
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _stackAnimation,
        _shadowAnimation,
        _glowAnimation,
      ]),
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          constraints: BoxConstraints(
            minWidth: widget.size,
            minHeight: widget.size,
            maxWidth: widget.size,
            maxHeight: widget.size,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              if (widget.showAnimation)
                Transform.scale(
                  scale: math.max(0.5, 1.0 + (_glowAnimation.value * 0.1)).toDouble(),
                  child: Container(
                    width: widget.size,
                    height: widget.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: logoColor.withValues(alpha: 0.1 + (_glowAnimation.value * 0.1)),
                          blurRadius: 20 + (_glowAnimation.value * 10),
                          spreadRadius: 5 + (_glowAnimation.value * 5),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Main logo
              _buildBooksLogo(logoColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBooksLogo(Color color) {
    final bookSize = widget.size * 0.4;
    final spacing = widget.size * 0.05;
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // Shadow
        if (widget.showAnimation)
          Transform.translate(
            offset: Offset(
              2 + (_shadowAnimation.value * 3),
              2 + (_shadowAnimation.value * 3),
            ),
            child: _buildBookStack(
              color.withValues(alpha: 0.2),
              bookSize,
              spacing,
              false,
            ),
          ),
        
        // Main books
        _buildBookStack(
          color,
          bookSize,
          spacing,
          true,
        ),
        
        // "OOKS" text
        Positioned(
          right: -widget.size * 0.15,
          child: _buildOOKSText(color),
        ),
      ],
    );
  }

  Widget _buildBookStack(Color color, double bookSize, double spacing, bool isMain) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top book
        Transform.translate(
          offset: Offset(
            0,
            -math.max(0, spacing * (1 - _stackAnimation.value)).toDouble(),
          ),
          child: Transform.rotate(
            angle: -0.1 * (1 - _stackAnimation.value),
            child: _buildBook(
              color,
              bookSize,
              isMain ? 0.9 : 0.7,
            ),
          ),
        ),
        
        SizedBox(height: math.max(0, spacing * (1 - _stackAnimation.value)).toDouble()),
        
        // Bottom book
        Transform.translate(
          offset: Offset(
            0,
            math.max(0, spacing * (1 - _stackAnimation.value)).toDouble(),
          ),
          child: Transform.rotate(
            angle: 0.1 * (1 - _stackAnimation.value),
            child: _buildBook(
              color,
              bookSize,
              isMain ? 1.0 : 0.8,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBook(Color color, double size, double opacity) {
    return Container(
      width: size,
      height: size * 0.7,
      decoration: BoxDecoration(
        color: color.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(size * 0.1),
        border: Border.all(
          color: color.withValues(alpha: opacity * 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Book spine
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: size * 0.15,
              decoration: BoxDecoration(
                color: color.withValues(alpha: opacity * 0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
              ),
            ),
          ),
          
          // Book pages
          Positioned(
            left: size * 0.15,
            right: size * 0.05,
            top: size * 0.05,
            bottom: size * 0.05,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: opacity * 0.9),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Column(
                children: List.generate(3, (index) {
                  return Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    color: color.withValues(alpha: opacity * 0.3),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOOKSText(Color color) {
    return Text(
      'OOKS',
      style: TextStyle(
        fontSize: widget.size * 0.25,
        fontWeight: FontWeight.w300,
        letterSpacing: 2.0,
        color: color,
        fontFamily: 'monospace',
      ),
    );
  }
}
