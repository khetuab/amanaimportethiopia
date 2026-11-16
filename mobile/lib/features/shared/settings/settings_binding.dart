import 'package:get/get.dart';
import '../../../core/localization/localization_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../data/repositories/user_repository.dart';
import 'settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(
        Get.find<ThemeController>(),
        Get.find<LocalizationService>(),
        UserRepository(Get.find<DioClient>()),
        Get.find<AuthService>(),
      ),
    );
  }
}
