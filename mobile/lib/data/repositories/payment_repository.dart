import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/payment_record_model.dart';

class PaymentRepository {
  PaymentRepository(this._dio);
  final DioClient _dio;

  Future<Map<String, dynamic>> getInstructions(String orderId) async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.paymentInstructions(orderId));
      final data = ((res.data as Map)['data'] as Map).cast<String, dynamic>();
      return data;
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<PaymentRecordModel> submit(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.paymentSubmit(orderId),
        data: payload,
      );
      return PaymentRecordModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<List<PaymentRecordModel>> mineForOrder(String orderId) async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.paymentMineForOrder(orderId));
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => PaymentRecordModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
