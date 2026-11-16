import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  NotificationRepository(this._dio);
  final DioClient _dio;

  Future<({List<NotificationModel> items, int unreadCount})> list({
    bool unreadOnly = false,
  }) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.notifications,
        queryParameters: {if (unreadOnly) 'unreadOnly': true},
      );
      final body = res.data as Map;
      final list = (body['data'] as List?) ?? const [];
      final meta =
          ((body['meta'] as Map?)?['unreadCount'] as num?)?.toInt() ?? 0;
      return (
        items: list
            .whereType<Map>()
            .map((m) => NotificationModel.fromJson(m.cast<String, dynamic>()))
            .toList(),
        unreadCount: meta,
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> markRead(String id) async {
    try {
      await _dio.dio.patch(ApiEndpoints.notificationRead(id));
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<void> markAllRead() async {
    try {
      await _dio.dio.post(ApiEndpoints.notificationsReadAll);
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
