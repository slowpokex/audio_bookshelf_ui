import 'dart:async';
import '../utils/app_logger.dart';

/// Service for tracking audiobook progress
class ProgressTrackingService {
  static final ProgressTrackingService _instance = ProgressTrackingService._internal();
  factory ProgressTrackingService() => _instance;
  ProgressTrackingService._internal();

  Timer? _progressTimer;
  final Map<String, Duration> _progressCache = {};
  final Duration _saveInterval = const Duration(seconds: 30);
  String? _currentUserId;
  String? _currentAudiobookId;
  Duration? _lastSavedPosition;

  /// Initialize the progress tracking service
  Future<void> initialize({required String userId}) async {
    _currentUserId = userId;
    AppLogger.logDebug('ProgressTrackingService initialized for user: $userId');
  }

  /// Start tracking progress for an audiobook
  void startTracking(String audiobookId, Duration totalDuration) {
    if (_currentUserId == null) {
      AppLogger.logError('ProgressTrackingService not initialized', StackTrace.current);
      return;
    }

    _currentAudiobookId = audiobookId;
    _lastSavedPosition = Duration.zero;

    // Start periodic progress saving
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(_saveInterval, (timer) {
      _saveProgress();
    });

    AppLogger.logDebug('Started tracking progress for audiobook: $audiobookId');
  }

  /// Stop tracking progress
  void stopTracking() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _currentAudiobookId = null;
    _lastSavedPosition = null;
    AppLogger.logDebug('Stopped progress tracking');
  }

  /// Update current position
  void updatePosition(Duration position) {
    if (_currentAudiobookId == null) return;

    _progressCache[_currentAudiobookId!] = position;
    
    // Save immediately if position changed significantly (more than 5 minutes)
    if (_lastSavedPosition != null) {
      final timeDiff = (position - _lastSavedPosition!).abs();
      if (timeDiff.inMinutes >= 5) {
        _saveProgress();
      }
    }
  }

  /// Save progress to database
  Future<void> _saveProgress() async {
    if (_currentUserId == null || _currentAudiobookId == null) return;

    final currentPosition = _progressCache[_currentAudiobookId!];
    if (currentPosition == null) return;

    // Only save if position has changed significantly
    if (_lastSavedPosition != null && 
        (currentPosition - _lastSavedPosition!).inSeconds.abs() < 10) {
      return;
    }

    try {
      // This would typically use the progress use cases
      // For now, we'll just log the progress
      AppLogger.logDebug(
        'Saving progress for audiobook ${_currentAudiobookId}: ${currentPosition.inSeconds}s'
      );
      
      _lastSavedPosition = currentPosition;
    } catch (e) {
      AppLogger.logError('Failed to save progress', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Get progress for an audiobook
  Duration? getProgress(String audiobookId) {
    return _progressCache[audiobookId];
  }

  /// Clear progress cache
  void clearCache() {
    _progressCache.clear();
    AppLogger.logDebug('Progress cache cleared');
  }

  /// Dispose of resources
  void dispose() {
    _progressTimer?.cancel();
    _progressTimer = null;
    _progressCache.clear();
    _currentUserId = null;
    _currentAudiobookId = null;
    _lastSavedPosition = null;
    AppLogger.logDebug('ProgressTrackingService disposed');
  }
}
