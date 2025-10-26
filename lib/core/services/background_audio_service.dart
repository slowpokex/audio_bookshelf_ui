import 'dart:async';
import 'package:flutter/services.dart';
import '../utils/app_logger.dart';

/// Service for managing background audio playback on Android
class BackgroundAudioService {
  static const MethodChannel _channel = MethodChannel('audio_player_service');
  static BackgroundAudioService? _instance;
  
  BackgroundAudioService._internal();
  
  static BackgroundAudioService get instance {
    _instance ??= BackgroundAudioService._internal();
    return _instance!;
  }

  /// Initialize the background audio service
  Future<void> initialize() async {
    try {
      AppLogger.logDebug('Initializing BackgroundAudioService');
      
      // Set up method call handler
      _channel.setMethodCallHandler(_handleMethodCall);
      
      AppLogger.logDebug('BackgroundAudioService initialized');
    } catch (e) {
      AppLogger.logError('Failed to initialize BackgroundAudioService', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Handle method calls from Android service
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      AppLogger.logDebug('Received method call: ${call.method}');
      
      switch (call.method) {
        case 'resumePlayback':
          // Handle audio focus gain
          break;
        case 'pausePlayback':
          // Handle audio focus loss
          break;
        case 'lowerVolume':
          // Handle ducking
          break;
        default:
          AppLogger.logDebug('Unknown method call: ${call.method}');
      }
    } catch (e) {
      AppLogger.logError('Error handling method call', StackTrace.current, context: {
        'method': call.method,
        'error': e.toString(),
      });
    }
  }

  /// Start the background audio service
  Future<void> startService() async {
    try {
      print('🎵 Starting background audio service...');
      await _channel.invokeMethod('startService');
      print('✅ Background audio service started successfully');
      AppLogger.logDebug('Background audio service started');
    } catch (e) {
      print('❌ Failed to start background audio service: $e');
      AppLogger.logError('Failed to start background audio service', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Stop the background audio service
  Future<void> stopService() async {
    try {
      await _channel.invokeMethod('stopService');
      AppLogger.logDebug('Background audio service stopped');
    } catch (e) {
      AppLogger.logError('Failed to stop background audio service', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Update media metadata for the notification
  Future<void> updateMetadata({
    required String title,
    required String artist,
    required String album,
    required Duration duration,
  }) async {
    try {
      print('🎵 Updating metadata: $title by $artist');
      await _channel.invokeMethod('updateMetadata', {
        'title': title,
        'artist': artist,
        'album': album,
        'duration': duration.inMilliseconds,
      });
      print('✅ Background audio metadata updated successfully');
      AppLogger.logDebug('Media metadata updated');
    } catch (e) {
      print('❌ Failed to update background audio metadata: $e');
      AppLogger.logError('Failed to update media metadata', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Update playback state
  Future<void> updatePlaybackState({
    required bool isPlaying,
    required Duration position,
    required Duration duration,
  }) async {
    try {
      await _channel.invokeMethod('updatePlaybackState', {
        'isPlaying': isPlaying,
        'position': position.inMilliseconds,
        'duration': duration.inMilliseconds,
      });
      AppLogger.logDebug('Playback state updated');
    } catch (e) {
      AppLogger.logError('Failed to update playback state', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Update only the playback position (for frequent updates)
  Future<void> updatePosition({
    required Duration position,
    required Duration duration,
  }) async {
    try {
      await _channel.invokeMethod('updatePlaybackState', {
        'isPlaying': true, // Assume playing when updating position
        'position': position.inMilliseconds,
        'duration': duration.inMilliseconds,
      });
    } catch (e) {
      AppLogger.logError('Failed to update position', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Show notification
  Future<void> showNotification() async {
    try {
      await _channel.invokeMethod('showNotification');
      AppLogger.logDebug('Notification shown');
    } catch (e) {
      AppLogger.logError('Failed to show notification', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Hide notification
  Future<void> hideNotification() async {
    try {
      await _channel.invokeMethod('hideNotification');
      AppLogger.logDebug('Notification hidden');
    } catch (e) {
      AppLogger.logError('Failed to hide notification', StackTrace.current, context: {'error': e.toString()});
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    try {
      await stopService();
      _channel.setMethodCallHandler(null);
      AppLogger.logDebug('BackgroundAudioService disposed');
    } catch (e) {
      AppLogger.logError('Failed to dispose BackgroundAudioService', StackTrace.current, context: {'error': e.toString()});
    }
  }
}
