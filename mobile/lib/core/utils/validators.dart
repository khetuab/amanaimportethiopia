/// Pure Dart validators. Safe to unit test without Flutter.
class Validators {
  Validators._();

  static final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
  static final _ethiopianPhone = RegExp(r'^(\+251|0)(9|7)\d{8}$');

  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'Email is required';
    if (!_emailRegex.hasMatch(s)) return 'Enter a valid email';
    return null;
  }

  static String? ethiopianPhone(String? v) {
    final s = (v ?? '').trim().replaceAll(' ', '');
    if (s.isEmpty) return 'Phone number is required';
    if (!_ethiopianPhone.hasMatch(s)) {
      return 'Use a valid Ethiopian number (e.g. 0911223344 or +251911223344)';
    }
    return null;
  }

  static String? required(String? v, {String field = 'This field'}) {
    if (v == null || v.trim().isEmpty) return '$field is required';
    return null;
  }

  static String? minLength(String? v, int min, {String? field}) {
    final s = (v ?? '').trim();
    if (s.length < min) {
      return '${field ?? 'Field'} must be at least $min characters';
    }
    return null;
  }

  static String? maxLength(String? v, int max, {String? field}) {
    final s = (v ?? '').trim();
    if (s.length > max) {
      return '${field ?? 'Field'} must be at most $max characters';
    }
    return null;
  }

  static String? password(String? v) {
    final s = v ?? '';
    if (s.length < 8) return 'At least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(s)) return 'Must include a letter';
    if (!RegExp(r'\d').hasMatch(s)) return 'Must include a digit';
    return null;
  }

  static String? positiveNumber(String? v, {String field = 'Value'}) {
    final n = double.tryParse((v ?? '').trim());
    if (n == null) return '$field must be a number';
    if (n <= 0) return '$field must be greater than zero';
    return null;
  }

  static String? url(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return null;
    final uri = Uri.tryParse(s);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'Enter a valid URL starting with http:// or https://';
    }
    return null;
  }
}
