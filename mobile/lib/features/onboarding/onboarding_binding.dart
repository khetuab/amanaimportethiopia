import 'package:get/get.dart';
import '../../core/services/session_guard.dart';
import 'onboarding_controller.dart';

class OnboardingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OnboardingController>(
      () => OnboardingController(Get.find<SessionGuard>()),
    );
  }
}
