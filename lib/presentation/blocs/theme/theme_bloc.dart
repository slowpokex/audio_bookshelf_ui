import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../core/services/theme_service.dart';

/// Events for theme management
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize theme service event
class ThemeInitializeEvent extends ThemeEvent {
  const ThemeInitializeEvent();
}

/// Set theme mode event
class ThemeSetModeEvent extends ThemeEvent {
  final ThemeMode mode;
  
  const ThemeSetModeEvent(this.mode);
  
  @override
  List<Object?> get props => [mode];
}

/// Toggle theme event
class ThemeToggleEvent extends ThemeEvent {
  const ThemeToggleEvent();
}

/// Reset theme to default event
class ThemeResetEvent extends ThemeEvent {
  const ThemeResetEvent();
}

/// States for theme management
abstract class ThemeState extends Equatable {
  const ThemeState();

  @override
  List<Object?> get props => [];
}

/// Initial theme state
class ThemeInitialState extends ThemeState {
  const ThemeInitialState();
}

/// Theme loading state
class ThemeLoadingState extends ThemeState {
  const ThemeLoadingState();
}

/// Theme loaded state
class ThemeLoadedState extends ThemeState {
  final ThemeMode currentMode;
  final bool isDark;
  final bool isLight;
  final bool isSystem;
  
  const ThemeLoadedState({
    required this.currentMode,
    required this.isDark,
    required this.isLight,
    required this.isSystem,
  });
  
  @override
  List<Object?> get props => [currentMode, isDark, isLight, isSystem];
  
  /// Create a copy with updated values
  ThemeLoadedState copyWith({
    ThemeMode? currentMode,
    bool? isDark,
    bool? isLight,
    bool? isSystem,
  }) {
    return ThemeLoadedState(
      currentMode: currentMode ?? this.currentMode,
      isDark: isDark ?? this.isDark,
      isLight: isLight ?? this.isLight,
      isSystem: isSystem ?? this.isSystem,
    );
  }
}

/// Theme error state
class ThemeErrorState extends ThemeState {
  final String message;
  final ThemeMode? fallbackMode;
  
  const ThemeErrorState({
    required this.message,
    this.fallbackMode,
  });
  
  @override
  List<Object?> get props => [message, fallbackMode];
}

/// Theme Bloc for managing theme state
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService _themeService;
  
  ThemeBloc({
    required ThemeService themeService,
  }) : _themeService = themeService,
       super(const ThemeInitialState()) {
    
    // Register event handlers
    on<ThemeInitializeEvent>(_onInitialize);
    on<ThemeSetModeEvent>(_onSetMode);
    on<ThemeToggleEvent>(_onToggle);
    on<ThemeResetEvent>(_onReset);
  }
  
  /// Initialize theme service
  Future<void> _onInitialize(
    ThemeInitializeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoadingState());
      
      await _themeService.initialize();
      
      final currentMode = _themeService.currentThemeMode;
      emit(ThemeLoadedState(
        currentMode: currentMode,
        isDark: currentMode == ThemeMode.dark,
        isLight: currentMode == ThemeMode.light,
        isSystem: currentMode == ThemeMode.system,
      ));
    } catch (e) {
      emit(ThemeErrorState(
        message: 'Failed to initialize theme: $e',
        fallbackMode: ThemeMode.system,
      ));
    }
  }
  
  /// Set theme mode
  Future<void> _onSetMode(
    ThemeSetModeEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (state is! ThemeLoadedState) {
        return;
      }
      
      emit(const ThemeLoadingState());
      
      await _themeService.setThemeMode(event.mode);
      
      emit(ThemeLoadedState(
        currentMode: event.mode,
        isDark: event.mode == ThemeMode.dark,
        isLight: event.mode == ThemeMode.light,
        isSystem: event.mode == ThemeMode.system,
      ));
    } catch (e) {
      emit(ThemeErrorState(
        message: 'Failed to set theme mode: $e',
        fallbackMode: _themeService.currentThemeMode,
      ));
    }
  }
  
  /// Toggle theme
  Future<void> _onToggle(
    ThemeToggleEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      if (state is! ThemeLoadedState) {
        return;
      }
      
      emit(const ThemeLoadingState());
      
      await _themeService.toggleTheme();
      
      final currentMode = _themeService.currentThemeMode;
      emit(ThemeLoadedState(
        currentMode: currentMode,
        isDark: currentMode == ThemeMode.dark,
        isLight: currentMode == ThemeMode.light,
        isSystem: currentMode == ThemeMode.system,
      ));
    } catch (e) {
      emit(ThemeErrorState(
        message: 'Failed to toggle theme: $e',
        fallbackMode: _themeService.currentThemeMode,
      ));
    }
  }
  
  /// Reset theme to default
  Future<void> _onReset(
    ThemeResetEvent event,
    Emitter<ThemeState> emit,
  ) async {
    try {
      emit(const ThemeLoadingState());
      
      await _themeService.resetToDefault();
      
      emit(const ThemeLoadedState(
        currentMode: ThemeMode.system,
        isDark: false,
        isLight: false,
        isSystem: true,
      ));
    } catch (e) {
      emit(ThemeErrorState(
        message: 'Failed to reset theme: $e',
        fallbackMode: ThemeMode.system,
      ));
    }
  }
  
  /// Get current theme mode
  ThemeMode get currentThemeMode {
    if (state is ThemeLoadedState) {
      return (state as ThemeLoadedState).currentMode;
    }
    return ThemeMode.system;
  }
  
  /// Check if current theme is dark
  bool isDarkTheme(BuildContext context) {
    return _themeService.isDarkTheme(context);
  }
  
  /// Check if current theme is light
  bool isLightTheme(BuildContext context) {
    return _themeService.isLightTheme(context);
  }
  
  /// Get effective theme mode
  ThemeMode getEffectiveThemeMode(BuildContext context) {
    return _themeService.getEffectiveThemeMode(context);
  }
  
  /// Get theme mode display name
  String getThemeModeDisplayName() {
    return _themeService.getThemeModeDisplayName();
  }
  
  /// Get theme mode description
  String getThemeModeDescription() {
    return _themeService.getThemeModeDescription();
  }
  
  /// Get available theme modes
  List<ThemeModeOption> getAvailableThemeModes() {
    return _themeService.getAvailableThemeModes();
  }
}
