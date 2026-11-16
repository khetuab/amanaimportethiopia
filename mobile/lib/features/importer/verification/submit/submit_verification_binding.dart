import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/importer_repository.dart';
import 'submit_verification_controller.dart';

class SubmitVerificationBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<SubmitVerificationController>(
      () => SubmitVerificationController(ImporterRepository(dio), dio),
    );
  }
}
