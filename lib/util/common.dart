/// A function that converts a string to title case.
String toTitleCase(String text) {
  return text.toLowerCase().split(' ').map((word) {
    if (word.isEmpty) {
      return '';
    }
    return word[0].toUpperCase() + word.substring(1);
  }).join(' ');
}

/// A custom exception.
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, this.code);

  @override
  String toString() => message;
}