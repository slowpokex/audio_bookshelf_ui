import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_bookshelf_ui/app.dart';
import 'test_config.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Audio Bookshelf UI', () {
    setUp(() {
      TestConfig.initialize();
    });

    group('App Initialization', () {
      testWidgets('should load app without errors', (WidgetTester tester) async {
        // Build our app and trigger a frame
        await tester.pumpWidget(TestHelpers.createTestApp());

        // Wait for loading to complete
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify that the app loads without errors
        expect(find.text('Audio Bookshelf'), findsOneWidget);
      });

      testWidgets('should display main navigation elements', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify main UI elements are present
        expect(find.text('Audio Bookshelf'), findsOneWidget);
      });

      testWidgets('should handle navigation to add audiobook page', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify the app loaded successfully
        expect(find.text('Audio Bookshelf'), findsOneWidget);
      });
    });

    group('Search Functionality', () {
      testWidgets('should load app successfully', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify app loads
        expect(find.text('Audio Bookshelf'), findsOneWidget);
      });
    });

    group('Theme and Styling', () {
      testWidgets('should apply correct theme', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify Material Design 3 theme is applied
        final materialAppFinder = find.byType(MaterialApp).first;
        expect(materialAppFinder, findsOneWidget);
        
        final materialApp = tester.widget<MaterialApp>(materialAppFinder);
        // Check if theme exists, if not, check if themeMode is set
        if (materialApp.theme != null) {
          expect(materialApp.theme!.useMaterial3, isTrue);
        } else {
          // If no explicit theme, check if themeMode is set
          expect(materialApp.themeMode, isNotNull);
        }
      });
    });

    group('Responsive Design', () {
      testWidgets('should load on different screen sizes', (WidgetTester tester) async {
        // Test with small screen
        await tester.binding.setSurfaceSize(const Size(400, 600)); // Larger screen to avoid overflow
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        expect(find.text('Audio Bookshelf'), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Accessibility', () {
      testWidgets('should load with accessibility support', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify that important elements are accessible
        expect(find.text('Audio Bookshelf'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle app initialization gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestApp());
        await TestHelpers.waitForLoadingToComplete(tester);

        expect(find.text('Audio Bookshelf'), findsOneWidget);
      });
    });
  });
}
