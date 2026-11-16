import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/order_model.dart';

class OrderRepository {
  OrderRepository(this._dio);
  final DioClient _dio;

  Future<({List<OrderModel> items, int page, int totalPages})> list({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.orders,
        queryParameters: {'status': ?status, 'page': page, 'limit': limit},
      );
      final body = res.data as Map;
      final list = (body['data'] as List?) ?? const [];
      final meta = ((body['meta'] as Map?)?['pagination'] as Map?) ?? const {};
      return (
        items: list
            .whereType<Map>()
            .map((m) => OrderModel.fromJson(m.cast<String, dynamic>()))
            .toList(),
        page: (meta['page'] as num?)?.toInt() ?? 1,
        totalPages: (meta['totalPages'] as num?)?.toInt() ?? 1,
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<OrderModel> getById(String id) async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.order(id));
      return OrderModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<OrderModel> transition(
    String id,
    String action, {
    String? note,
  }) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.orderTransition(id),
        data: {'action': action, 'note': ?note},
      );
      return OrderModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
