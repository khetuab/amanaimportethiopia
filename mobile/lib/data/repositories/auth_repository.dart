import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/user_model.dart';

class AuthRepository {
  AuthRepository(this._dio);
  final DioClient _dio;

  Future<UserModel> me() async {
    try {
      final res = await _dio.dio.get('/auth/me');
      return UserModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
