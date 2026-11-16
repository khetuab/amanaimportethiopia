import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/order_repository.dart';
import 'importer_orders_controller.dart';

class ImporterOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImporterOrdersController>(
      () => ImporterOrdersController(OrderRepository(Get.find<DioClient>())),
    );
  }
}
