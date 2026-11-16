import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository(this._dio);
  final DioClient _dio;

  Future<List<CategoryModel>> list() async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.categories);
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => CategoryModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
