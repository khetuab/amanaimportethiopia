import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/quotation_model.dart';

class QuotationRepository {
  QuotationRepository(this._dio);
  final DioClient _dio;

  Future<QuotationModel> submit(
    String requestId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.quotationsForRequest(requestId),
        data: payload,
      );
      return QuotationModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<List<QuotationModel>> forRequest(String requestId) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.quotationsForRequest(requestId),
      );
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => QuotationModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<QuotationModel> update(String id, Map<String, dynamic> patch) async {
    try {
      final res = await _dio.dio.patch(ApiEndpoints.quotation(id), data: patch);
      return QuotationModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> withdraw(String id, {String? reason}) async {
    try {
      await _dio.dio.post(
        ApiEndpoints.quotationWithdraw(id),
        data: {'reason': ?reason},
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  /// Returns the newly created Order.
  Future<Map<String, dynamic>> accept(String id) async {
    try {
      final res = await _dio.dio.post(ApiEndpoints.quotationAccept(id));
      return ((res.data as Map)['data'] as Map).cast<String, dynamic>();
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<({List<QuotationModel> items, int page, int totalPages})>
  myQuotations({String? status, int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.myQuotations,
        queryParameters: {'status': ?status, 'page': page, 'limit': limit},
      );
      final body = res.data as Map;
      final list = (body['data'] as List?) ?? const [];
      final meta = ((body['meta'] as Map?)?['pagination'] as Map?) ?? const {};
      return (
        items: list
            .whereType<Map>()
            .map((m) => QuotationModel.fromJson(m.cast<String, dynamic>()))
            .toList(),
        page: (meta['page'] as num?)?.toInt() ?? 1,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
