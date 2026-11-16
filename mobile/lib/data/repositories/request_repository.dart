import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/product_request_model.dart';

class RequestRepository {
  RequestRepository(this._dio);
  final DioClient _dio;

  Future<ProductRequestModel> create(Map<String, dynamic> payload) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.createRequest,
        data: payload,
      );
      return ProductRequestModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<({List<ProductRequestModel> items, int page, int totalPages})>
  listMine({String? status, int page = 1, int limit = 20}) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.myRequests,
        queryParameters: {'status': ?status, 'page': page, 'limit': limit},
      );
      final body = res.data as Map;
      final list = (body['data'] as List?) ?? const [];
      final meta = ((body['meta'] as Map?)?['pagination'] as Map?) ?? const {};
      return (
        items: list
            .whereType<Map>()
            .map((m) => ProductRequestModel.fromJson(m.cast<String, dynamic>()))
            .toList(),
        page: (meta['page'] as num?)?.toInt() ?? 1,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<ProductRequestModel> getById(String id) async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.request(id));
      return ProductRequestModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<ProductRequestModel> publish(String id) async {
    try {
      final res = await _dio.dio.post(ApiEndpoints.requestPublish(id));
      return ProductRequestModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<ProductRequestModel> cancel(String id, {String? reason}) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.requestCancel(id),
        data: {'reason': ?reason},
      );
      return ProductRequestModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<({List<ProductRequestModel> items, int page, int totalPages})> browse({
    String? categoryId,
    String? city,
    double? budgetMin,
    double? budgetMax,
    String? q,
    String? sort,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.browseRequests,
        queryParameters: {
          'category': ?categoryId,
          'city': ?city,
          'budgetMin': ?budgetMin,
          'budgetMax': ?budgetMax,
          if (q != null && q.isNotEmpty) 'q': q,
          'sort': ?sort,
          'page': page,
          'limit': limit,
        },
      );
      final body = res.data as Map;
      final list = (body['data'] as List?) ?? const [];
      final meta = ((body['meta'] as Map?)?['pagination'] as Map?) ?? const {};
      return (
        items: list
            .whereType<Map>()
            .map((m) => ProductRequestModel.fromJson(m.cast<String, dynamic>()))
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
