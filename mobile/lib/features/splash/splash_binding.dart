import 'package:get/get.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/session_guard.dart';
import 'splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(Get.find<AuthService>(), Get.find<SessionGuard>()),
    );
  }
}
