import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/importer_repository.dart';
import 'business_profile_controller.dart';

class BusinessProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessProfileController>(
      () => BusinessProfileController(
        Get.find<AuthService>(),
        ImporterRepository(Get.find<DioClient>()),
      ),
    );
  }
}
