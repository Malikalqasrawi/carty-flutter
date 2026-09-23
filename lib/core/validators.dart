/// Form validators. Each returns null when the value is valid,
/// or an error message to show under the field.
class Validators {
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? Function(String?) required(String fieldName) {
    return (value) {
      if (value == null || value.trim().isEmpty) return '$fieldName is required';
      return null;
    };
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) return 'Username is required';
    if (value.trim().contains(' ')) return 'Username must be one word (no spaces)';
    if (value.trim().length < 3) return 'Username must be at least 3 characters';
    return null;
  }

  /// Jordanian mobile: +962 then 9 digits starting with 7 (e.g. +962791234567).
  static String? jordanPhone(String? value) {
    final v = value?.replaceAll(' ', '') ?? '';
    if (!RegExp(r'^\+9627\d{8}$').hasMatch(v)) {
      return 'Use the format +9627XXXXXXXX';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.length < 10) {
      return 'Password must be at least 10 characters';
    }
    return null;
  }

  static String? Function(String?) confirmPassword(String Function() original) {
    return (value) => value == original() ? null : 'Passwords do not match';
  }
}
