import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;

import 'core/constants/app_constants.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/add_audiobook_page.dart';
import 'presentation/widgets/loading/splash_screen.dart';
import 'presentation/blocs/audiobook/audiobook_bloc.dart';
import 'application/use_cases/audiobook_use_cases.dart';
import 'infrastructure/repositories/audiobook_repository_impl.dart';
import 'infrastructure/data_sources/audiobook_local_data_source.dart';
import 'infrastructure/data_sources/audiobook_remote_data_source.dart';

/// Main application widget
class AudioBookshelfApp extends StatelessWidget {
  const AudioBookshelfApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AudiobookBloc>(
          create: (context) => AudiobookBloc(
            getAudiobooksUseCase: GetAudiobooksUseCase(_audiobookRepository),
            getAudiobookUseCase: GetAudiobookUseCase(_audiobookRepository),
            createAudiobookUseCase: CreateAudiobookUseCase(_audiobookRepository),
            updateAudiobookUseCase: UpdateAudiobookUseCase(_audiobookRepository),
            deleteAudiobookUseCase: DeleteAudiobookUseCase(_audiobookRepository),
            toggleFavoriteUseCase: ToggleFavoriteUseCase(_audiobookRepository),
            rateAudiobookUseCase: RateAudiobookUseCase(_audiobookRepository),
            searchAudiobooksUseCase: SearchAudiobooksUseCase(_audiobookRepository),
            getRecommendationsUseCase: GetRecommendationsUseCase(_audiobookRepository),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ru', 'RU'),
        ],
        routerConfig: _router,
      ),
    );
  }
}

/// Router configuration
final GoRouter _router = GoRouter(
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
      path: '/audiobook-detail',
      name: 'audiobook-detail',
      builder: (context, state) {
        final audiobookId = state.extra as String?;
        if (audiobookId == null) {
          return const Scaffold(
            body: Center(
              child: Text('Audiobook ID is required'),
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text('Audiobook Detail'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.audiotrack,
                  size: 64,
                  color: Colors.blue,
                ),
                const SizedBox(height: 16),
                Text(
                  'Audiobook ID: $audiobookId',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Audiobook detail page coming soon...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },
    ),
    GoRoute(
      path: '/add-audiobook',
      name: 'add-audiobook',
      builder: (context, state) => const AddAudiobookPage(),
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

/// Repository instance (this would be injected via dependency injection)
final _audiobookRepository = AudiobookRepositoryImpl(
  localDataSource: AudiobookLocalDataSource(),
  remoteDataSource: AudiobookRemoteDataSource(
    client: http.Client(),
    baseUrl: AppConstants.apiBaseUrl,
    apiKey: AppConstants.apiKey,
  ),
);
