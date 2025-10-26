import 'dart:io';
import 'dart:typed_data';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

/// Service for handling file import operations
class FileImportService {
  // Cache for Android version detection to avoid repeated checks
  static int? _cachedAndroidSdkVersion;
  
  static const List<String> _supportedAudioFormats = [
    'mp3', 'm4a', 'm4b', 'aac', 'flac', 'ogg', 'wav'
  ];

  static const List<String> _supportedImageFormats = [
    'jpg', 'jpeg', 'png', 'webp'
  ];
  
  // Android SDK version constants
  static const int _android13SdkVersion = 33;

  /// Validates if the file format is supported for audio
  static bool isSupportedAudioFormat(String filePath) {
    final extension = path.extension(filePath).substring(1).toLowerCase();
    return _supportedAudioFormats.contains(extension);
  }

  /// Validates if the file format is supported for images
  static bool isSupportedImageFormat(String filePath) {
    final extension = path.extension(filePath).substring(1).toLowerCase();
    return _supportedImageFormats.contains(extension);
  }

  /// Validates audio file integrity
  static Future<AudioFileValidationResult> validateAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        return AudioFileValidationResult(
          isValid: false,
          error: 'File does not exist',
        );
      }

      // Check file size (minimum 1KB, maximum 2GB)
      final fileSize = await file.length();
      if (fileSize < 1024) {
        return AudioFileValidationResult(
          isValid: false,
          error: 'File is too small (minimum 1KB)',
        );
      }
      if (fileSize > 2 * 1024 * 1024 * 1024) {
        return AudioFileValidationResult(
          isValid: false,
          error: 'File is too large (maximum 2GB)',
        );
      }

      // Check file format
      if (!isSupportedAudioFormat(filePath)) {
        return AudioFileValidationResult(
          isValid: false,
          error: 'Unsupported audio format. Supported: ${_supportedAudioFormats.join(', ')}',
        );
      }

      // Basic file header validation
      final header = await _readFileHeader(file, 12);
      if (!_isValidAudioHeader(header, path.extension(filePath).substring(1).toLowerCase())) {
        return AudioFileValidationResult(
          isValid: false,
          error: 'Invalid audio file format',
        );
      }

      return AudioFileValidationResult(
        isValid: true,
        fileSize: fileSize,
        checksum: await _calculateChecksum(file),
      );
    } catch (e) {
      return AudioFileValidationResult(
        isValid: false,
        error: 'Failed to validate file: $e',
      );
    }
  }

  /// Validates image file integrity
  static Future<ImageFileValidationResult> validateImageFile(String filePath) async {
    try {
      final file = File(filePath);
      
      // Check if file exists
      if (!await file.exists()) {
        return ImageFileValidationResult(
          isValid: false,
          error: 'File does not exist',
        );
      }

      // Check file size (maximum 10MB for images)
      final fileSize = await file.length();
      if (fileSize > 10 * 1024 * 1024) {
        return ImageFileValidationResult(
          isValid: false,
          error: 'Image file is too large (maximum 10MB)',
        );
      }

      // Check file format
      if (!isSupportedImageFormat(filePath)) {
        return ImageFileValidationResult(
          isValid: false,
          error: 'Unsupported image format. Supported: ${_supportedImageFormats.join(', ')}',
        );
      }

      // Basic image header validation
      final header = await _readFileHeader(file, 8);
      if (!_isValidImageHeader(header, path.extension(filePath).substring(1).toLowerCase())) {
        return ImageFileValidationResult(
          isValid: false,
          error: 'Invalid image file format',
        );
      }

      return ImageFileValidationResult(
        isValid: true,
        fileSize: fileSize,
        checksum: await _calculateChecksum(file),
      );
    } catch (e) {
      return ImageFileValidationResult(
        isValid: false,
        error: 'Failed to validate image file: $e',
      );
    }
  }

  /// Copies file to app directory
  static Future<String> copyFileToAppDirectory(String sourcePath, String destinationDir) async {
    try {
      final sourceFile = File(sourcePath);
      final fileName = path.basename(sourcePath);
      final destinationPath = path.join(destinationDir, fileName);
      
      // Create destination directory if it doesn't exist
      final destinationDirFile = Directory(destinationDir);
      if (!await destinationDirFile.exists()) {
        await destinationDirFile.create(recursive: true);
      }

      // Copy file
      await sourceFile.copy(destinationPath);
      
      return destinationPath;
    } catch (e) {
      throw Exception('Failed to copy file: $e');
    }
  }

  /// Requests necessary permissions for file access
  /// Returns a Map with permission status and message for better error handling
  static Future<Map<String, dynamic>> requestPermissionsWithStatus() async {
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSdkVersion();
      
      if (sdkVersion >= _android13SdkVersion) {
        // Android 13+ (API 33+) - granular media permissions
        return await _requestGranularMediaPermissions();
      } else if (sdkVersion >= 29) {
        // Android 10-12 (API 29-32) - scoped storage
        return await _requestScopedStoragePermissions();
      } else {
        // Android 9 and below - legacy storage permissions
        return await _requestLegacyStoragePermissions();
      }
    }
    
    // iOS/other platforms don't need explicit storage permission
    return {
      'granted': true,
      'message': 'Permissions not required on this platform',
    };
  }

  /// Requests granular media permissions for Android 13+
  static Future<Map<String, dynamic>> _requestGranularMediaPermissions() async {
    try {
      // Request audio permission
      final audioStatus = await Permission.audio.request();
      
      if (!audioStatus.isGranted) {
        return {
          'granted': false,
          'message': 'Audio permission is required to access audiobook files',
          'status': audioStatus,
          'permissionType': 'audio',
        };
      }
      
      // Request photos permission for cover images (optional but recommended)
      final photosStatus = await Permission.photos.request();
      
      if (!photosStatus.isGranted) {
        // Photos permission is optional for audiobooks, so we continue
        // But log this for the user
        return {
          'granted': true,
          'message': 'Audio permission granted. Photo permission recommended for cover images',
          'photosStatus': photosStatus,
        };
      }
      
      return {
        'granted': true,
        'message': 'All permissions granted',
      };
    } catch (e) {
      return {
        'granted': false,
        'message': 'Failed to request permissions: $e',
        'error': e.toString(),
      };
    }
  }

  /// Requests scoped storage permissions for Android 10-12
  static Future<Map<String, dynamic>> _requestScopedStoragePermissions() async {
    try {
      final storageStatus = await Permission.storage.request();
      
      if (storageStatus.isGranted) {
        return {'granted': true, 'message': 'Storage permission granted'};
      }
      
      if (storageStatus.isPermanentlyDenied) {
        return {
          'granted': false,
          'message': 'Storage permission permanently denied. Please enable it in Settings.',
          'status': storageStatus,
          'requiresSettings': true,
        };
      }
      
      return {
        'granted': false,
        'message': 'Storage permission denied',
        'status': storageStatus,
      };
    } catch (e) {
      return {
        'granted': false,
        'message': 'Failed to request storage permission: $e',
        'error': e.toString(),
      };
    }
  }

  /// Requests legacy storage permissions for Android 9 and below
  static Future<Map<String, dynamic>> _requestLegacyStoragePermissions() async {
    try {
      // Check if we already have permission
      final storageStatus = await Permission.storage.status;
      
      if (storageStatus.isGranted) {
        return {'granted': true, 'message': 'Storage permission already granted'};
      }
      
      // Request permission
      final newStatus = await Permission.storage.request();
      
      if (newStatus.isGranted) {
        return {'granted': true, 'message': 'Storage permission granted'};
      }
      
      if (newStatus.isPermanentlyDenied) {
        return {
          'granted': false,
          'message': 'Storage permission permanently denied. Please enable it in Settings.',
          'status': newStatus,
          'requiresSettings': true,
        };
      }
      
      return {
        'granted': false,
        'message': 'Storage permission denied',
        'status': newStatus,
      };
    } catch (e) {
      return {
        'granted': false,
        'message': 'Failed to request storage permission: $e',
        'error': e.toString(),
      };
    }
  }

  /// Requests necessary permissions for file access (backward compatibility)
  static Future<bool> requestPermissions() async {
    final result = await requestPermissionsWithStatus();
    return result['granted'] as bool;
  }

  /// Checks if storage permissions are already granted
  static Future<bool> hasStoragePermissions() async {
    if (Platform.isAndroid) {
      final sdkVersion = await _getAndroidSdkVersion();
      
      if (sdkVersion >= _android13SdkVersion) {
        try {
          final audioStatus = await Permission.audio.status;
          final photosStatus = await Permission.photos.status;
          // Audio is required, photos is optional
          return audioStatus.isGranted;
        } catch (e) {
          // Fallback to storage permission check
          final storageStatus = await Permission.storage.status;
          return storageStatus.isGranted;
        }
      } else {
        final storageStatus = await Permission.storage.status;
        return storageStatus.isGranted;
      }
    }
    return true; // iOS/other platforms
  }

  /// Gets user-friendly permission error message
  static String getPermissionErrorMessage() {
    if (Platform.isAndroid) {
      return 'Storage permission is required to select audio files. Please grant permission in Settings.';
    }
    return 'File access permission is required.';
  }

  /// Gets Android SDK version (cached for performance)
  static Future<int> _getAndroidSdkVersion() async {
    // Return cached version if available
    if (_cachedAndroidSdkVersion != null) {
      return _cachedAndroidSdkVersion!;
    }
    
    if (!Platform.isAndroid) {
      _cachedAndroidSdkVersion = 0;
      return 0;
    }
    
    try {
      // Use platform channels to get SDK version
      // For now, we'll use the permission handler's capability check
      // In a production app, consider using device_info_plus package
      final audioStatus = await Permission.audio.status;
      
      // If Permission.audio is available and returns a valid status,
      // we're on Android 13+ (API 33+)
      if (audioStatus != null) {
        _cachedAndroidSdkVersion = _android13SdkVersion;
        return _cachedAndroidSdkVersion!;
      }
      
      // Fallback: assume Android 10+ for scoped storage
      // This is a conservative estimate
      _cachedAndroidSdkVersion = 29;
      return _cachedAndroidSdkVersion!;
    } catch (e) {
      // Default to Android 10 (API 29) for safety
      _cachedAndroidSdkVersion = 29;
      return _cachedAndroidSdkVersion!;
    }
  }

  /// Checks if the device is running Android 13 or above (backward compatibility)
  static Future<bool> _isAndroid13OrAbove() async {
    if (!Platform.isAndroid) return false;
    final sdkVersion = await _getAndroidSdkVersion();
    return sdkVersion >= _android13SdkVersion;
  }

  /// Gets app documents directory
  static Future<String> getAppDocumentsDirectory() async {
    try {
      // Use path_provider to get the app documents directory
      // This will give us the proper directory without needing explicit storage permissions
      final directory = await getApplicationDocumentsDirectory();
      return directory.path;
    } catch (e) {
      // Fallback to the old approach if path_provider fails
      final directory = Directory('/storage/emulated/0/Android/data/com.example.audio_bookshelf_ui/files');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    }
  }

  /// Copies multiple files from a folder to app directory
  static Future<List<String>> copyFolderFilesToAppDirectory(
    String sourceFolderPath,
    String destinationDir,
    List<String> filePaths,
  ) async {
    final List<String> destinationPaths = [];
    
    try {
      // Create destination directory if it doesn't exist
      final destinationDirFile = Directory(destinationDir);
      if (!await destinationDirFile.exists()) {
        await destinationDirFile.create(recursive: true);
      }

      for (final filePath in filePaths) {
        final sourceFile = File(filePath);
        final fileName = path.basename(filePath);
        final destinationPath = path.join(destinationDir, fileName);
        
        // Copy file
        await sourceFile.copy(destinationPath);
        destinationPaths.add(destinationPath);
      }
      
      return destinationPaths;
    } catch (e) {
      throw Exception('Failed to copy folder files: $e');
    }
  }

  /// Validates multiple audio files
  static Future<List<AudioFileValidationResult>> validateMultipleAudioFiles(
    List<String> filePaths,
  ) async {
    final List<AudioFileValidationResult> results = [];
    
    for (final filePath in filePaths) {
      final result = await validateAudioFile(filePath);
      results.add(result);
    }
    
    return results;
  }

  /// Gets total size of multiple files
  static Future<int> getTotalFileSize(List<String> filePaths) async {
    int totalSize = 0;
    
    for (final filePath in filePaths) {
      final file = File(filePath);
      if (await file.exists()) {
        totalSize += await file.length();
      }
    }
    
    return totalSize;
  }

  /// Estimates total duration for multiple audio files
  static Duration estimateTotalDuration(List<String> filePaths, List<String> formats) {
    Duration totalDuration = Duration.zero;
    
    for (int i = 0; i < filePaths.length; i++) {
      final file = File(filePaths[i]);
      final stat = file.statSync();
      final format = i < formats.length ? formats[i] : 'mp3';
      final duration = estimateAudioDuration(stat.size, format);
      totalDuration += duration;
    }
    
    return totalDuration;
  }

  /// Gets audiobooks directory
  static Future<String> getAudiobooksDirectory() async {
    final documentsDir = await getAppDocumentsDirectory();
    final audiobooksDir = Directory(path.join(documentsDir, 'audiobooks'));
    if (!await audiobooksDir.exists()) {
      await audiobooksDir.create(recursive: true);
    }
    return audiobooksDir.path;
  }

  /// Gets covers directory
  static Future<String> getCoversDirectory() async {
    final documentsDir = await getAppDocumentsDirectory();
    final coversDir = Directory(path.join(documentsDir, 'covers'));
    if (!await coversDir.exists()) {
      await coversDir.create(recursive: true);
    }
    return coversDir.path;
  }

  /// Estimates audio duration based on file size and format
  static Duration estimateAudioDuration(int fileSize, String format) {
    final bytesPerSecond = _getEstimatedBitrate(format) * 1000 / 8;
    final seconds = fileSize / bytesPerSecond;
    return Duration(seconds: seconds.round());
  }

  /// Gets estimated bitrate for audio format
  static int _getEstimatedBitrate(String format) {
    switch (format.toLowerCase()) {
      case 'mp3':
        return 128; // 128 kbps
      case 'm4a':
      case 'm4b':
        return 64; // 64 kbps
      case 'aac':
        return 128; // 128 kbps
      case 'flac':
        return 1000; // 1000 kbps
      case 'ogg':
        return 128; // 128 kbps
      case 'wav':
        return 1400; // 1400 kbps
      default:
        return 128;
    }
  }

  /// Reads file header for validation
  static Future<Uint8List> _readFileHeader(File file, int bytes) async {
    final randomAccessFile = await file.open();
    try {
      final header = Uint8List(bytes);
      await randomAccessFile.readInto(header);
      return header;
    } finally {
      await randomAccessFile.close();
    }
  }

  /// Validates audio file header
  static bool _isValidAudioHeader(Uint8List header, String format) {
    switch (format.toLowerCase()) {
      case 'mp3':
        // MP3 files start with ID3 tag or MPEG frame
        return (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33) || // ID3
               (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0); // MPEG
      case 'm4a':
      case 'm4b':
        // M4A/M4B files start with ftyp atom
        return header[4] == 0x66 && header[5] == 0x74 && header[6] == 0x79 && header[7] == 0x70;
      case 'aac':
        // AAC files start with ADTS header
        return (header[0] == 0xFF && (header[1] & 0xF0) == 0xF0);
      case 'flac':
        // FLAC files start with "fLaC"
        return header[0] == 0x66 && header[1] == 0x4C && header[2] == 0x61 && header[3] == 0x43;
      case 'ogg':
        // OGG files start with "OggS"
        return header[0] == 0x4F && header[1] == 0x67 && header[2] == 0x67 && header[3] == 0x53;
      case 'wav':
        // WAV files start with "RIFF"
        return header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46;
      default:
        return false;
    }
  }

  /// Validates image file header
  static bool _isValidImageHeader(Uint8List header, String format) {
    switch (format.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        // JPEG files start with FF D8
        return header[0] == 0xFF && header[1] == 0xD8;
      case 'png':
        // PNG files start with 89 50 4E 47
        return header[0] == 0x89 && header[1] == 0x50 && header[2] == 0x4E && header[3] == 0x47;
      case 'webp':
        // WebP files start with "RIFF" and contain "WEBP"
        return header[0] == 0x52 && header[1] == 0x49 && header[2] == 0x46 && header[3] == 0x46 &&
               header[8] == 0x57 && header[9] == 0x45 && header[10] == 0x42 && header[11] == 0x50;
      default:
        return false;
    }
  }

  /// Calculates file checksum
  static Future<String> _calculateChecksum(File file) async {
    final bytes = await file.readAsBytes();
    // Simple checksum calculation - in production, use proper crypto library
    int checksum = 0;
    for (int byte in bytes) {
      checksum = (checksum + byte) % 0xFFFFFFFF;
    }
    return checksum.toRadixString(16);
  }
}

/// Result of audio file validation
class AudioFileValidationResult {
  final bool isValid;
  final String? error;
  final int? fileSize;
  final String? checksum;

  const AudioFileValidationResult({
    required this.isValid,
    this.error,
    this.fileSize,
    this.checksum,
  });
}

/// Result of image file validation
class ImageFileValidationResult {
  final bool isValid;
  final String? error;
  final int? fileSize;
  final String? checksum;

  const ImageFileValidationResult({
    required this.isValid,
    this.error,
    this.fileSize,
    this.checksum,
  });
}
