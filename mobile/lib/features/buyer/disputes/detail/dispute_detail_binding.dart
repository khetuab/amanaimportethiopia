import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/dispute_repository.dart';
import 'dispute_detail_controller.dart';

class DisputeDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DisputeDetailController>(
      () => DisputeDetailController(DisputeRepository(Get.find<DioClient>())),
    );
  }
}
