import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/review_model.dart';

class ReviewRepository {
  ReviewRepository(this._dio);
  final DioClient _dio;

  Future<ReviewModel> forOrder(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.reviewOrder(orderId),
        data: payload,
      );
      return ReviewModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<List<ReviewModel>> forImporter(String importerId) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.reviewsForImporter(importerId),
      );
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => ReviewModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
