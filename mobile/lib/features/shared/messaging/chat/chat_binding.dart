import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/message_repository.dart';
import 'chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(
      () => ChatController(
        MessageRepository(Get.find<DioClient>()),
        Get.find<AuthService>(),
      ),
    );
  }
}
