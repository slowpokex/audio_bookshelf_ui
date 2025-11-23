import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'core/constants/app_constants.dart';
import 'core/services/audio_player_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/theme_service.dart';
import 'core/services/sleep_timer_service.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/add_audiobook_page.dart';
import 'presentation/pages/audio_player_page.dart';
import 'presentation/pages/audiobook_details_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/widgets/loading/splash_screen.dart';
import 'presentation/blocs/audiobook/audiobook_bloc.dart';
import 'presentation/blocs/audio_player/audio_player_bloc.dart';
import 'presentation/blocs/theme/theme_bloc.dart';
import 'presentation/blocs/theme/theme_bloc_provider.dart';
import 'application/use_cases/audiobook_use_cases.dart';
import 'infrastructure/repositories/audiobook_repository_impl.dart';
import 'infrastructure/data_sources/audiobook_local_data_source.dart';
import 'infrastructure/data_sources/audiobook_remote_data_source.dart';

/// Main application widget
class AudioBookshelfApp extends StatefulWidget {
  const AudioBookshelfApp({super.key});

  @override
  State<AudioBookshelfApp> createState() => _AudioBookshelfAppState();
}

class _AudioBookshelfAppState extends State<AudioBookshelfApp> {
  late final http.Client _httpClient;
  late final AudiobookRepositoryImpl _audiobookRepository;
  late final AudioPlayerBloc _audioPlayerBloc;
  late final AudiobookBloc _audiobookBloc;
  late final ThemeBloc _themeBloc;

  @override
  void initState() {
    super.initState();
    // Create HTTP client that will be disposed properly
    _httpClient = http.Client();
    
    // Create repository with proper lifecycle management
    _audiobookRepository = AudiobookRepositoryImpl(
      localDataSource: AudiobookLocalDataSource(),
      remoteDataSource: AudiobookRemoteDataSource(
        client: _httpClient,
        baseUrl: AppConstants.apiBaseUrl,
        apiKey: AppConstants.apiKey,
      ),
    );
    
    // Create blocs that persist across rebuilds
    _audiobookBloc = AudiobookBloc(
      getAudiobooksUseCase: GetAudiobooksUseCase(_audiobookRepository),
      getAudiobookUseCase: GetAudiobookUseCase(_audiobookRepository),
      createAudiobookUseCase: CreateAudiobookUseCase(_audiobookRepository),
      updateAudiobookUseCase: UpdateAudiobookUseCase(_audiobookRepository),
      deleteAudiobookUseCase: DeleteAudiobookUseCase(_audiobookRepository),
      toggleFavoriteUseCase: ToggleFavoriteUseCase(_audiobookRepository),
      rateAudiobookUseCase: RateAudiobookUseCase(_audiobookRepository),
      searchAudiobooksUseCase: SearchAudiobooksUseCase(_audiobookRepository),
      getRecommendationsUseCase: GetRecommendationsUseCase(_audiobookRepository),
    );
    
    _audioPlayerBloc = AudioPlayerBloc(
      audioPlayerService: AudioPlayerService(),
    );
    
    _themeBloc = ThemeBloc(
      themeService: ThemeService.instance,
    )..add(const ThemeInitializeEvent());

    // Initialize SleepTimerService
    SleepTimerService().initialize(_audioPlayerBloc);
  }

  @override
  void dispose() {
    // Dispose blocs in reverse order of creation
    _themeBloc.close();
    _audioPlayerBloc.close();
    _audiobookBloc.close();
    
    // Dispose services
    SleepTimerService().dispose();
    
    // Dispose HTTP client to prevent memory leaks
    _httpClient.close();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudiobookBloc>.value(value: _audiobookBloc),
        BlocProvider<AudioPlayerBloc>.value(value: _audioPlayerBloc),
        BlocProvider<ThemeBloc>.value(value: _themeBloc),
      ],
      child: ThemeBlocBuilder(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState is ThemeLoadedState 
                ? themeState.currentMode 
                : ThemeMode.system,
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('ru', 'RU'),
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}

/// Router configuration
final _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/add-audiobook',
      name: 'add-audiobook',
      builder: (context, state) => const AddAudiobookPage(),
    ),
    GoRoute(
      path: '/audio-player',
      name: 'audio-player',
      builder: (context, state) => const AudioPlayerPage(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsPage(),
    ),
    GoRoute(
      path: '/audiobook-details/:id',
      name: 'audiobook-details',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AudiobookDetailsPage(audiobookId: id);
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(
      title: const Text('Error'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Page not found: ${state.uri.toString()}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
);
