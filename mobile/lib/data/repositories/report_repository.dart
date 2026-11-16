import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';

class ReportRepository {
  ReportRepository(this._dio);
  final DioClient _dio;

  Future<Map<String, dynamic>> submitFraudReport({
    required String category,
    required String description,
    String? relatedOrderId,
    List<Map<String, dynamic>> evidence = const [],
  }) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.fraudReports,
        data: {
          'category': category,
          'description': description,
          'relatedOrder': ?relatedOrderId,
          if (evidence.isNotEmpty) 'evidence': evidence,
        },
      );
      return ((res.data as Map)['data'] as Map).cast<String, dynamic>();
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
