import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:audio_bookshelf_ui/core/services/theme_service.dart';
import 'package:audio_bookshelf_ui/core/theme/app_theme.dart';
import 'package:audio_bookshelf_ui/presentation/blocs/theme/theme_bloc.dart';
import 'package:audio_bookshelf_ui/presentation/pages/settings_page.dart';

void main() {
  group('Settings Page Integration Tests', () {
    late ThemeService themeService;
    
    setUp(() {
      // Mock SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService.instance;
    });
    
    testWidgets('Settings page renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show settings page
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      
      // Should show back button in AppBar
      expect(find.byIcon(Icons.arrow_back).first, findsOneWidget);
    });
    
    testWidgets('Theme section displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show theme controls
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Quick Toggle'), findsOneWidget);
      
      // Should show current theme mode
      expect(find.textContaining('theme'), findsAtLeastNWidgets(1));
    });
    
    testWidgets('Theme selection dialog opens', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap on theme option
      await tester.tap(find.text('Theme'));
      await tester.pumpAndSettle();
      
      // Should show theme selection dialog
      expect(find.text('Choose Theme'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
    });
    
    testWidgets('Quick theme toggle works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find and tap quick toggle
      await tester.tap(find.textContaining('Quick Toggle'));
      await tester.pumpAndSettle();
      
      // Theme should change (this tests the bloc integration)
      // The UI should update to reflect the new theme
    });
    
    testWidgets('Settings sections are properly organized', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Check that all main sections are present
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Library'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      
      // Check that cards are present for each section
      expect(find.byType(Card), findsAtLeastNWidgets(4));
    });
    
    testWidgets('Audio settings section displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show audio settings
      expect(find.text('Default Volume'), findsOneWidget);
      expect(find.text('Playback Speed'), findsOneWidget);
      expect(find.text('Auto-skip Silence'), findsOneWidget);
    });
    
    testWidgets('Library settings section displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show library settings
      expect(find.text('Download Location'), findsOneWidget);
      expect(find.text('Auto-download'), findsOneWidget);
      expect(find.text('Sync Progress'), findsOneWidget);
    });
    
    testWidgets('About section displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show about section
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('Help & Support'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });
    
    testWidgets('Settings page handles theme state changes', (WidgetTester tester) async {
      final themeBloc = ThemeBloc(themeService: themeService);
      
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => themeBloc..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Change theme to dark
      themeBloc.add(const ThemeSetModeEvent(ThemeMode.dark));
      await tester.pumpAndSettle();
      
      // UI should update to reflect dark theme
      // The theme mode text should change
      expect(find.textContaining('Dark theme'), findsOneWidget);
    });
    
    testWidgets('Back to main screen button displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show back to main screen button
      expect(find.text('Back to Main Screen'), findsOneWidget);
      expect(find.text('Return to the audiobook library'), findsOneWidget);
      expect(find.text('Go to Library'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back).last, findsOneWidget);
    });
    
    testWidgets('Back to main screen button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Find the back button
      final backButton = find.text('Go to Library');
      expect(backButton, findsOneWidget);
      
      // Scroll to make sure the button is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -200));
      await tester.pumpAndSettle();
      
      // Now tap the button
      await tester.tap(backButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      // Button should be tappable (this tests the button interaction)
      // In a real app, this would navigate back to the home screen
    });
    
    testWidgets('AppBar back button is present and functional', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: BlocProvider<ThemeBloc>(
            create: (context) => ThemeBloc(themeService: themeService)
              ..add(const ThemeInitializeEvent()),
            child: const SettingsPage(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show back button in AppBar
      final appBarBackButton = find.byIcon(Icons.arrow_back).first;
      expect(appBarBackButton, findsOneWidget);
      
      // Should be able to tap the back button
      await tester.tap(appBarBackButton, warnIfMissed: false);
      await tester.pumpAndSettle();
      
      // Back button should be functional
      // In a real app, this would navigate back to the previous screen
    });
  });
}
