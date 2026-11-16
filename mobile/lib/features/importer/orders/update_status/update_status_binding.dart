import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../data/repositories/shipment_repository.dart';
import 'update_status_controller.dart';

class UpdateStatusBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<UpdateStatusController>(
      () =>
          UpdateStatusController(OrderRepository(dio), ShipmentRepository(dio)),
    );
  }
}
