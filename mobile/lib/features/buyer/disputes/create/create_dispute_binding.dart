import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/dispute_repository.dart';
import 'create_dispute_controller.dart';

class CreateDisputeBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<CreateDisputeController>(
      () => CreateDisputeController(DisputeRepository(dio), dio),
    );
  }
}
