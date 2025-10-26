import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/theme_service.dart';
import 'theme_bloc.dart';

/// Theme Bloc Provider for easy access throughout the app
class ThemeBlocProvider extends StatelessWidget {
  final Widget child;
  
  const ThemeBlocProvider({
    super.key,
    required this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeBloc>(
      create: (context) => ThemeBloc(
        themeService: ThemeService.instance,
      )..add(const ThemeInitializeEvent()),
      child: child,
    );
  }
}

/// Extension on BuildContext for easy theme access
extension ThemeContext on BuildContext {
  /// Get the theme bloc
  ThemeBloc get themeBloc => BlocProvider.of<ThemeBloc>(this);
  
  /// Get current theme mode
  ThemeMode get currentThemeMode => themeBloc.currentThemeMode;
  
  /// Check if current theme is dark
  bool get isDarkTheme => themeBloc.isDarkTheme(this);
  
  /// Check if current theme is light
  bool get isLightTheme => themeBloc.isLightTheme(this);
  
  /// Get effective theme mode
  ThemeMode get effectiveThemeMode => themeBloc.getEffectiveThemeMode(this);
  
  /// Get theme mode display name
  String get themeModeDisplayName => themeBloc.getThemeModeDisplayName();
  
  /// Get theme mode description
  String get themeModeDescription => themeBloc.getThemeModeDescription();
  
  /// Get available theme modes
  List<ThemeModeOption> get availableThemeModes => themeBloc.getAvailableThemeModes();
  
  /// Set theme mode
  void setThemeMode(ThemeMode mode) {
    themeBloc.add(ThemeSetModeEvent(mode));
  }
  
  /// Toggle theme
  void toggleTheme() {
    themeBloc.add(const ThemeToggleEvent());
  }
  
  /// Reset theme to default
  void resetTheme() {
    themeBloc.add(const ThemeResetEvent());
  }
}

/// Theme Bloc Builder for reactive UI updates
class ThemeBlocBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, ThemeState state) builder;
  
  const ThemeBlocBuilder({
    super.key,
    required this.builder,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: builder,
    );
  }
}

/// Theme Bloc Listener for side effects
class ThemeBlocListener extends StatelessWidget {
  final Widget child;
  final void Function(BuildContext context, ThemeState state)? listener;
  
  const ThemeBlocListener({
    super.key,
    required this.child,
    this.listener,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocListener<ThemeBloc, ThemeState>(
      listener: listener ?? (context, state) {},
      child: child,
    );
  }
}

/// Theme Bloc Consumer for both building and listening
class ThemeBlocConsumer extends StatelessWidget {
  final Widget Function(BuildContext context, ThemeState state) builder;
  final void Function(BuildContext context, ThemeState state)? listener;
  
  const ThemeBlocConsumer({
    super.key,
    required this.builder,
    this.listener,
  });
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ThemeBloc, ThemeState>(
      builder: builder,
      listener: listener ?? (context, state) {},
    );
  }
}
