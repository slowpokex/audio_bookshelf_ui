import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:audio_bookshelf_ui/core/services/theme_service.dart';
import 'package:audio_bookshelf_ui/presentation/blocs/theme/theme_bloc.dart';

void main() {
  group('Theme System Tests', () {
    late ThemeService themeService;
    
    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService.instance;
    });
    
    testWidgets('Theme service initialization', (WidgetTester tester) async {
      await themeService.initialize();
      
      // Default should be system theme
      expect(themeService.currentThemeMode, ThemeMode.system);
      expect(themeService.isSystemTheme, true);
    });
    
    testWidgets('Theme mode switching', (WidgetTester tester) async {
      await themeService.initialize();
      
      // Test switching to light theme
      await themeService.setThemeMode(ThemeMode.light);
      expect(themeService.currentThemeMode, ThemeMode.light);
      expect(themeService.getThemeModeDisplayName(), 'Light');
      
      // Test switching to dark theme
      await themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.currentThemeMode, ThemeMode.dark);
      expect(themeService.getThemeModeDisplayName(), 'Dark');
      
      // Test switching to system theme
      await themeService.setThemeMode(ThemeMode.system);
      expect(themeService.currentThemeMode, ThemeMode.system);
      expect(themeService.getThemeModeDisplayName(), 'System');
    });
    
    testWidgets('Theme toggle functionality', (WidgetTester tester) async {
      await themeService.initialize();
      
      // Start with system theme
      await themeService.setThemeMode(ThemeMode.system);
      expect(themeService.currentThemeMode, ThemeMode.system);
      
      // Toggle should switch to light
      await themeService.toggleTheme();
      expect(themeService.currentThemeMode, ThemeMode.light);
      
      // Toggle should switch to dark
      await themeService.toggleTheme();
      expect(themeService.currentThemeMode, ThemeMode.dark);
      
      // Toggle should switch back to light
      await themeService.toggleTheme();
      expect(themeService.currentThemeMode, ThemeMode.light);
    });
    
    testWidgets('Theme persistence', (WidgetTester tester) async {
      await themeService.initialize();
      
      // Set theme to dark
      await themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.currentThemeMode, ThemeMode.dark);
      
      // Create new instance to simulate app restart
      final newThemeService = ThemeService.instance;
      await newThemeService.initialize();
      
      // Should persist the dark theme
      expect(newThemeService.currentThemeMode, ThemeMode.dark);
    });
    
    testWidgets('Theme Bloc state management', (WidgetTester tester) async {
      final themeBloc = ThemeBloc(themeService: themeService);
      
      // Initial state should be loading
      expect(themeBloc.state, isA<ThemeInitialState>());
      
      // Initialize theme
      themeBloc.add(const ThemeInitializeEvent());
      await tester.pump();
      
      // Should transition to loaded state
      expect(themeBloc.state, isA<ThemeLoadedState>());
      
      // Test setting theme mode
      themeBloc.add(const ThemeSetModeEvent(ThemeMode.dark));
      await tester.pump();
      
      final loadedState = themeBloc.state as ThemeLoadedState;
      expect(loadedState.currentMode, ThemeMode.dark);
      expect(loadedState.isDark, true);
      expect(loadedState.isLight, false);
      expect(loadedState.isSystem, false);
    });
    
    testWidgets('Available theme modes', (WidgetTester tester) async {
      final availableModes = themeService.getAvailableThemeModes();
      
      expect(availableModes.length, 3);
      expect(availableModes.any((mode) => mode.mode == ThemeMode.light), true);
      expect(availableModes.any((mode) => mode.mode == ThemeMode.dark), true);
      expect(availableModes.any((mode) => mode.mode == ThemeMode.system), true);
      
      // Check that each mode has proper display information
      for (final mode in availableModes) {
        expect(mode.name, isNotEmpty);
        expect(mode.description, isNotEmpty);
        expect(mode.icon, isNotNull);
      }
    });
    
    testWidgets('Theme reset functionality', (WidgetTester tester) async {
      await themeService.initialize();
      
      // Set to dark theme
      await themeService.setThemeMode(ThemeMode.dark);
      expect(themeService.currentThemeMode, ThemeMode.dark);
      
      // Reset to default
      await themeService.resetToDefault();
      expect(themeService.currentThemeMode, ThemeMode.system);
    });
  });
}
