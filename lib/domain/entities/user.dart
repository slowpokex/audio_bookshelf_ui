import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

/// User entity representing a user of the application
class User extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? displayName;
  final String? avatarPath;
  final String? language;
  final String? timezone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final bool isPremium;
  final Map<String, dynamic> preferences;
  final List<String> favoriteGenres;
  final List<String> favoriteAuthors;
  final List<String> favoriteNarrators;
  final double averageRating;
  final int totalBooksRead;
  final int totalHoursListened;
  final DateTime? lastActiveAt;
  final String? subscriptionType;
  final DateTime? subscriptionExpiresAt;
  final Map<String, dynamic> metadata;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.displayName,
    this.avatarPath,
    this.language,
    this.timezone,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.isPremium = false,
    this.preferences = const {},
    this.favoriteGenres = const [],
    this.favoriteAuthors = const [],
    this.favoriteNarrators = const [],
    this.averageRating = 0.0,
    this.totalBooksRead = 0,
    this.totalHoursListened = 0,
    this.lastActiveAt,
    this.subscriptionType,
    this.subscriptionExpiresAt,
    this.metadata = const {},
  });

  /// Creates a new user with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? displayName,
    String? avatarPath,
    String? language,
    String? timezone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    bool? isPremium,
    Map<String, dynamic>? preferences,
    List<String>? favoriteGenres,
    List<String>? favoriteAuthors,
    List<String>? favoriteNarrators,
    double? averageRating,
    int? totalBooksRead,
    int? totalHoursListened,
    DateTime? lastActiveAt,
    String? subscriptionType,
    DateTime? subscriptionExpiresAt,
    Map<String, dynamic>? metadata,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
      language: language ?? this.language,
      timezone: timezone ?? this.timezone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      isPremium: isPremium ?? this.isPremium,
      preferences: preferences ?? this.preferences,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
      favoriteAuthors: favoriteAuthors ?? this.favoriteAuthors,
      favoriteNarrators: favoriteNarrators ?? this.favoriteNarrators,
      averageRating: averageRating ?? this.averageRating,
      totalBooksRead: totalBooksRead ?? this.totalBooksRead,
      totalHoursListened: totalHoursListened ?? this.totalHoursListened,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Creates a user from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String?,
      avatarPath: json['avatarPath'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      isPremium: json['isPremium'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] as Map? ?? {}),
      favoriteGenres: List<String>.from(json['favoriteGenres'] as List? ?? []),
      favoriteAuthors: List<String>.from(json['favoriteAuthors'] as List? ?? []),
      favoriteNarrators: List<String>.from(json['favoriteNarrators'] as List? ?? []),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalBooksRead: json['totalBooksRead'] as int? ?? 0,
      totalHoursListened: json['totalHoursListened'] as int? ?? 0,
      lastActiveAt: json['lastActiveAt'] != null 
          ? DateTime.parse(json['lastActiveAt'] as String) 
          : null,
      subscriptionType: json['subscriptionType'] as String?,
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null 
          ? DateTime.parse(json['subscriptionExpiresAt'] as String) 
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  /// Converts user to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'displayName': displayName,
      'avatarPath': avatarPath,
      'language': language,
      'timezone': timezone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'isPremium': isPremium,
      'preferences': preferences,
      'favoriteGenres': favoriteGenres,
      'favoriteAuthors': favoriteAuthors,
      'favoriteNarrators': favoriteNarrators,
      'averageRating': averageRating,
      'totalBooksRead': totalBooksRead,
      'totalHoursListened': totalHoursListened,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'subscriptionType': subscriptionType,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// Creates a new user with default values
  factory User.create({
    required String username,
    required String email,
    String? displayName,
    String? language,
    String? timezone,
  }) {
    final now = DateTime.now();
    return User(
      id: const Uuid().v4(),
      username: username,
      email: email,
      displayName: displayName,
      language: language ?? 'en',
      timezone: timezone ?? 'UTC',
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Updates the user's last active timestamp
  User updateLastActive() {
    return copyWith(
      lastActiveAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Updates user preferences
  User updatePreferences(Map<String, dynamic> newPreferences) {
    final updatedPreferences = Map<String, dynamic>.from(preferences);
    updatedPreferences.addAll(newPreferences);
    
    return copyWith(
      preferences: updatedPreferences,
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a favorite genre
  User addFavoriteGenre(String genre) {
    if (favoriteGenres.contains(genre)) return this;
    
    return copyWith(
      favoriteGenres: [...favoriteGenres, genre],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a favorite genre
  User removeFavoriteGenre(String genre) {
    return copyWith(
      favoriteGenres: favoriteGenres.where((g) => g != genre).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a favorite author
  User addFavoriteAuthor(String author) {
    if (favoriteAuthors.contains(author)) return this;
    
    return copyWith(
      favoriteAuthors: [...favoriteAuthors, author],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a favorite author
  User removeFavoriteAuthor(String author) {
    return copyWith(
      favoriteAuthors: favoriteAuthors.where((a) => a != author).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Adds a favorite narrator
  User addFavoriteNarrator(String narrator) {
    if (favoriteNarrators.contains(narrator)) return this;
    
    return copyWith(
      favoriteNarrators: [...favoriteNarrators, narrator],
      updatedAt: DateTime.now(),
    );
  }

  /// Removes a favorite narrator
  User removeFavoriteNarrator(String narrator) {
    return copyWith(
      favoriteNarrators: favoriteNarrators.where((n) => n != narrator).toList(),
      updatedAt: DateTime.now(),
    );
  }

  /// Updates reading statistics
  User updateReadingStats({
    int? booksRead,
    int? hoursListened,
    double? averageRating,
  }) {
    return copyWith(
      totalBooksRead: totalBooksRead + (booksRead ?? 0),
      totalHoursListened: totalHoursListened + (hoursListened ?? 0),
      averageRating: averageRating ?? this.averageRating,
      updatedAt: DateTime.now(),
    );
  }

  /// Checks if user has premium subscription
  bool get hasPremiumSubscription {
    if (!isPremium) return false;
    if (subscriptionExpiresAt == null) return true;
    return subscriptionExpiresAt!.isAfter(DateTime.now());
  }

  /// Gets user's display name or username
  String get displayNameOrUsername => displayName ?? username;

  /// Gets user's avatar or default avatar
  String get avatarOrDefault => avatarPath ?? 'assets/images/default_avatar.png';

  /// Gets user's language or default
  String get languageOrDefault => language ?? 'en';

  /// Gets user's timezone or default
  String get timezoneOrDefault => timezone ?? 'UTC';

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    displayName,
    avatarPath,
    language,
    timezone,
    createdAt,
    updatedAt,
    isActive,
    isPremium,
    preferences,
    favoriteGenres,
    favoriteAuthors,
    favoriteNarrators,
    averageRating,
    totalBooksRead,
    totalHoursListened,
    lastActiveAt,
    subscriptionType,
    subscriptionExpiresAt,
    metadata,
  ];
}
