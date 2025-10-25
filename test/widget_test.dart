// This is a basic Flutter widget test for Audio Bookshelf UI.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:audio_bookshelf_ui/app.dart';

void main() {
  testWidgets('Audio Bookshelf UI smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AudioBookshelfApp());

    // Verify that the app loads without errors
    expect(find.text('Audio Bookshelf'), findsOneWidget);
    
    // Verify that the search bar is present
    expect(find.byType(TextField), findsOneWidget);
  });
}
