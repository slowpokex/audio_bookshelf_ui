import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../core/services/database_service.dart';
import '../../core/utils/app_logger.dart';
import '../models/audiobook_model.dart';

/// Local data source for audiobooks using SQLite
class AudiobookLocalDataSource {
  static const String _tableName = 'audiobooks';
  static const String _databaseName = 'audiobookshelf.db';
  static const int _databaseVersion = 1;

  Database? _database;

  /// Gets the database instance
  Future<Database> get database async {
    AppLogger.logDatabaseOperation('get_database', 'audiobook_local_data_source');
    
    if (_database != null) {
      AppLogger.logDebug('Using existing database instance');
      return _database!;
    }
    
    AppLogger.logDebug('No existing database, initializing...');
    
    // Ensure database service is properly initialized
    try {
      AppLogger.logDebug('Calling DatabaseService.ensureInitialized()');
      await DatabaseService.ensureInitialized();
      AppLogger.logDebug('DatabaseService.ensureInitialized() completed successfully');
    } catch (e) {
      AppLogger.logDatabaseError('ensureInitialized', 'database_service', e.toString(), StackTrace.current);
      // If initialization fails, try to force re-initialization
      try {
        AppLogger.logDebug('Attempting force re-initialization');
        await DatabaseService.forceReinitialize();
        AppLogger.logDebug('Force re-initialization completed successfully');
      } catch (reinitError) {
        AppLogger.logDatabaseError('forceReinitialize', 'database_service', reinitError.toString(), StackTrace.current);
        throw Exception('Failed to initialize database service: $e. Re-initialization also failed: $reinitError');
      }
    }
    
    try {
      AppLogger.logDebug('Calling _initDatabase()');
      _database = await _initDatabase();
      AppLogger.logDatabaseOperation('init_database', 'audiobook_local_data_source', duration: 0);
      return _database!;
    } catch (e) {
      AppLogger.logDatabaseError('init_database', 'audiobook_local_data_source', e.toString(), StackTrace.current);
      throw Exception('Failed to initialize database: $e');
    }
  }

  /// Initializes the database
  Future<Database> _initDatabase() async {
    AppLogger.logDatabaseOperation('_initDatabase', 'audiobook_local_data_source');
    
    AppLogger.logDebug('Mobile platform detected, using file database');
    // For mobile platforms (Android/iOS)
    // Database factory is already initialized via DatabaseService.ensureInitialized()
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/$_databaseName';
    AppLogger.logDebug('Database path: $path');
    
    try {
      final db = await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
      AppLogger.logDatabaseOperation('open_database', 'audiobook_local_data_source', duration: 0);
      return db;
    } catch (e) {
      AppLogger.logDatabaseError('open_database', 'audiobook_local_data_source', e.toString(), StackTrace.current);
      rethrow;
    }
  }

  /// Creates the database tables
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        author TEXT NOT NULL,
        narrator TEXT,
        description TEXT,
        genre TEXT,
        year INTEGER,
        isbn TEXT,
        publisher TEXT,
        language TEXT,
        duration INTEGER,
        cover_image_path TEXT,
        audio_file_path TEXT,
        tags TEXT,
        series TEXT,
        series_order INTEGER,
        series_id TEXT,
        metadata TEXT,
        is_local INTEGER NOT NULL DEFAULT 0,
        local_path TEXT,
        is_completed INTEGER NOT NULL DEFAULT 0,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 0.0,
        play_count INTEGER NOT NULL DEFAULT 0,
        last_played_at INTEGER,
        current_position INTEGER,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_audiobooks_title ON $_tableName (title)');
    await db.execute('CREATE INDEX idx_audiobooks_author ON $_tableName (author)');
    await db.execute('CREATE INDEX idx_audiobooks_genre ON $_tableName (genre)');
    await db.execute('CREATE INDEX idx_audiobooks_is_completed ON $_tableName (is_completed)');
    await db.execute('CREATE INDEX idx_audiobooks_is_favorite ON $_tableName (is_favorite)');
    await db.execute('CREATE INDEX idx_audiobooks_rating ON $_tableName (rating)');
    await db.execute('CREATE INDEX idx_audiobooks_created_at ON $_tableName (created_at)');
    await db.execute('CREATE INDEX idx_audiobooks_updated_at ON $_tableName (updated_at)');
  }

  /// Upgrades the database
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle database upgrades here
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
    }
  }

  /// Gets all audiobooks with optional filters
  Future<List<AudiobookModel>> getAudiobooks({
    int? limit,
    int? offset,
    String? searchQuery,
    String? genre,
    String? author,
    String? narrator,
    bool? isCompleted,
    bool? isFavorite,
    String? sortBy,
    String? sortOrder,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];

    // Build WHERE clause based on filters
    if (searchQuery != null && searchQuery.isNotEmpty) {
      whereClause += ' AND (title LIKE ? OR author LIKE ? OR description LIKE ?)';
      whereArgs.addAll(['%$searchQuery%', '%$searchQuery%', '%$searchQuery%']);
    }

    if (genre != null && genre.isNotEmpty) {
      whereClause += ' AND genre = ?';
      whereArgs.add(genre);
    }

    if (author != null && author.isNotEmpty) {
      whereClause += ' AND author = ?';
      whereArgs.add(author);
    }

    if (narrator != null && narrator.isNotEmpty) {
      whereClause += ' AND narrator = ?';
      whereArgs.add(narrator);
    }

    if (isCompleted != null) {
      whereClause += ' AND is_completed = ?';
      whereArgs.add(isCompleted ? 1 : 0);
    }

    if (isFavorite != null) {
      whereClause += ' AND is_favorite = ?';
      whereArgs.add(isFavorite ? 1 : 0);
    }

    // Build ORDER BY clause
    String orderBy = 'created_at DESC';
    if (sortBy != null && sortBy.isNotEmpty) {
      String columnName;
      switch (sortBy) {
        case 'title':
          columnName = 'title';
          break;
        case 'author':
          columnName = 'author';
          break;
        case 'rating':
          columnName = 'rating';
          break;
        case 'duration':
          columnName = 'duration';
          break;
        case 'created_at':
          columnName = 'created_at';
          break;
        case 'updated_at':
          columnName = 'updated_at';
          break;
        case 'last_played_at':
        case 'last_played': // Support both variants
          columnName = 'last_played_at';
          break;
        case 'play_count':
          columnName = 'play_count';
          break;
        default:
          // If sortBy doesn't match any case, use default
          columnName = 'created_at';
          break;
      }
      
      // Build order by from scratch (no DESC in default)
      if (sortOrder == 'asc') {
        orderBy = '$columnName ASC';
      } else {
        orderBy = '$columnName DESC';
      }
    }

    // Build LIMIT and OFFSET clause
    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
      if (offset != null) {
        limitClause += ' OFFSET $offset';
      }
    }

    final query = '''
      SELECT * FROM $_tableName
      ${whereClause.isNotEmpty ? 'WHERE ${whereClause.substring(5)}' : ''}
      ORDER BY $orderBy
      $limitClause
    ''';

    final results = await db.rawQuery(query, whereArgs);
    return results.map((row) => AudiobookModel.fromMap(row)).toList();
  }

  /// Gets an audiobook by ID
  Future<AudiobookModel?> getAudiobookById(String id) async {
    final db = await database;
    final results = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return AudiobookModel.fromMap(results.first);
  }

  /// Creates a new audiobook
  Future<AudiobookModel> createAudiobook(AudiobookModel audiobook) async {
    final db = await database;
    await db.insert(_tableName, audiobook.toMap());
    return audiobook;
  }

  /// Updates an existing audiobook
  Future<AudiobookModel> updateAudiobook(AudiobookModel audiobook) async {
    final db = await database;
    await db.update(
      _tableName,
      audiobook.toMap(),
      where: 'id = ?',
      whereArgs: [audiobook.id],
    );
    return audiobook;
  }

  /// Deletes an audiobook
  Future<void> deleteAudiobook(String id) async {
    final db = await database;
    await db.delete(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Caches an audiobook (inserts or updates)
  Future<void> cacheAudiobook(AudiobookModel audiobook) async {
    final db = await database;
    await db.insert(
      _tableName,
      audiobook.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Batch caches multiple audiobooks efficiently using a transaction.
  /// This is much faster than calling cacheAudiobook multiple times sequentially.
  Future<void> cacheAudiobooks(List<AudiobookModel> audiobooks) async {
    if (audiobooks.isEmpty) return;
    
    final db = await database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final audiobook in audiobooks) {
        batch.insert(
          _tableName,
          audiobook.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    });
  }

  /// Searches audiobooks
  Future<List<AudiobookModel>> searchAudiobooks({
    required String searchQuery,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    final db = await database;
    
    String whereClause = 'AND (title LIKE ? OR author LIKE ? OR description LIKE ? OR narrator LIKE ?)';
    List<dynamic> whereArgs = ['%$searchQuery%', '%$searchQuery%', '%$searchQuery%', '%$searchQuery%'];

    // Apply additional filters
    if (filters != null) {
      if (filters['genre'] != null) {
        whereClause += ' AND genre = ?';
        whereArgs.add(filters['genre']);
      }
      if (filters['author'] != null) {
        whereClause += ' AND author = ?';
        whereArgs.add(filters['author']);
      }
      if (filters['narrator'] != null) {
        whereClause += ' AND narrator = ?';
        whereArgs.add(filters['narrator']);
      }
      if (filters['isCompleted'] != null) {
        whereClause += ' AND is_completed = ?';
        whereArgs.add(filters['isCompleted'] ? 1 : 0);
      }
      if (filters['isFavorite'] != null) {
        whereClause += ' AND is_favorite = ?';
        whereArgs.add(filters['isFavorite'] ? 1 : 0);
      }
    }

    // Build LIMIT and OFFSET clause
    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
      if (offset != null) {
        limitClause += ' OFFSET $offset';
      }
    }

    final query = '''
      SELECT * FROM $_tableName
      WHERE ${whereClause.substring(5)}
      ORDER BY title ASC
      $limitClause
    ''';

    final results = await db.rawQuery(query, whereArgs);
    return results.map((row) => AudiobookModel.fromMap(row)).toList();
  }

  /// Gets recommendations
  Future<List<AudiobookModel>> getRecommendations({
    required String userId,
    int? limit,
    String? basedOn,
  }) async {
    final db = await database;
    
    // Simple recommendation logic based on user preferences
    // This could be enhanced with more sophisticated algorithms
    String orderBy = 'rating DESC, play_count DESC';
    
    if (basedOn == 'genre') {
      // Get audiobooks with high ratings in user's favorite genres
      orderBy = 'rating DESC, genre';
    } else if (basedOn == 'author') {
      // Get audiobooks by user's favorite authors
      orderBy = 'author, rating DESC';
    } else if (basedOn == 'narrator') {
      // Get audiobooks by user's favorite narrators
      orderBy = 'narrator, rating DESC';
    }

    // Build LIMIT clause
    String limitClause = '';
    if (limit != null) {
      limitClause = 'LIMIT $limit';
    }

    final query = '''
      SELECT * FROM $_tableName
      WHERE rating > 3.0
      ORDER BY $orderBy
      $limitClause
    ''';

    final results = await db.rawQuery(query);
    return results.map((row) => AudiobookModel.fromMap(row)).toList();
  }

  /// Clears all cached audiobooks
  Future<void> clearCache() async {
    final db = await database;
    await db.delete(_tableName);
  }

  /// Gets the count of cached audiobooks
  Future<int> getCacheCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $_tableName');
    return result.first['count'] as int;
  }

  /// Gets the size of the cache in bytes
  Future<int> getCacheSize() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final dbFile = File('${documentsDirectory.path}/$_databaseName');
    
    if (await dbFile.exists()) {
      return await dbFile.length();
    }
    
    return 0;
  }

  /// Closes the database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
