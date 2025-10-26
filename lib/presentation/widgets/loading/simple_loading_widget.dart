import 'package:flutter/material.dart';

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
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showLogo) ...[
            Icon(
              Icons.audiotrack,
              size: size,
              color: theme.colorScheme.primary,
            ),
            if (message != null) const SizedBox(height: 24),
          ],
          
          if (message != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                message!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
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
