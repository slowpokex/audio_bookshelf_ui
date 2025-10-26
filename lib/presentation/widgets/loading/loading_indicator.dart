import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Custom loading indicator with circular progress and animated elements
class LoadingIndicator extends StatefulWidget {
  const LoadingIndicator({
    super.key,
    required this.progress,
    this.size = 150,
    this.color,
    this.backgroundColor,
    this.showParticles = true,
  });

  final double progress; // 0.0 to 1.0
  final double size;
  final Color? color;
  final Color? backgroundColor;
  final bool showParticles;

  @override
  State<LoadingIndicator> createState() => _LoadingIndicatorState();
}

class _LoadingIndicatorState extends State<LoadingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _particleController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _particleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    // Rotation animation
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Pulse animation
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Particle animation
    _particleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    if (widget.showParticles) {
      _particleController.repeat();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = widget.color ?? theme.colorScheme.primary;
    final backgroundColor = widget.backgroundColor ?? 
        (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1));
    
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
        _particleAnimation,
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
              // Background circle
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: backgroundColor,
                ),
              ),
              
              // Progress circle
              SizedBox(
                width: widget.size,
                height: widget.size,
                child: CustomPaint(
                  painter: ProgressCirclePainter(
                    progress: widget.progress,
                    color: primaryColor,
                    strokeWidth: widget.size * 0.08,
                  ),
                ),
              ),
              
              // Rotating elements
              Transform.rotate(
                angle: _rotationAnimation.value,
                child: _buildRotatingElements(primaryColor),
              ),
              
              // Pulse effect
              Transform.scale(
                scale: math.max(0.1, _pulseAnimation.value).toDouble(),
                child: Container(
                  width: widget.size * 0.3,
                  height: widget.size * 0.3,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withValues(alpha: 0.2),
                  ),
                ),
              ),
              
              // Center content
              _buildCenterContent(primaryColor),
              
              // Particles
              if (widget.showParticles)
                ..._buildParticles(primaryColor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRotatingElements(Color color) {
    return Stack(
      children: List.generate(8, (index) {
        final angle = (index * math.pi * 2) / 8;
        final radius = widget.size * 0.35;
        final x = math.cos(angle) * radius;
        final y = math.sin(angle) * radius;
        
        return Positioned(
          left: widget.size / 2 + x - 3,
          top: widget.size / 2 + y - 3,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.6),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCenterContent(Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.library_books,
          size: widget.size * 0.2,
          color: color,
        ),
        SizedBox(height: widget.size * 0.05),
        Text(
          '${(widget.progress * 100).toInt()}%',
          style: TextStyle(
            fontSize: widget.size * 0.12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  List<Widget> _buildParticles(Color color) {
    return List.generate(6, (index) {
      final angle = (index * math.pi * 2) / 6 + _particleAnimation.value * math.pi * 2;
      final radius = widget.size * 0.45;
      final x = math.cos(angle) * radius;
      final y = math.sin(angle) * radius;
      
      return Positioned(
        left: widget.size / 2 + x - 2,
        top: widget.size / 2 + y - 2,
        child: Opacity(
          opacity: (math.sin(_particleAnimation.value * math.pi * 2 + index) + 1) / 2,
          child: Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ),
      );
    });
  }
}

/// Custom painter for the progress circle
class ProgressCirclePainter extends CustomPainter {
  const ProgressCirclePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, backgroundPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is ProgressCirclePainter &&
        (oldDelegate.progress != progress ||
         oldDelegate.color != color ||
         oldDelegate.strokeWidth != strokeWidth);
  }
}
