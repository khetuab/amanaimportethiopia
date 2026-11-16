import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

class UserRepository {
  UserRepository(this._dio);
  final DioClient _dio;

  Future<UserModel> getMe() async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.usersMe);
      return UserModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<UserModel> updateMe({
    String? fullName,
    String? preferredLanguage,
  }) async {
    try {
      final res = await _dio.dio.patch(
        ApiEndpoints.usersMe,
        data: {'fullName': ?fullName, 'preferredLanguage': ?preferredLanguage},
      );
      return UserModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.dio.post(
        ApiEndpoints.usersChangePassword,
        data: {'currentPassword': currentPassword, 'newPassword': newPassword},
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
