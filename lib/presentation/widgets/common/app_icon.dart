import 'package:flutter/material.dart';
import 'dart:io';
import '../loading/animated_books_logo.dart';
import '../loading/simple_animated_logo.dart';

/// App icon widget that can be used in various places
class AppIcon extends StatelessWidget {
  const AppIcon({
    super.key,
    this.size = 40,
    this.showAnimation = false,
    this.color,
  });

  final double size;
  final bool showAnimation;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Platform.isAndroid || Platform.isIOS
        ? SimpleAnimatedLogo(
            size: size,
            showAnimation: showAnimation,
            color: color,
          )
        : AnimatedBooksLogo(
            size: size,
            showAnimation: showAnimation,
            color: color,
          );
  }
}

/// App icon for app bars and navigation
class AppBarIcon extends StatelessWidget {
  const AppBarIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppIcon(
      size: 32,
      showAnimation: false,
    );
  }
}

/// Large app icon for splash screens and welcome pages
class LargeAppIcon extends StatelessWidget {
  const LargeAppIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppIcon(
      size: 120,
      showAnimation: true,
    );
  }
}
