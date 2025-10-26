import 'package:flutter/material.dart';
import 'dart:io';
import 'animated_books_logo.dart';
import 'simple_animated_logo.dart';

/// A simple loading widget that can be used throughout the app
class SimpleLoadingWidget extends StatelessWidget {
  const SimpleLoadingWidget({
    super.key,
    this.message,
    this.size = 60,
    this.showLogo = true,
  });

  final String? message;
  final double size;
  final bool showLogo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLogo)
            Platform.isAndroid || Platform.isIOS
                ? SimpleAnimatedLogo(
                    size: size,
                    showAnimation: true,
                    color: isDark ? Colors.white : Colors.black87,
                  )
                : AnimatedBooksLogo(
                    size: size,
                    showAnimation: true,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
          
          if (showLogo && message != null)
            const SizedBox(height: 24),
          
          if (message != null)
            Text(
              message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          
          if (!showLogo)
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
