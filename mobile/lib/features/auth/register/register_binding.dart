import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/session_guard.dart';
import '../../../core/storage/local_storage.dart';
import 'register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(
        Get.find<AuthService>(),
        Get.find<SessionGuard>(),
        Get.find<LocalStorage>(),
      ),
    );
  }
}
