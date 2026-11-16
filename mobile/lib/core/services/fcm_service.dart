import 'package:get/get.dart';

import '../constants/api_endpoints.dart';
import '../network/dio_client.dart';
import '../storage/local_storage.dart';
import '../constants/storage_keys.dart';

/// FCM integration is opt-in. When firebase_core + firebase_messaging are
/// uncommented in pubspec and Firebase config files exist, this service
/// registers the device and forwards foreground taps to deep links.
///
/// Today it uploads a token placeholder when the platform provides one.
class FcmService extends GetxService {
  FcmService(this._dio, this._local);
  final DioClient _dio;
  final LocalStorage _local;

  String? _token;

  Future<void> init() async {
    // Placeholder: no Firebase SDK linked yet.
    // When enabled, replace body with:
    //   await Firebase.initializeApp();
    //   final settings = await FirebaseMessaging.instance.requestPermission();
    //   final token = await FirebaseMessaging.instance.getToken();
    //   if (token != null) { _token = token; await _upload(token); }
    //   FirebaseMessaging.onMessage.listen((msg) => ...);
    _token = _local.getString(StorageKeys.fcmToken);
    if (_token != null && _token!.isNotEmpty) {
      await _upload(_token!);
    }
  }

  Future<void> _upload(String token) async {
    try {
      await _dio.dio.post(ApiEndpoints.usersFcmToken, data: {'token': token});
      await _local.setString(StorageKeys.fcmToken, token);
    } catch (_) {}
  }
}
