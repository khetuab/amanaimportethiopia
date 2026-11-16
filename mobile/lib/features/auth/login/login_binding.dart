import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/session_guard.dart';
import '../../../core/storage/local_storage.dart';
import 'login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginController>(
      () => LoginController(
        Get.find<AuthService>(),
        Get.find<SessionGuard>(),
        Get.find<LocalStorage>(),
      ),
      fenix: true,
    );
  }
}
