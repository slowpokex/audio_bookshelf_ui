import '../../application/events/audiobook_events.dart';
import '../../core/utils/logger.dart';
import '../../core/errors/failures.dart';

/// Event handler for audiobook events
abstract class AudiobookEventHandler {
  Future<void> handle(AudiobookEvent event);
}

/// Event handler for audiobook created events
class AudiobookCreatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookCreatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookCreatedEvent) {
      try {
        await _handleAudiobookCreated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook created event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook created event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookCreated(AudiobookCreatedEvent event) async {
    _logger.info(
      'Audiobook created: ${event.audiobook.title}',
      extra: {
        'audiobookId': event.audiobookId,
        'title': event.audiobook.title,
        'author': event.audiobook.author,
      },
    );

    // Add any additional logic for handling audiobook creation
    // For example: send notifications, update analytics, etc.
  }
}

/// Event handler for audiobook updated events
class AudiobookUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookUpdatedEvent) {
      try {
        await _handleAudiobookUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookUpdated(AudiobookUpdatedEvent event) async {
    _logger.info(
      'Audiobook updated: ${event.audiobook.title}',
      extra: {
        'audiobookId': event.audiobookId,
        'title': event.audiobook.title,
        'changes': event.changes,
      },
    );

    // Add any additional logic for handling audiobook updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook deleted events
class AudiobookDeletedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookDeletedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookDeletedEvent) {
      try {
        await _handleAudiobookDeleted(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook deleted event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook deleted event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookDeleted(AudiobookDeletedEvent event) async {
    _logger.info(
      'Audiobook deleted',
      extra: {'audiobookId': event.audiobookId},
    );

    // Add any additional logic for handling audiobook deletion
    // For example: cleanup files, update analytics, etc.
  }
}

/// Event handler for audiobook favorited events
class AudiobookFavoritedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookFavoritedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookFavoritedEvent) {
      try {
        await _handleAudiobookFavorited(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook favorited event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook favorited event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookFavorited(AudiobookFavoritedEvent event) async {
    _logger.info(
      'Audiobook ${event.isFavorite ? 'favorited' : 'unfavorited'}',
      extra: {
        'audiobookId': event.audiobookId,
        'isFavorite': event.isFavorite,
      },
    );

    // Add any additional logic for handling audiobook favoriting
    // For example: update user preferences, send notifications, etc.
  }
}

/// Event handler for audiobook rated events
class AudiobookRatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookRatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookRatedEvent) {
      try {
        await _handleAudiobookRated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook rated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook rated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookRated(AudiobookRatedEvent event) async {
    _logger.info(
      'Audiobook rated: ${event.rating}',
      extra: {
        'audiobookId': event.audiobookId,
        'rating': event.rating,
        'previousRating': event.previousRating,
      },
    );

    // Add any additional logic for handling audiobook rating
    // For example: update recommendations, send notifications, etc.
  }
}

/// Event handler for audiobook played events
class AudiobookPlayedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookPlayedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookPlayedEvent) {
      try {
        await _handleAudiobookPlayed(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook played event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook played event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookPlayed(AudiobookPlayedEvent event) async {
    _logger.info(
      'Audiobook played',
      extra: {
        'audiobookId': event.audiobookId,
        'position': event.position.inMilliseconds,
        'duration': event.duration.inMilliseconds,
      },
    );

    // Add any additional logic for handling audiobook playback
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook paused events
class AudiobookPausedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookPausedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookPausedEvent) {
      try {
        await _handleAudiobookPaused(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook paused event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook paused event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookPaused(AudiobookPausedEvent event) async {
    _logger.info(
      'Audiobook paused',
      extra: {
        'audiobookId': event.audiobookId,
        'position': event.position.inMilliseconds,
        'duration': event.duration.inMilliseconds,
      },
    );

    // Add any additional logic for handling audiobook pausing
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook stopped events
class AudiobookStoppedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookStoppedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookStoppedEvent) {
      try {
        await _handleAudiobookStopped(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook stopped event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook stopped event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookStopped(AudiobookStoppedEvent event) async {
    _logger.info(
      'Audiobook stopped',
      extra: {
        'audiobookId': event.audiobookId,
        'position': event.position.inMilliseconds,
        'duration': event.duration.inMilliseconds,
      },
    );

    // Add any additional logic for handling audiobook stopping
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook completed events
class AudiobookCompletedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookCompletedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookCompletedEvent) {
      try {
        await _handleAudiobookCompleted(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook completed event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook completed event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookCompleted(AudiobookCompletedEvent event) async {
    _logger.info(
      'Audiobook completed',
      extra: {
        'audiobookId': event.audiobookId,
        'totalDuration': event.totalDuration.inMilliseconds,
        'completedAt': event.completedAt.toIso8601String(),
      },
    );

    // Add any additional logic for handling audiobook completion
    // For example: update user statistics, send congratulations, etc.
  }
}

/// Event handler for audiobook progress updated events
class AudiobookProgressUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookProgressUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookProgressUpdatedEvent) {
      try {
        await _handleAudiobookProgressUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook progress updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook progress updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookProgressUpdated(AudiobookProgressUpdatedEvent event) async {
    _logger.info(
      'Audiobook progress updated: ${event.progressPercentage.toStringAsFixed(1)}%',
      extra: {
        'audiobookId': event.audiobookId,
        'currentPosition': event.currentPosition.inMilliseconds,
        'totalDuration': event.totalDuration.inMilliseconds,
        'progressPercentage': event.progressPercentage,
      },
    );

    // Add any additional logic for handling audiobook progress updates
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook metadata updated events
class AudiobookMetadataUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookMetadataUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookMetadataUpdatedEvent) {
      try {
        await _handleAudiobookMetadataUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook metadata updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook metadata updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookMetadataUpdated(AudiobookMetadataUpdatedEvent event) async {
    _logger.info(
      'Audiobook metadata updated',
      extra: {
        'audiobookId': event.audiobookId,
        'newMetadata': event.newMetadata,
        'previousMetadata': event.previousMetadata,
      },
    );

    // Add any additional logic for handling audiobook metadata updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook tags updated events
class AudiobookTagsUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookTagsUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookTagsUpdatedEvent) {
      try {
        await _handleAudiobookTagsUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook tags updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook tags updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookTagsUpdated(AudiobookTagsUpdatedEvent event) async {
    _logger.info(
      'Audiobook tags updated',
      extra: {
        'audiobookId': event.audiobookId,
        'newTags': event.newTags,
        'previousTags': event.previousTags,
      },
    );

    // Add any additional logic for handling audiobook tags updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook series updated events
class AudiobookSeriesUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookSeriesUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookSeriesUpdatedEvent) {
      try {
        await _handleAudiobookSeriesUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook series updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook series updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookSeriesUpdated(AudiobookSeriesUpdatedEvent event) async {
    _logger.info(
      'Audiobook series updated',
      extra: {
        'audiobookId': event.audiobookId,
        'series': event.series,
        'seriesOrder': event.seriesOrder,
        'seriesId': event.seriesId,
        'previousSeries': event.previousSeries,
        'previousSeriesOrder': event.previousSeriesOrder,
        'previousSeriesId': event.previousSeriesId,
      },
    );

    // Add any additional logic for handling audiobook series updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook cover updated events
class AudiobookCoverUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookCoverUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookCoverUpdatedEvent) {
      try {
        await _handleAudiobookCoverUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook cover updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook cover updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookCoverUpdated(AudiobookCoverUpdatedEvent event) async {
    _logger.info(
      'Audiobook cover updated',
      extra: {
        'audiobookId': event.audiobookId,
        'newCoverPath': event.newCoverPath,
        'previousCoverPath': event.previousCoverPath,
      },
    );

    // Add any additional logic for handling audiobook cover updates
    // For example: update cache, send notifications, etc.
  }
}

/// Event handler for audiobook audio updated events
class AudiobookAudioUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookAudioUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookAudioUpdatedEvent) {
      try {
        await _handleAudiobookAudioUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook audio updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook audio updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookAudioUpdated(AudiobookAudioUpdatedEvent event) async {
    _logger.info(
      'Audiobook audio updated',
      extra: {
        'audiobookId': event.audiobookId,
        'newAudioPath': event.newAudioPath,
        'previousAudioPath': event.previousAudioPath,
      },
    );

    // Add any additional logic for handling audiobook audio updates
    // For example: update cache, send notifications, etc.
  }
}

/// Event handler for audiobook local status updated events
class AudiobookLocalStatusUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookLocalStatusUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookLocalStatusUpdatedEvent) {
      try {
        await _handleAudiobookLocalStatusUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook local status updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook local status updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookLocalStatusUpdated(AudiobookLocalStatusUpdatedEvent event) async {
    _logger.info(
      'Audiobook local status updated',
      extra: {
        'audiobookId': event.audiobookId,
        'isLocal': event.isLocal,
        'localPath': event.localPath,
        'previousIsLocal': event.previousIsLocal,
        'previousLocalPath': event.previousLocalPath,
      },
    );

    // Add any additional logic for handling audiobook local status updates
    // For example: update cache, send notifications, etc.
  }
}

/// Event handler for audiobook completion status updated events
class AudiobookCompletionStatusUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookCompletionStatusUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookCompletionStatusUpdatedEvent) {
      try {
        await _handleAudiobookCompletionStatusUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook completion status updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook completion status updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookCompletionStatusUpdated(AudiobookCompletionStatusUpdatedEvent event) async {
    _logger.info(
      'Audiobook completion status updated',
      extra: {
        'audiobookId': event.audiobookId,
        'isCompleted': event.isCompleted,
        'previousIsCompleted': event.previousIsCompleted,
      },
    );

    // Add any additional logic for handling audiobook completion status updates
    // For example: update user statistics, send notifications, etc.
  }
}

/// Event handler for audiobook play count updated events
class AudiobookPlayCountUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookPlayCountUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookPlayCountUpdatedEvent) {
      try {
        await _handleAudiobookPlayCountUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook play count updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook play count updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookPlayCountUpdated(AudiobookPlayCountUpdatedEvent event) async {
    _logger.info(
      'Audiobook play count updated',
      extra: {
        'audiobookId': event.audiobookId,
        'playCount': event.playCount,
        'previousPlayCount': event.previousPlayCount,
      },
    );

    // Add any additional logic for handling audiobook play count updates
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook last played updated events
class AudiobookLastPlayedUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookLastPlayedUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookLastPlayedUpdatedEvent) {
      try {
        await _handleAudiobookLastPlayedUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook last played updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook last played updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookLastPlayedUpdated(AudiobookLastPlayedUpdatedEvent event) async {
    _logger.info(
      'Audiobook last played updated',
      extra: {
        'audiobookId': event.audiobookId,
        'lastPlayedAt': event.lastPlayedAt.toIso8601String(),
        'previousLastPlayedAt': event.previousLastPlayedAt?.toIso8601String(),
      },
    );

    // Add any additional logic for handling audiobook last played updates
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook current position updated events
class AudiobookCurrentPositionUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookCurrentPositionUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookCurrentPositionUpdatedEvent) {
      try {
        await _handleAudiobookCurrentPositionUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook current position updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook current position updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookCurrentPositionUpdated(AudiobookCurrentPositionUpdatedEvent event) async {
    _logger.info(
      'Audiobook current position updated',
      extra: {
        'audiobookId': event.audiobookId,
        'currentPosition': event.currentPosition.inMilliseconds,
        'previousCurrentPosition': event.previousCurrentPosition.inMilliseconds,
      },
    );

    // Add any additional logic for handling audiobook current position updates
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook duration updated events
class AudiobookDurationUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookDurationUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookDurationUpdatedEvent) {
      try {
        await _handleAudiobookDurationUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook duration updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook duration updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookDurationUpdated(AudiobookDurationUpdatedEvent event) async {
    _logger.info(
      'Audiobook duration updated',
      extra: {
        'audiobookId': event.audiobookId,
        'duration': event.duration.inMilliseconds,
        'previousDuration': event.previousDuration.inMilliseconds,
      },
    );

    // Add any additional logic for handling audiobook duration updates
    // For example: update analytics, send notifications, etc.
  }
}

/// Event handler for audiobook language updated events
class AudiobookLanguageUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookLanguageUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookLanguageUpdatedEvent) {
      try {
        await _handleAudiobookLanguageUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook language updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook language updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookLanguageUpdated(AudiobookLanguageUpdatedEvent event) async {
    _logger.info(
      'Audiobook language updated',
      extra: {
        'audiobookId': event.audiobookId,
        'language': event.language,
        'previousLanguage': event.previousLanguage,
      },
    );

    // Add any additional logic for handling audiobook language updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook publisher updated events
class AudiobookPublisherUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookPublisherUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookPublisherUpdatedEvent) {
      try {
        await _handleAudiobookPublisherUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook publisher updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook publisher updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookPublisherUpdated(AudiobookPublisherUpdatedEvent event) async {
    _logger.info(
      'Audiobook publisher updated',
      extra: {
        'audiobookId': event.audiobookId,
        'publisher': event.publisher,
        'previousPublisher': event.previousPublisher,
      },
    );

    // Add any additional logic for handling audiobook publisher updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook ISBN updated events
class AudiobookIsbnUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookIsbnUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookIsbnUpdatedEvent) {
      try {
        await _handleAudiobookIsbnUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook ISBN updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook ISBN updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookIsbnUpdated(AudiobookIsbnUpdatedEvent event) async {
    _logger.info(
      'Audiobook ISBN updated',
      extra: {
        'audiobookId': event.audiobookId,
        'isbn': event.isbn,
        'previousIsbn': event.previousIsbn,
      },
    );

    // Add any additional logic for handling audiobook ISBN updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook year updated events
class AudiobookYearUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookYearUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookYearUpdatedEvent) {
      try {
        await _handleAudiobookYearUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook year updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook year updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookYearUpdated(AudiobookYearUpdatedEvent event) async {
    _logger.info(
      'Audiobook year updated',
      extra: {
        'audiobookId': event.audiobookId,
        'year': event.year,
        'previousYear': event.previousYear,
      },
    );

    // Add any additional logic for handling audiobook year updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook genre updated events
class AudiobookGenreUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookGenreUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookGenreUpdatedEvent) {
      try {
        await _handleAudiobookGenreUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook genre updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook genre updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookGenreUpdated(AudiobookGenreUpdatedEvent event) async {
    _logger.info(
      'Audiobook genre updated',
      extra: {
        'audiobookId': event.audiobookId,
        'genre': event.genre,
        'previousGenre': event.previousGenre,
      },
    );

    // Add any additional logic for handling audiobook genre updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook narrator updated events
class AudiobookNarratorUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookNarratorUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookNarratorUpdatedEvent) {
      try {
        await _handleAudiobookNarratorUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook narrator updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook narrator updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookNarratorUpdated(AudiobookNarratorUpdatedEvent event) async {
    _logger.info(
      'Audiobook narrator updated',
      extra: {
        'audiobookId': event.audiobookId,
        'narrator': event.narrator,
        'previousNarrator': event.previousNarrator,
      },
    );

    // Add any additional logic for handling audiobook narrator updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook author updated events
class AudiobookAuthorUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookAuthorUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookAuthorUpdatedEvent) {
      try {
        await _handleAudiobookAuthorUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook author updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook author updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookAuthorUpdated(AudiobookAuthorUpdatedEvent event) async {
    _logger.info(
      'Audiobook author updated',
      extra: {
        'audiobookId': event.audiobookId,
        'author': event.author,
        'previousAuthor': event.previousAuthor,
      },
    );

    // Add any additional logic for handling audiobook author updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook title updated events
class AudiobookTitleUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookTitleUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookTitleUpdatedEvent) {
      try {
        await _handleAudiobookTitleUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook title updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook title updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookTitleUpdated(AudiobookTitleUpdatedEvent event) async {
    _logger.info(
      'Audiobook title updated',
      extra: {
        'audiobookId': event.audiobookId,
        'title': event.title,
        'previousTitle': event.previousTitle,
      },
    );

    // Add any additional logic for handling audiobook title updates
    // For example: update search index, send notifications, etc.
  }
}

/// Event handler for audiobook description updated events
class AudiobookDescriptionUpdatedEventHandler extends AudiobookEventHandler {
  final Logger _logger;

  AudiobookDescriptionUpdatedEventHandler(this._logger);

  @override
  Future<void> handle(AudiobookEvent event) async {
    if (event is AudiobookDescriptionUpdatedEvent) {
      try {
        await _handleAudiobookDescriptionUpdated(event);
      } catch (e) {
        _logger.error(
          'Failed to handle audiobook description updated event',
          error: e,
          extra: {'audiobookId': event.audiobookId},
        );
        throw GeneralFailure(
          message: 'Failed to handle audiobook description updated event: ${e.toString()}',
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> _handleAudiobookDescriptionUpdated(AudiobookDescriptionUpdatedEvent event) async {
    _logger.info(
      'Audiobook description updated',
      extra: {
        'audiobookId': event.audiobookId,
        'description': event.description,
        'previousDescription': event.previousDescription,
      },
    );

    // Add any additional logic for handling audiobook description updates
    // For example: update search index, send notifications, etc.
  }
}
