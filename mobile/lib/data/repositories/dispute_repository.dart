import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/dispute_model.dart';

class DisputeRepository {
  DisputeRepository(this._dio);
  final DioClient _dio;

  Future<DisputeModel> open(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.disputeOpen(orderId),
        data: payload,
      );
      return DisputeModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<List<DisputeModel>> forOrder(String orderId) async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.disputesForOrder(orderId));
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => DisputeModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<DisputeModel> addMessage(String id, String body) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.disputeMessage(id),
        data: {'body': body},
      );
      return DisputeModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> withdraw(String id) async {
    try {
      await _dio.dio.post(ApiEndpoints.disputeWithdraw(id));
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
