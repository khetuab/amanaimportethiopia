import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exception.dart';
import '../../core/network/api_interceptor.dart';
import '../../core/network/dio_client.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

class MessageRepository {
  MessageRepository(this._dio);
  final DioClient _dio;

  Future<List<ConversationModel>> conversations() async {
    try {
      final res = await _dio.dio.get(ApiEndpoints.conversations);
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => ConversationModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<List<MessageModel>> messages(
    String conversationId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.dio.get(
        ApiEndpoints.conversationMessages(conversationId),
        queryParameters: {'page': page, 'limit': limit},
      );
      final list = ((res.data as Map)['data'] as List?) ?? const [];
      return list
          .whereType<Map>()
          .map((m) => MessageModel.fromJson(m.cast<String, dynamic>()))
          .toList();
    } catch (e) {
      throw _toApi(e);
    }
  }

  Future<MessageModel> send(String conversationId, String body) async {
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.conversationMessages(conversationId),
        data: {'body': body},
      );
      return MessageModel.fromJson(
        ((res.data as Map)['data'] as Map).cast<String, dynamic>(),
      );
    } catch (e) {
      throw _toApi(e);
    }
  }

  ApiException _toApi(Object e) =>
      e is ApiException ? e : toApiException(e as dynamic);
}
