import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/order_repository.dart';
import 'importer_order_detail_controller.dart';

class ImporterOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImporterOrderDetailController>(
      () =>
          ImporterOrderDetailController(OrderRepository(Get.find<DioClient>())),
    );
  }
}
