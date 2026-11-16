import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/shipment_model.dart';

class ShipmentRepository {
  ShipmentRepository(this._dio);
  final DioClient _dio;

  Future<ShipmentModel> forOrder(String orderId) async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.shipmentForOrder(orderId));
      return ShipmentModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<ShipmentModel> addEvent(
    String orderId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.shipmentAddEvent(orderId),
        data: payload,
      );
      return ShipmentModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
