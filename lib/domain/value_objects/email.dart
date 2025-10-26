import 'package:equatable/equatable.dart';

/// Email value object with validation
class Email extends Equatable {
  final String value;

  const Email(this.value);

  /// Creates an email from string with validation
  factory Email.fromString(String email) {
    if (!_isValidEmail(email)) {
      throw ArgumentError('Invalid email format: $email');
    }
    return Email(email.toLowerCase().trim());
  }

  /// Validates email format
  static bool _isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    );
    
    return emailRegex.hasMatch(email);
  }

  /// Gets the local part of the email (before @)
  String get localPart => value.split('@').first;

  /// Gets the domain part of the email (after @)
  String get domain => value.split('@').last;

  /// Checks if email is from a specific domain
  bool isFromDomain(String domain) {
    return this.domain.toLowerCase() == domain.toLowerCase();
  }

  /// Checks if email is from a common provider
  bool get isFromCommonProvider {
    const commonProviders = [
      'gmail.com',
      'yahoo.com',
      'hotmail.com',
      'outlook.com',
      'icloud.com',
      'aol.com',
    ];
    return commonProviders.contains(domain.toLowerCase());
  }

  /// Masks the email for privacy (e.g., j***@gmail.com)
  String get masked {
    if (localPart.length <= 2) return '***@$domain';
    
    final firstChar = localPart[0];
    final lastChar = localPart[localPart.length - 1];
    final maskedLocal = '$firstChar${'*' * (localPart.length - 2)}$lastChar';
    
    return '$maskedLocal@$domain';
  }

  @override
  String toString() => value;

  @override
  List<Object?> get props => [value];
}
