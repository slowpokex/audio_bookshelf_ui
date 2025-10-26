import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/audiobook_model.dart';
import '../../core/errors/exceptions.dart';
import '../../core/constants/app_constants.dart';

/// Remote data source for audiobooks using HTTP API
class AudiobookRemoteDataSource {
  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;

  AudiobookRemoteDataSource({
    required http.Client client,
    required String baseUrl,
    required String apiKey,
  }) : _client = client,
       _baseUrl = baseUrl,
       _apiKey = apiKey;

  /// Gets all audiobooks from remote API
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
    try {
      final uri = Uri.parse('$_baseUrl/audiobooks').replace(
        queryParameters: _buildQueryParameters(
          limit: limit,
          offset: offset,
          searchQuery: searchQuery,
          genre: genre,
          author: author,
          narrator: narrator,
          isCompleted: isCompleted,
          isFavorite: isFavorite,
          sortBy: sortBy,
          sortOrder: sortOrder,
        ),
      );

      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audiobooks = (data['data'] as List)
            .map((json) => AudiobookModel.fromJson(json))
            .toList();
        return audiobooks;
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to get audiobooks: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Gets an audiobook by ID from remote API
  Future<AudiobookModel?> getAudiobookById(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/audiobooks/$id');
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AudiobookModel.fromJson(data['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to get audiobook: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Creates a new audiobook on remote API
  Future<AudiobookModel> createAudiobook(AudiobookModel audiobook) async {
    try {
      final uri = Uri.parse('$_baseUrl/audiobooks');
      final response = await _client.post(
        uri,
        headers: _getHeaders(),
        body: json.encode(audiobook.toJson()),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return AudiobookModel.fromJson(data['data']);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to create audiobook: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Updates an existing audiobook on remote API
  Future<AudiobookModel> updateAudiobook(AudiobookModel audiobook) async {
    try {
      final uri = Uri.parse('$_baseUrl/audiobooks/${audiobook.id}');
      final response = await _client.put(
        uri,
        headers: _getHeaders(),
        body: json.encode(audiobook.toJson()),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AudiobookModel.fromJson(data['data']);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to update audiobook: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Deletes an audiobook from remote API
  Future<void> deleteAudiobook(String id) async {
    try {
      final uri = Uri.parse('$_baseUrl/audiobooks/$id');
      final response = await _client.delete(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode != 204) {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to delete audiobook: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Searches audiobooks on remote API
  Future<List<AudiobookModel>> searchAudiobooks({
    required String query,
    int? limit,
    int? offset,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, String>{
        'q': query,
        if (limit != null) 'limit': limit.toString(),
        if (offset != null) 'offset': offset.toString(),
      };

      // Add filters to query parameters
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
      }

      final uri = Uri.parse('$_baseUrl/audiobooks/search').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audiobooks = (data['data'] as List)
            .map((json) => AudiobookModel.fromJson(json))
            .toList();
        return audiobooks;
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to search audiobooks: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Gets recommendations from remote API
  Future<List<AudiobookModel>> getRecommendations({
    required String userId,
    int? limit,
    String? basedOn,
  }) async {
    try {
      final queryParams = <String, String>{
        'user_id': userId,
        if (limit != null) 'limit': limit.toString(),
        if (basedOn != null) 'based_on': basedOn,
      };

      final uri = Uri.parse('$_baseUrl/recommendations').replace(
        queryParameters: queryParams,
      );

      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final audiobooks = (data['data'] as List)
            .map((json) => AudiobookModel.fromJson(json))
            .toList();
        return audiobooks;
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to get recommendations: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Uploads an audiobook file
  Future<String> uploadAudiobookFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw FileSystemException(
          message: 'Audio file not found: $filePath',
          timestamp: DateTime.now(),
        );
      }

      final uri = Uri.parse('$_baseUrl/audiobooks/upload');
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(_getHeaders());
      request.files.add(await http.MultipartFile.fromPath('file', filePath));

      final response = await request.send().timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = json.decode(responseBody);
        return data['file_url'] as String;
      } else {
        throw _handleHttpError(await http.Response.fromStream(response));
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to upload audiobook file: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Downloads an audiobook file
  Future<void> downloadAudiobookFile(String url, String localPath) async {
    try {
      final uri = Uri.parse(url);
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to download audiobook file: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Gets audiobook metadata from external sources
  Future<Map<String, dynamic>> getAudiobookMetadata(String isbn) async {
    try {
      final uri = Uri.parse('$_baseUrl/audiobooks/metadata/$isbn');
      final response = await _client.get(
        uri,
        headers: _getHeaders(),
      ).timeout(AppConstants.defaultTimeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['metadata'] as Map<String, dynamic>;
      } else {
        throw _handleHttpError(response);
      }
    } catch (e) {
      if (e is AppException) rethrow;
      throw NetworkException(
        message: 'Failed to get audiobook metadata: ${e.toString()}',
        timestamp: DateTime.now(),
      );
    }
  }

  /// Builds query parameters for API requests
  Map<String, String> _buildQueryParameters({
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
  }) {
    final params = <String, String>{};

    if (limit != null) params['limit'] = limit.toString();
    if (offset != null) params['offset'] = offset.toString();
    if (searchQuery != null && searchQuery.isNotEmpty) {
      params['search'] = searchQuery;
    }
    if (genre != null && genre.isNotEmpty) params['genre'] = genre;
    if (author != null && author.isNotEmpty) params['author'] = author;
    if (narrator != null && narrator.isNotEmpty) params['narrator'] = narrator;
    if (isCompleted != null) params['completed'] = isCompleted.toString();
    if (isFavorite != null) params['favorite'] = isFavorite.toString();
    if (sortBy != null && sortBy.isNotEmpty) params['sort_by'] = sortBy;
    if (sortOrder != null && sortOrder.isNotEmpty) params['sort_order'] = sortOrder;

    return params;
  }

  /// Gets HTTP headers for API requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'User-Agent': 'AudioBookshelfUI/1.0.0',
    };
  }

  /// Handles HTTP errors
  AppException _handleHttpError(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: 'Bad request: $body',
          timestamp: DateTime.now(),
        );
      case 401:
        return AuthenticationException(
          message: 'Unauthorized: $body',
          timestamp: DateTime.now(),
        );
      case 403:
        return AuthorizationException(
          message: 'Forbidden: $body',
          timestamp: DateTime.now(),
        );
      case 404:
        return GeneralException(
          message: 'Not found: $body',
          timestamp: DateTime.now(),
        );
      case 409:
        return GeneralException(
          message: 'Conflict: $body',
          timestamp: DateTime.now(),
        );
      case 422:
        return ValidationException(
          message: 'Validation error: $body',
          timestamp: DateTime.now(),
        );
      case 429:
        return NetworkException(
          message: 'Rate limit exceeded: $body',
          timestamp: DateTime.now(),
        );
      case 500:
        return NetworkException(
          message: 'Server error: $body',
          timestamp: DateTime.now(),
        );
      case 502:
        return NetworkException(
          message: 'Bad gateway: $body',
          timestamp: DateTime.now(),
        );
      case 503:
        return NetworkException(
          message: 'Service unavailable: $body',
          timestamp: DateTime.now(),
        );
      case 504:
        return NetworkException(
          message: 'Gateway timeout: $body',
          timestamp: DateTime.now(),
        );
      default:
        return NetworkException(
          message: 'HTTP $statusCode: $body',
          timestamp: DateTime.now(),
        );
    }
  }
}
