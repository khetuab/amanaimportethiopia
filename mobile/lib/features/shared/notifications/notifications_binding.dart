import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/notification_repository.dart';
import 'notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(
        NotificationRepository(Get.find<DioClient>()),
      ),
    );
  }
}
