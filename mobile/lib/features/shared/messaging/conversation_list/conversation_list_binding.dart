import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/message_repository.dart';
import 'conversation_list_controller.dart';

class ConversationListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConversationListController>(
      () =>
          ConversationListController(MessageRepository(Get.find<DioClient>())),
    );
  }
}
