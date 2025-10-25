import 'package:flutter/material.dart';

/// A simpler, more robust animated logo for mobile devices
class SimpleAnimatedLogo extends StatefulWidget {
  const SimpleAnimatedLogo({
    super.key,
    this.size = 100,
    this.showAnimation = true,
    this.color,
  });

  final double size;
  final bool showAnimation;
  final Color? color;

  @override
  State<SimpleAnimatedLogo> createState() => _SimpleAnimatedLogoState();
}

class _SimpleAnimatedLogoState extends State<SimpleAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    if (widget.showAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final logoColor = widget.color ?? (isDark ? Colors.white : Colors.black87);
    
    return AnimatedBuilder(
      animation: _controller,
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
              // Simple book stack
              _buildSimpleBookStack(logoColor),
              
              // "OOKS" text
              Positioned(
                right: -widget.size * 0.15,
                child: _buildOOKSText(logoColor),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSimpleBookStack(Color color) {
    final bookSize = widget.size * 0.4;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Top book
        Transform.rotate(
          angle: -_rotationAnimation.value,
          child: _buildSimpleBook(
            color,
            bookSize,
            0.9,
          ),
        ),
        
        const SizedBox(height: 4),
        
        // Bottom book
        Transform.rotate(
          angle: _rotationAnimation.value,
          child: _buildSimpleBook(
            color,
            bookSize,
            1.0,
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleBook(Color color, double size, double opacity) {
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
