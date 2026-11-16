import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/request_repository.dart';
import 'request_detail_controller.dart';

class RequestDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestDetailController>(
      () => RequestDetailController(RequestRepository(Get.find<DioClient>())),
    );
  }
}
