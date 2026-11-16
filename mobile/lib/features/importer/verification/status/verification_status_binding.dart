import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/importer_repository.dart';
import 'verification_status_controller.dart';

class VerificationStatusBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerificationStatusController>(
      () => VerificationStatusController(
        ImporterRepository(Get.find<DioClient>()),
      ),
    );
  }
}
