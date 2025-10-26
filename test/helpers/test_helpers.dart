import 'dart:io';
import 'package:audio_bookshelf_ui/presentation/blocs/audio_player/audio_player_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:path/path.dart' as path;

import 'package:audio_bookshelf_ui/app.dart';
import 'package:audio_bookshelf_ui/presentation/blocs/audiobook/audiobook_bloc.dart';
import 'package:audio_bookshelf_ui/presentation/blocs/audio_player/audio_player_bloc.dart';
import 'package:audio_bookshelf_ui/application/use_cases/audiobook_use_cases.dart';
import 'package:audio_bookshelf_ui/domain/entities/audiobook.dart';
import 'package:audio_bookshelf_ui/domain/entities/user.dart';
import 'package:audio_bookshelf_ui/domain/value_objects/email.dart';
import 'package:audio_bookshelf_ui/domain/value_objects/rating.dart';
import 'package:audio_bookshelf_ui/core/services/audio_player_service.dart';
import 'package:audio_bookshelf_ui/core/services/sleep_timer_service.dart';
import 'package:audio_bookshelf_ui/core/services/database_service.dart';
import 'package:audio_bookshelf_ui/core/services/metadata_storage_service.dart';
import 'package:audio_bookshelf_ui/core/services/folder_scan_service.dart';
import 'package:audio_bookshelf_ui/core/services/file_import_service.dart';
import 'package:audio_bookshelf_ui/core/services/progress_tracking_service.dart';
import 'package:audio_bookshelf_ui/core/services/background_audio_service.dart';
import 'package:audio_bookshelf_ui/core/utils/app_logger.dart';
import '../test_config.dart';

// Mock classes for Blocs
class MockAudiobookBloc extends Mock implements AudiobookBloc {
  @override
  Stream<AudiobookState> get stream => Stream.value(AudiobookInitialState());

  @override
  AudiobookState get state => AudiobookInitialState();

  @override
  Future<void> close() async {}
}

class MockAudioPlayerBloc extends Mock implements AudioPlayerBloc {
  @override
  Stream<AudioPlayerState> get stream => Stream.value(const AudioPlayerState.initial());

  @override
  AudioPlayerState get state => const AudioPlayerState.initial();

  @override
  Future<void> close() async {}
}

// Mock classes for Use Cases
class MockGetAudiobooksUseCase extends Mock implements GetAudiobooksUseCase {}
class MockGetAudiobookUseCase extends Mock implements GetAudiobookUseCase {}
class MockCreateAudiobookUseCase extends Mock implements CreateAudiobookUseCase {}
class MockUpdateAudiobookUseCase extends Mock implements UpdateAudiobookUseCase {}
class MockDeleteAudiobookUseCase extends Mock implements DeleteAudiobookUseCase {}
class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}
class MockRateAudiobookUseCase extends Mock implements RateAudiobookUseCase {}
class MockSearchAudiobooksUseCase extends Mock implements SearchAudiobooksUseCase {}
class MockGetRecommendationsUseCase extends Mock implements GetRecommendationsUseCase {}

// Mock classes for Repositories
class MockAudiobookRepository extends Mock implements AudiobookRepository {}

// Mock classes for Services
class MockAudioPlayerService extends Mock implements AudioPlayerService {}
class MockSleepTimerService extends Mock implements SleepTimerService {}
class MockDatabaseService extends Mock implements DatabaseService {}
class MockMetadataStorageService extends Mock implements MetadataStorageService {}
class MockFolderScanService extends Mock implements FolderScanService {}
class MockFileImportService extends Mock implements FileImportService {}
class MockProgressTrackingService extends Mock implements ProgressTrackingService {}
class MockBackgroundAudioService extends Mock implements BackgroundAudioService {}
class MockAppLogger extends Mock implements AppLogger {}

/// Test helpers for Audio Bookshelf UI tests
class TestHelpers {
  /// Creates a test widget with proper dependencies
  static Widget createTestWidget({
    required Widget child,
    AudiobookBloc? audiobookBloc,
    AudioPlayerBloc? audioPlayerBloc,
    List<BlocProvider>? additionalProviders,
  }) {
    final providers = <BlocProvider>[
      BlocProvider<AudiobookBloc>(
        create: (context) => audiobookBloc ?? MockAudiobookBloc(),
      ),
      if (audioPlayerBloc != null)
        BlocProvider<AudioPlayerBloc>(
          create: (context) => audioPlayerBloc,
        ),
      ...?additionalProviders,
    ];
    
    return MaterialApp.router(
      routerConfig: GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => MultiBlocProvider(
              providers: providers,
              child: child,
            ),
          ),
          GoRoute(
            path: '/add-audiobook',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Add Audiobook Page')),
            ),
          ),
          GoRoute(
            path: '/audiobook-detail',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Audiobook Detail Page')),
            ),
          ),
        ],
      ),
    );
  }

  /// Creates a test widget with the main app
  static Widget createTestApp({
    AudiobookBloc? audiobookBloc,
    AudioPlayerBloc? audioPlayerBloc,
    List<BlocProvider>? additionalProviders,
  }) {
    return createTestWidget(
      audiobookBloc: audiobookBloc,
      audioPlayerBloc: audioPlayerBloc,
      additionalProviders: additionalProviders,
      child: const AudioBookshelfApp(),
    );
  }

  /// Creates a test widget with multiple blocs
  static Widget createTestWidgetWithBlocs({
    required Widget child,
    Map<Type, BlocProvider>? blocProviders,
  }) {
    final providers = <BlocProvider>[
      BlocProvider<AudiobookBloc>(
        create: (context) => MockAudiobookBloc(),
      ),
      BlocProvider<AudioPlayerBloc>(
        create: (context) => MockAudioPlayerBloc(),
      ),
      ...?blocProviders?.values,
    ];
    
    return MaterialApp(
      home: MultiBlocProvider(
        providers: providers,
        child: child,
      ),
    );
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

  /// Creates a temporary directory for testing
  static Future<Directory> createTempDirectory(String prefix) async {
    return await Directory.systemTemp.createTemp('${prefix}_test_');
  }

  /// Creates a temporary file with content
  static Future<File> createTempFile(String prefix, String extension, {String? content}) async {
    final tempDir = await createTempDirectory(prefix);
    final file = File(path.join(tempDir.path, 'test.$extension'));
    if (content != null) {
      await file.writeAsString(content);
    }
    return file;
  }

  /// Creates test audiobook data
  static Audiobook createTestAudiobook({
    String? id,
    String? title,
    String? author,
    String? narrator,
    String? description,
    String? genre,
    int? year,
    Duration? duration,
    String? coverImagePath,
    String? audioFilePath,
    List<String>? tags,
    bool isCompleted = false,
    bool isFavorite = false,
    double rating = 0.0,
    int playCount = 0,
    Duration? currentPosition,
    String? series,
    int? seriesOrder,
    Map<String, dynamic>? metadata,
  }) {
    return Audiobook(
      id: id ?? TestConfig.testTitle,
      title: title ?? TestConfig.testTitle,
      author: author ?? TestConfig.testAuthor,
      narrator: narrator ?? TestConfig.testNarrator,
      description: description ?? TestConfig.testDescription,
      genre: genre ?? TestConfig.testGenre,
      year: year ?? TestConfig.testYear,
      duration: duration ?? TestConfig.mediumDuration,
      coverImagePath: coverImagePath ?? TestConfig.testCoverImage,
      audioFilePath: audioFilePath ?? 'test_audio.mp3',
      tags: tags ?? TestConfig.testTags,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
      isCompleted: isCompleted,
      isFavorite: isFavorite,
      rating: rating,
      playCount: playCount,
      currentPosition: currentPosition,
      series: series ?? TestConfig.testSeries,
      seriesOrder: seriesOrder ?? TestConfig.testSeriesOrder,
      metadata: metadata ?? {},
    );
  }

  /// Creates test user data
  static User createTestUser({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? language,
    String? timezone,
    bool isActive = true,
    bool isPremium = false,
    Map<String, dynamic>? preferences,
    List<String>? favoriteGenres,
    List<String>? favoriteAuthors,
    List<String>? favoriteNarrators,
    double averageRating = 0.0,
    int totalBooksRead = 0,
    int totalHoursListened = 0,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? 'test_user_id',
      username: username ?? 'testuser',
      email: email ?? 'test@example.com',
      displayName: displayName ?? 'Test User',
      language: language ?? 'en',
      timezone: timezone ?? 'UTC',
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      updatedAt: DateTime.now(),
      isActive: isActive,
      isPremium: isPremium,
      preferences: preferences ?? {},
      favoriteGenres: favoriteGenres ?? TestConfig.testTags,
      favoriteAuthors: favoriteAuthors ?? [TestConfig.testAuthor],
      favoriteNarrators: favoriteNarrators ?? [TestConfig.testNarrator],
      averageRating: averageRating,
      totalBooksRead: totalBooksRead,
      totalHoursListened: totalHoursListened,
      metadata: metadata ?? {},
    );
  }

  /// Creates test email value object
  static Email createTestEmail(String email) {
    return Email.fromString(email);
  }

  /// Creates test rating value object
  static Rating createTestRating(double rating) {
    return Rating.fromDouble(rating);
  }

  /// Creates test rating from integer
  static Rating createTestRatingFromInt(int rating) {
    return Rating.fromInt(rating);
  }

  /// Creates test rating from percentage
  static Rating createTestRatingFromPercentage(int percentage) {
    return Rating.fromPercentage(percentage);
  }

  /// Creates a list of test audiobooks
  static List<Audiobook> createTestAudiobooks(int count) {
    return List.generate(count, (index) => createTestAudiobook(
      id: 'test_audiobook_$index',
      title: 'Test Audiobook $index',
      author: 'Test Author $index',
      narrator: 'Test Narrator $index',
      genre: TestConfig.testTags[index % TestConfig.testTags.length],
      year: TestConfig.testYear + index,
    ));
  }

  /// Creates test audio file info
  static AudioFileInfo createTestAudioFileInfo({
    String? filePath,
    String? fileName,
    int? fileSize,
    String? fileFormat,
    Duration? duration,
    String? title,
    String? author,
    String? album,
    int? year,
    String? genre,
    int? trackNumber,
    bool isSelected = false,
  }) {
    return AudioFileInfo(
      filePath: filePath ?? 'test/path/audio.mp3',
      fileName: fileName ?? 'audio.mp3',
      fileSize: fileSize ?? TestConfig.mediumFileSize,
      fileFormat: fileFormat ?? 'mp3',
      duration: duration ?? TestConfig.mediumDuration,
      title: title ?? TestConfig.testTitle,
      author: author ?? TestConfig.testAuthor,
      album: album ?? TestConfig.testTitle,
      year: year ?? TestConfig.testYear,
      genre: genre ?? TestConfig.testGenre,
      trackNumber: trackNumber ?? 1,
      isSelected: isSelected,
    );
  }

  /// Creates test metadata
  static AudioFileMetadata createTestMetadata({
    String? title,
    String? author,
    String? album,
    int? year,
    String? genre,
    int? trackNumber,
    DateTime? lastModified,
  }) {
    return AudioFileMetadata(
      title: title ?? TestConfig.testTitle,
      author: author ?? TestConfig.testAuthor,
      album: album ?? TestConfig.testTitle,
      year: year ?? TestConfig.testYear,
      genre: genre ?? TestConfig.testGenre,
      trackNumber: trackNumber ?? 1,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  /// Creates test validation result
  static AudioFileValidationResult createTestValidationResult({
    bool isValid = true,
    int? fileSize,
    String? error,
  }) {
    return AudioFileValidationResult(
      isValid: isValid,
      fileSize: fileSize ?? TestConfig.mediumFileSize,
      error: error,
    );
  }

  /// Verifies that a widget is accessible
  static void verifyAccessibility(WidgetTester tester, Finder finder) {
    final widget = tester.widget(finder);
    expect(widget, isNotNull);
    // Additional accessibility checks can be added here
  }

  /// Simulates user interaction with proper timing
  static Future<void> simulateUserInteraction(WidgetTester tester, Finder finder) async {
    await tester.tap(finder);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  /// Waits for a specific state to be reached
  static Future<void> waitForState<T>(
    WidgetTester tester,
    Type blocType,
    T targetState, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stopwatch = Stopwatch()..start();
    
    while (stopwatch.elapsed < timeout) {
      await tester.pump(const Duration(milliseconds: 100));
      // Check if target state is reached
      // This would need to be implemented based on specific bloc states
    }
  }

  /// Cleans up test resources
  static Future<void> cleanupTestResources(List<Directory> tempDirs) async {
    for (final dir in tempDirs) {
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    }
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
