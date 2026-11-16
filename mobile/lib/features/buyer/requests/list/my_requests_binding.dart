import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/request_repository.dart';
import 'my_requests_controller.dart';

class MyRequestsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyRequestsController>(
      () => MyRequestsController(RequestRepository(Get.find<DioClient>())),
    );
  }
}
