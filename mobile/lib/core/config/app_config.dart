class AppConfig {
  AppConfig._();

  static const String appName = 'Ethio Import';
  static const String appTagline = 'Import sourcing, made calm.';
  static const String currencyCode = 'ETB';

  // Network
  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 25);
  static const Duration sendTimeout = Duration(seconds: 30);

  // Pagination
  static const int defaultPageSize = 20;

  // Media
  static const int imageMaxWidthPx = 1600;
  static const int imageQuality = 78;
  static const int maxAttachmentsPerRequest = 10;

  // UIX
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration debounceShort = Duration(milliseconds: 300);
  static const Duration debounceMedium = Duration(milliseconds: 500);
}
