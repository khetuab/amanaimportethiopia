import 'package:get/get.dart';
import '../../data/models/user_model.dart';
import '../../features/shared/notifications/notifications_controller.dart';
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';
import '../network/api_exception.dart';
import '../network/api_interceptor.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage.dart';

/// Owns the session. No screen talks to Dio for auth — they call this.
class AuthService extends GetxService {
  AuthService(this._dio, this._secure);

  final DioClient _dio;
  final SecureStorage _secure;

  final Rxn<UserModel> _user = Rxn<UserModel>();
  UserModel? get user => _user.value;
  bool get isAuthenticated => _user.value != null;

  RxString get roleStream => RxString(_user.value?.role ?? '');
  String get role => _user.value?.role ?? '';

  /// Called during bootstrap. If tokens exist, tries `/auth/me`.
  Future<void> restoreSession() async {
    final token = await _secure.read(StorageKeys.accessToken);
    if (token == null || token.isEmpty) return;
    try {
      final res = await _dio.dio.get(ApiEndpoints.me);
      final data = res.data;
      if (data is Map && data['data'] is Map) {
        _user.value = UserModel.fromJson(
          (data['data'] as Map).cast<String, dynamic>(),
        );
      }
    } catch (_) {
      // token invalid → clean
      await _secure.delete(StorageKeys.accessToken);
      await _secure.delete(StorageKeys.refreshToken);
    }
  }

  Future<UserModel> login({
    required String identifier,
    required String password,
  }) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.login,
        data: {'identifier': identifier, 'password': password},
      );
      final data = (res.data as Map)['data'] as Map;
      final tokens = data['tokens'] as Map;
      final user = UserModel.fromJson(
        (data['user'] as Map).cast<String, dynamic>(),
      );
      await _secure.write(
        StorageKeys.accessToken,
        tokens['accessToken'].toString(),
      );
      await _secure.write(
        StorageKeys.refreshToken,
        tokens['refreshToken'].toString(),
      );
      _user.value = user;
      if (Get.isRegistered<AuthServiceRoleTag>()) {
        Get.find<AuthServiceRoleTag>().role = _user.value?.role ?? 'buyer';
      }
      final savedToken = await _secure.read(StorageKeys.accessToken);

      Get.log(
        '[AUTH DEBUG] Access token saved: '
            '${savedToken != null && savedToken.trim().isNotEmpty}',
      );
      return user;
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String role, // buyer | importer
    String? buyerType,
  }) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.register,
        data: {
          'fullName': fullName,
          'email': email,
          'phone': phone,
          'password': password,
          'role': role,
          'buyerType': ?buyerType,
        },
      );
      final data = (res.data as Map)['data'] as Map;
      final tokens = data['tokens'] as Map;
      final user = UserModel.fromJson(
        (data['user'] as Map).cast<String, dynamic>(),
      );
      await _secure.write(
        StorageKeys.accessToken,
        tokens['accessToken'].toString(),
      );
      await _secure.write(
        StorageKeys.refreshToken,
        tokens['refreshToken'].toString(),
      );
      _user.value = user;
      return user;
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.dio.post(ApiEndpoints.logout);
    } catch (_) {}
    await _secure.delete(StorageKeys.accessToken);
    await _secure.delete(StorageKeys.refreshToken);
    _user.value = null;
  }

  void setUser(UserModel u) => _user.value = u;

  ApiException _toApi(Object e) {
    // AuthInterceptor converts DioException → ApiException via repository,
    // but AuthService is used directly during login, so convert here too.
    return toApiException(e as dynamic);
  }
}
