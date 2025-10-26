import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:audio_bookshelf_ui/presentation/pages/add_audiobook_page.dart';
import 'package:audio_bookshelf_ui/presentation/blocs/audiobook/audiobook_bloc.dart';
import 'package:audio_bookshelf_ui/application/use_cases/audiobook_use_cases.dart';

void main() {
  group('AddAudiobookPage', () {
    late AudiobookBloc mockAudiobookBloc;

    setUp(() {
      mockAudiobookBloc = MockAudiobookBloc();
    });

    testWidgets('should display form fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AudiobookBloc>(
            create: (context) => mockAudiobookBloc,
            child: const AddAudiobookPage(),
          ),
        ),
      );

      // Check if the page title is displayed
      expect(find.text('Add Audiobook'), findsOneWidget);

      // Check if required form fields are present
      expect(find.text('Title *'), findsOneWidget);
      expect(find.text('Author *'), findsOneWidget);
      expect(find.text('Narrator'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Genre'), findsOneWidget);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text('ISBN'), findsOneWidget);
      expect(find.text('Publisher'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);

      // Check if file selection buttons are present
      expect(find.text('Select Audio File'), findsOneWidget);
      expect(find.text('Select Cover Image'), findsOneWidget);

      // Check if save button is present
      expect(find.text('Add Audiobook'), findsOneWidget);
    });

    testWidgets('should validate required fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AudiobookBloc>(
            create: (context) => mockAudiobookBloc,
            child: const AddAudiobookPage(),
          ),
        ),
      );

      // Try to save without filling required fields
      await tester.tap(find.text('Add Audiobook'));
      await tester.pump();

      // Should show validation error for title
      expect(find.text('Title is required'), findsOneWidget);
    });

    testWidgets('should show audio file selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AudiobookBloc>(
            create: (context) => mockAudiobookBloc,
            child: const AddAudiobookPage(),
          ),
        ),
      );

      // Check if audio file selection button is present
      expect(find.text('Select Audio File'), findsOneWidget);
      expect(find.text('Supported formats: mp3, m4a, m4b, aac, flac, ogg, wav'), findsOneWidget);
    });

    testWidgets('should show cover image selection', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AudiobookBloc>(
            create: (context) => mockAudiobookBloc,
            child: const AddAudiobookPage(),
          ),
        ),
      );

      // Check if cover image selection button is present
      expect(find.text('Select Cover Image'), findsOneWidget);
      expect(find.text('Supported formats: jpg, jpeg, png, webp'), findsOneWidget);
    });

    testWidgets('should show series information section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AudiobookBloc>(
            create: (context) => mockAudiobookBloc,
            child: const AddAudiobookPage(),
          ),
        ),
      );

      // Check if series fields are present
      expect(find.text('Series'), findsOneWidget);
      expect(find.text('Series Order'), findsOneWidget);
    });

    testWidgets('should show tags section', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AudiobookBloc>(
            create: (context) => mockAudiobookBloc,
            child: const AddAudiobookPage(),
          ),
        ),
      );

      // Check if tags field is present
      expect(find.text('Tags'), findsOneWidget);
      expect(find.text('Enter tags separated by commas'), findsOneWidget);
      expect(find.text('Example: fiction, mystery, thriller, romance'), findsOneWidget);
    });
  });
}

class MockAudiobookBloc extends MockBloc<AudiobookEvent, AudiobookState> implements AudiobookBloc {
  MockAudiobookBloc() : super(AudiobookInitialState());
  
  @override
  Future<void> add(AudiobookEvent event) async {
    // Mock implementation
  }
}

class MockBloc<E, S> extends Bloc<E, S> {
  MockBloc(S initialState) : super(initialState);
}
