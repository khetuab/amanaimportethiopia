class StorageKeys {
  StorageKeys._();

  // Secure storage (flutter_secure_storage)
  static const String accessToken = 'ethio.accessToken';
  static const String refreshToken = 'ethio.refreshToken';

  // Shared preferences (local_storage)
  static const String hasOnboarded = 'ethio.hasOnboarded';
  static const String themeMode = 'ethio.themeMode';
  static const String languageCode = 'ethio.languageCode';
  static const String lastUserRole = 'ethio.lastUserRole';
  static const String cachedUserJson = 'ethio.cachedUser';
  static const String fcmToken = 'ethio.fcmToken';
}
