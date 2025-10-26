import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Service for managing theme preferences and persistence
/// Handles theme mode switching and storage using SharedPreferences
class ThemeService {
  // Private constructor to prevent instantiation
  ThemeService._();
  
  static final ThemeService _instance = ThemeService._();
  static ThemeService get instance => _instance;
  
  // Constants
  static const String _themeModeKey = 'theme_mode';
  static const String _isFirstLaunchKey = 'is_first_launch';
  
  // Current theme mode
  ThemeMode _currentThemeMode = ThemeMode.system;
  
  // Getters
  ThemeMode get currentThemeMode => _currentThemeMode;
  
  /// Initialize the theme service
  /// Loads saved theme preferences from SharedPreferences
  Future<void> initialize() async {
    try {
      AppLogger.logAppLifecycle('Initializing theme service');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode preference
      final themeModeIndex = prefs.getInt(_themeModeKey);
      if (themeModeIndex != null && themeModeIndex < ThemeMode.values.length) {
        _currentThemeMode = ThemeMode.values[themeModeIndex];
        AppLogger.logAppLifecycle('Loaded theme mode: ${_currentThemeMode.name}');
      } else {
        // First launch - use system default
        _currentThemeMode = ThemeMode.system;
        await _saveThemeMode(_currentThemeMode);
        AppLogger.logAppLifecycle('First launch - using system theme mode');
      }
      
      AppLogger.logAppLifecycle('Theme service initialized successfully');
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to initialize theme service', stackTrace);
      // Fallback to system theme mode
      _currentThemeMode = ThemeMode.system;
    }
  }
  
  /// Set the theme mode and persist it
  /// [themeMode] - The theme mode to set (light, dark, or system)
  Future<void> setThemeMode(ThemeMode themeMode) async {
    try {
      if (_currentThemeMode == themeMode) {
        return; // No change needed
      }
      
      AppLogger.logAppLifecycle('Setting theme mode to: ${themeMode.name}');
      
      _currentThemeMode = themeMode;
      await _saveThemeMode(themeMode);
      
      AppLogger.logAppLifecycle('Theme mode updated successfully');
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to set theme mode', stackTrace);
      rethrow;
    }
  }
  
  /// Toggle between light and dark themes
  /// If current mode is system, switches to light
  /// If current mode is light, switches to dark
  /// If current mode is dark, switches to light
  Future<void> toggleTheme() async {
    ThemeMode newMode;
    
    switch (_currentThemeMode) {
      case ThemeMode.system:
        newMode = ThemeMode.light;
        break;
      case ThemeMode.light:
        newMode = ThemeMode.dark;
        break;
      case ThemeMode.dark:
        newMode = ThemeMode.light;
        break;
    }
    
    await setThemeMode(newMode);
  }
  
  /// Get the effective theme mode based on system brightness
  /// Returns the actual theme mode that should be used
  ThemeMode getEffectiveThemeMode(BuildContext context) {
    if (_currentThemeMode == ThemeMode.system) {
      final brightness = MediaQuery.of(context).platformBrightness;
      return brightness == Brightness.dark ? ThemeMode.dark : ThemeMode.light;
    }
    return _currentThemeMode;
  }
  
  /// Check if the current theme is dark
  /// Takes into account system brightness when theme mode is system
  bool isDarkTheme(BuildContext context) {
    final effectiveMode = getEffectiveThemeMode(context);
    return effectiveMode == ThemeMode.dark;
  }
  
  /// Check if the current theme is light
  /// Takes into account system brightness when theme mode is system
  bool isLightTheme(BuildContext context) {
    final effectiveMode = getEffectiveThemeMode(context);
    return effectiveMode == ThemeMode.light;
  }
  
  /// Check if the theme mode is set to system
  bool get isSystemTheme => _currentThemeMode == ThemeMode.system;
  
  /// Get theme mode display name for UI
  String getThemeModeDisplayName() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  /// Get theme mode description for UI
  String getThemeModeDescription() {
    switch (_currentThemeMode) {
      case ThemeMode.light:
        return 'Always use light theme';
      case ThemeMode.dark:
        return 'Always use dark theme';
      case ThemeMode.system:
        return 'Follow system theme setting';
    }
  }
  
  /// Reset theme preferences to default (system)
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
  }
  
  /// Clear all theme preferences
  Future<void> clearPreferences() async {
    try {
      AppLogger.logAppLifecycle('Clearing theme preferences');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_themeModeKey);
      
      _currentThemeMode = ThemeMode.system;
      
      AppLogger.logAppLifecycle('Theme preferences cleared successfully');
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to clear theme preferences', stackTrace);
      rethrow;
    }
  }
  
  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode(ThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeModeKey, themeMode.index);
      
      AppLogger.logAppLifecycle('Theme mode saved: ${themeMode.name}');
    } catch (e, stackTrace) {
      AppLogger.logError('Failed to save theme mode', stackTrace);
      rethrow;
    }
  }
  
  /// Get all available theme modes for UI selection
  List<ThemeModeOption> getAvailableThemeModes() {
    return [
      ThemeModeOption(
        mode: ThemeMode.light,
        name: 'Light',
        description: 'Always use light theme',
        icon: Icons.light_mode,
      ),
      ThemeModeOption(
        mode: ThemeMode.dark,
        name: 'Dark',
        description: 'Always use dark theme',
        icon: Icons.dark_mode,
      ),
      ThemeModeOption(
        mode: ThemeMode.system,
        name: 'System',
        description: 'Follow system theme setting',
        icon: Icons.brightness_auto,
      ),
    ];
  }
  
  /// Check if this is the first app launch
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey(_isFirstLaunchKey);
    } catch (e) {
      AppLogger.logError('Failed to check first launch status', StackTrace.current);
      return false;
    }
  }
  
  /// Mark that the app has been launched before
  Future<void> markAsLaunched() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, true);
    } catch (e) {
      AppLogger.logError('Failed to mark app as launched', StackTrace.current);
    }
  }
}

/// Data class for theme mode options in UI
class ThemeModeOption {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;
  
  const ThemeModeOption({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
  });
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ThemeModeOption && other.mode == mode;
  }
  
  @override
  int get hashCode => mode.hashCode;
  
  @override
  String toString() => 'ThemeModeOption(mode: $mode, name: $name)';
}
