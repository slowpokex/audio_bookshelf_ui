import 'package:flutter/material.dart';

/// Custom color palette inspired by the attractive muted green/gray design
/// Perfect for readers with calming, professional aesthetics
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // Primary Green Palette - Vibrant accent colors
  static const Color primaryGreen = Color(0xFF4CAF50); // Vibrant green for active states
  static const Color primaryGreenLight = Color(0xFF81C784); // Lighter green variant
  static const Color primaryGreenDark = Color(0xFF388E3C); // Darker green variant
  
  // Lime Green Accent - For highlights and active elements
  static const Color limeGreen = Color(0xFF8BC34A); // Lime green accent
  static const Color limeGreenLight = Color(0xFFAED581); // Light lime variant
  static const Color limeGreenDark = Color(0xFF689F38); // Dark lime variant

  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF8F9FA); // Pale cream/off-white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure white for cards
  static const Color lightSurfaceVariant = Color(0xFFF5F5F5); // Light gray variant
  static const Color lightOnBackground = Color(0xFF1A1A1A); // Dark text on light background
  static const Color lightOnSurface = Color(0xFF2D2D2D); // Dark text on surface
  static const Color lightOnSurfaceVariant = Color(0xFF666666); // Muted text color
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF1A1A1A); // Dark muted green/charcoal
  static const Color darkSurface = Color(0xFF2D2D2D); // Dark gray/green for cards
  static const Color darkSurfaceVariant = Color(0xFF3A3A3A); // Dark gray variant
  static const Color darkOnBackground = Color(0xFFFFFFFF); // White text on dark background
  static const Color darkOnSurface = Color(0xFFE0E0E0); // Light text on surface
  static const Color darkOnSurfaceVariant = Color(0xFFB0B0B0); // Muted light text

  // Neutral Grays
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Audio Player Specific Colors
  static const Color audioProgress = Color(0xFF4CAF50);
  static const Color audioProgressBackground = Color(0xFFE0E0E0);
  static const Color audioControl = Color(0xFF4CAF50);
  static const Color audioControlDisabled = Color(0xFF9E9E9E);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);

  // Border Colors
  static const Color borderLight = Color(0xFFE0E0E0);
  static const Color borderDark = Color(0xFF424242);

  // Overlay Colors
  static const Color overlayLight = Color(0x80000000);
  static const Color overlayDark = Color(0x80FFFFFF);

  /// Get the appropriate text color based on background brightness
  static Color getTextColorForBackground(Color backgroundColor) {
    // Calculate luminance to determine if background is light or dark
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? lightOnBackground : darkOnBackground;
  }

  /// Get the appropriate surface color based on theme brightness
  static Color getSurfaceColor(bool isDark) {
    return isDark ? darkSurface : lightSurface;
  }

  /// Get the appropriate background color based on theme brightness
  static Color getBackgroundColor(bool isDark) {
    return isDark ? darkBackground : lightBackground;
  }

  /// Get the appropriate accent color based on theme brightness
  static Color getAccentColor(bool isDark) {
    return isDark ? limeGreen : primaryGreen;
  }

  /// Get the appropriate muted text color based on theme brightness
  static Color getMutedTextColor(bool isDark) {
    return isDark ? darkOnSurfaceVariant : lightOnSurfaceVariant;
  }
}
