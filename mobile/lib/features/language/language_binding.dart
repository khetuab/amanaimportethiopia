import 'package:get/get.dart';
import '../../core/localization/localization_service.dart';
import '../../core/services/session_guard.dart';
import 'language_controller.dart';

class LanguageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LanguageController>(
      () => LanguageController(
        Get.find<LocalizationService>(),
        Get.find<SessionGuard>(),
      ),
    );
  }
}
