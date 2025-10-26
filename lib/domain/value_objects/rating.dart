import 'package:equatable/equatable.dart';

/// Rating value object with validation (0.0 to 5.0)
class Rating extends Equatable {
  final double value;

  const Rating(this.value);

  /// Creates a rating from double with validation
  factory Rating.fromDouble(double rating) {
    if (rating < 0.0 || rating > 5.0) {
      throw ArgumentError('Rating must be between 0.0 and 5.0, got: $rating');
    }
    return Rating(rating);
  }

  /// Creates a rating from integer (0 to 5)
  factory Rating.fromInt(int rating) {
    if (rating < 0 || rating > 5) {
      throw ArgumentError('Rating must be between 0 and 5, got: $rating');
    }
    return Rating(rating.toDouble());
  }

  /// Creates a rating from percentage (0 to 100)
  factory Rating.fromPercentage(int percentage) {
    if (percentage < 0 || percentage > 100) {
      throw ArgumentError('Percentage must be between 0 and 100, got: $percentage');
    }
    return Rating((percentage / 100.0 * 5.0).clamp(0.0, 5.0));
  }

  /// Gets the rating as a percentage (0 to 100)
  int get percentage => (value / 5.0 * 100).round();

  /// Gets the rating as an integer (0 to 5)
  int get integer => value.round();

  /// Gets the rating as stars (0 to 5)
  int get stars => value.round();

  /// Gets the rating as a string with one decimal place
  String get formatted => value.toStringAsFixed(1);

  /// Gets the rating as a string with stars
  String get starsString {
    final fullStars = value.floor();
    final hasHalfStar = value - fullStars >= 0.5;
    
    final stars = '★' * fullStars;
    final halfStar = hasHalfStar ? '☆' : '';
    final emptyStars = '☆' * (5 - fullStars - (hasHalfStar ? 1 : 0));
    
    return '$stars$halfStar$emptyStars';
  }

  /// Gets the rating as a string with emoji
  String get emojiString {
    if (value >= 4.5) return '⭐⭐⭐⭐⭐';
    if (value >= 3.5) return '⭐⭐⭐⭐☆';
    if (value >= 2.5) return '⭐⭐⭐☆☆';
    if (value >= 1.5) return '⭐⭐☆☆☆';
    if (value >= 0.5) return '⭐☆☆☆☆';
    return '☆☆☆☆☆';
  }

  /// Checks if rating is excellent (4.5+)
  bool get isExcellent => value >= 4.5;

  /// Checks if rating is good (3.5+)
  bool get isGood => value >= 3.5;

  /// Checks if rating is average (2.5+)
  bool get isAverage => value >= 2.5;

  /// Checks if rating is poor (1.5+)
  bool get isPoor => value >= 1.5;

  /// Checks if rating is terrible (0.5+)
  bool get isTerrible => value >= 0.5;

  /// Checks if rating is unrated (0.0)
  bool get isUnrated => value == 0.0;

  /// Gets the rating category
  RatingCategory get category {
    if (value >= 4.5) return RatingCategory.excellent;
    if (value >= 3.5) return RatingCategory.good;
    if (value >= 2.5) return RatingCategory.average;
    if (value >= 1.5) return RatingCategory.poor;
    if (value >= 0.5) return RatingCategory.terrible;
    return RatingCategory.unrated;
  }

  /// Gets the rating description
  String get description {
    switch (category) {
      case RatingCategory.excellent:
        return 'Excellent';
      case RatingCategory.good:
        return 'Good';
      case RatingCategory.average:
        return 'Average';
      case RatingCategory.poor:
        return 'Poor';
      case RatingCategory.terrible:
        return 'Terrible';
      case RatingCategory.unrated:
        return 'Unrated';
    }
  }

  /// Adds two ratings and returns the average
  Rating operator +(Rating other) {
    return Rating((value + other.value) / 2);
  }

  /// Compares two ratings
  int compareTo(Rating other) {
    return value.compareTo(other.value);
  }

  /// Checks if this rating is greater than another
  bool operator >(Rating other) => value > other.value;

  /// Checks if this rating is greater than or equal to another
  bool operator >=(Rating other) => value >= other.value;

  /// Checks if this rating is less than another
  bool operator <(Rating other) => value < other.value;

  /// Checks if this rating is less than or equal to another
  bool operator <=(Rating other) => value <= other.value;

  @override
  String toString() => formatted;

  @override
  List<Object?> get props => [value];
}

/// Rating categories
enum RatingCategory {
  unrated,
  terrible,
  poor,
  average,
  good,
  excellent,
}
