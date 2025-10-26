import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:audio_bookshelf_ui/app.dart';
import 'package:audio_bookshelf_ui/presentation/blocs/audiobook/audiobook_bloc.dart';
import 'package:audio_bookshelf_ui/application/use_cases/audiobook_use_cases.dart';
import 'package:audio_bookshelf_ui/core/utils/result.dart';

// Mock classes
class MockAudiobookBloc extends Mock implements AudiobookBloc {
  @override
  Stream<AudiobookState> get stream => Stream.value(AudiobookInitialState());

  @override
  AudiobookState get state => AudiobookInitialState();

  @override
  Future<void> close() async {}
}
class MockGetAudiobooksUseCase extends Mock implements GetAudiobooksUseCase {}
class MockGetAudiobookUseCase extends Mock implements GetAudiobookUseCase {}
class MockCreateAudiobookUseCase extends Mock implements CreateAudiobookUseCase {}
class MockUpdateAudiobookUseCase extends Mock implements UpdateAudiobookUseCase {}
class MockDeleteAudiobookUseCase extends Mock implements DeleteAudiobookUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}
class MockRateAudiobookUseCase extends Mock implements RateAudiobookUseCase {}
class MockSearchAudiobooksUseCase extends Mock implements SearchAudiobooksUseCase {}
class MockGetRecommendationsUseCase extends Mock implements GetRecommendationsUseCase {}
class MockAudiobookRepository extends Mock implements AudiobookRepository {}

/// Test helpers for Audio Bookshelf UI tests
class TestHelpers {
  /// Creates a test widget with proper dependencies
  static Widget createTestWidget({
    required Widget child,
    AudiobookBloc? audiobookBloc,
  }) {
    final mockBloc = audiobookBloc ?? _createMockAudiobookBloc();
    
    return MaterialApp(
      home: BlocProvider<AudiobookBloc>(
        create: (context) => mockBloc,
        child: child,
      ),
    );
  }

  /// Creates a test widget with the main app
  static Widget createTestApp({
    AudiobookBloc? audiobookBloc,
  }) {
    final mockBloc = audiobookBloc ?? _createMockAudiobookBloc();
    
    return MaterialApp(
      home: BlocProvider<AudiobookBloc>(
        create: (context) => mockBloc,
        child: const AudioBookshelfApp(),
      ),
    );
  }

  /// Creates a mock AudiobookBloc with default behavior
  static AudiobookBloc _createMockAudiobookBloc() {
    // For now, return a simple mock that doesn't require complex setup
    // This is a simplified approach for basic widget testing
    return MockAudiobookBloc();
  }

  /// Waits for loading to complete in tests
  static Future<void> waitForLoadingToComplete(WidgetTester tester) async {
    // Wait for any loading indicators to disappear with timeout
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait
    
    while (find.byType(CircularProgressIndicator).evaluate().isNotEmpty && attempts < maxAttempts) {
      await tester.pump(const Duration(milliseconds: 100));
      attempts++;
    }
    
    // Wait for any pending timers with shorter timeout
    try {
      await tester.pumpAndSettle(const Duration(seconds: 2));
    } catch (e) {
      // If pumpAndSettle times out, just pump a few times
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
  }

  /// Waits for specific text to appear
  static Future<void> waitForText(WidgetTester tester, String text) async {
    await tester.pumpAndSettle();
    int attempts = 0;
    const maxAttempts = 50; // 5 seconds max wait
    
    while (find.text(text).evaluate().isEmpty && attempts < maxAttempts) {
      await tester.pump(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  /// Creates a mock use case
  static T createMockUseCase<T>() {
    return Mock() as T;
  }

  /// Sets up common test expectations
  static void setupCommonMocks() {
    // Add common mock setups here
  }
}

/// Extension methods for WidgetTester
extension WidgetTesterExtensions on WidgetTester {
  /// Pumps and settles with a timeout
  Future<void> pumpAndSettleWithTimeout([Duration? timeout]) async {
    await pumpAndSettle(timeout ?? const Duration(seconds: 5));
  }

  /// Waits for a specific widget to appear
  Future<void> waitForWidget(Finder finder, {Duration? timeout}) async {
    final maxAttempts = (timeout?.inMilliseconds ?? 5000) ~/ 100;
    int attempts = 0;
    
    while (finder.evaluate().isEmpty && attempts < maxAttempts) {
      await pump(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  /// Taps a widget and waits for it to settle
  Future<void> tapAndSettle(Finder finder) async {
    await tap(finder);
    await pumpAndSettle();
  }

  /// Enters text and waits for it to settle
  Future<void> enterTextAndSettle(Finder finder, String text) async {
    await enterText(finder, text);
    await pumpAndSettle();
  }
}
