/// Every failure from the network layer surfaces as ApiException.
/// UI code never sees DioException.
class ApiException implements Exception {
  ApiException({
    required this.message,
    this.code,
    this.statusCode,
    this.details,
  });

  final String message;
  final String? code;
  final int? statusCode;
  final dynamic details;

  bool get isAuthError => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidation => statusCode == 422 || code == 'VALIDATION_ERROR';
  bool get isConflict => statusCode == 409;
  bool get isRateLimited => statusCode == 429;
  bool get isNetwork => statusCode == null;

  /// Backend returns `{ error: { code, message, details } }`.
  factory ApiException.fromJson(
    dynamic data, {
    int? statusCode,
    String fallback = 'Something went wrong. Please try again.',
  }) {
    try {
      if (data is Map) {
        final err = data['error'];
        if (err is Map) {
          return ApiException(
            message: (err['message'] ?? fallback).toString(),
            code: err['code']?.toString(),
            statusCode: statusCode,
            details: err['details'],
          );
        }
      }
    } catch (_) {}
    return ApiException(message: fallback, statusCode: statusCode);
  }

  @override
  String toString() => 'ApiException($statusCode · $code): $message';
}
