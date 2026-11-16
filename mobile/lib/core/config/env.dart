
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  Env._();

  static late final String apiBaseUrl;
  static late final String appEnv;

  static bool get isDev => appEnv == 'development';

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');

    apiBaseUrl = _required('API_BASE_URL');
    appEnv = dotenv.env['APP_ENV'] ?? 'development';

    final uri = Uri.tryParse(apiBaseUrl);

    if (uri == null ||
        !uri.hasScheme ||
        !uri.hasAuthority ||
        !(uri.scheme == 'https' ||
            (isDev && uri.scheme == 'http'))) {
      throw StateError('Invalid API_BASE_URL: $apiBaseUrl');
    }
  }

  static String _required(String key) {
    final value = dotenv.env[key];

    if (value == null || value.trim().isEmpty) {
      throw StateError(
        'Missing required env var: $key (check mobile/.env)',
      );
    }

    return value.trim();
  }
}
