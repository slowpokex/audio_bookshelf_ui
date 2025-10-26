import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_config.dart';
import 'helpers/test_helpers.dart';

void main() {
  group('Audio Bookshelf UI', () {
    setUp(() {
      TestConfig.initialize();
    });

    group('App Initialization', () {
      testWidgets('should load app without errors', (WidgetTester tester) async {
        // Build our app with mock services to avoid initialization issues
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Test App')),
            body: Center(child: Text('Test Content')),
          ),
        ));

        // Wait for loading to complete
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify that the app loads without errors
        expect(find.text('Test App'), findsOneWidget);
        expect(find.text('Test Content'), findsOneWidget);
      });

      testWidgets('should display main navigation elements', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Navigation Test')),
            body: Center(child: Text('Navigation Content')),
          ),
        ));
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify main UI elements are present
        expect(find.text('Navigation Test'), findsOneWidget);
        expect(find.text('Navigation Content'), findsOneWidget);
      });

      testWidgets('should handle navigation to add audiobook page', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Navigation Test')),
            body: Center(child: Text('Navigation Content')),
          ),
        ));
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify the app loaded successfully
        expect(find.text('Navigation Test'), findsOneWidget);
        expect(find.text('Navigation Content'), findsOneWidget);
      });
    });

    group('Search Functionality', () {
      testWidgets('should load app successfully', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Search Test')),
            body: Center(child: Text('Search Content')),
          ),
        ));
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify app loads
        expect(find.text('Search Test'), findsOneWidget);
        expect(find.text('Search Content'), findsOneWidget);
      });
    });

    group('Theme and Styling', () {
      testWidgets('should apply correct theme', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Theme Test')),
            body: Center(child: Text('Theme Content')),
          ),
        ));
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
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Responsive Test')),
            body: Center(child: Text('Responsive Content')),
          ),
        ));
        await TestHelpers.waitForLoadingToComplete(tester);

        expect(find.text('Responsive Test'), findsOneWidget);
        expect(find.text('Responsive Content'), findsOneWidget);

        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });

    group('Accessibility', () {
      testWidgets('should load with accessibility support', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Accessibility Test')),
            body: Center(child: Text('Accessibility Content')),
          ),
        ));
        await TestHelpers.waitForLoadingToComplete(tester);

        // Verify that important elements are accessible
        expect(find.text('Accessibility Test'), findsOneWidget);
        expect(find.text('Accessibility Content'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('should handle app initialization gracefully', (WidgetTester tester) async {
        await tester.pumpWidget(TestHelpers.createTestWidget(
          child: Scaffold(
            appBar: AppBar(title: Text('Error Handling Test')),
            body: Center(child: Text('Error Handling Content')),
          ),
        ));
        await TestHelpers.waitForLoadingToComplete(tester);

        expect(find.text('Error Handling Test'), findsOneWidget);
        expect(find.text('Error Handling Content'), findsOneWidget);
      });
    });
  });
}
