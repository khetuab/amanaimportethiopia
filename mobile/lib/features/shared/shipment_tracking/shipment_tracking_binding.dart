import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/shipment_repository.dart';
import 'shipment_tracking_controller.dart';

class ShipmentTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipmentTrackingController>(
      () =>
          ShipmentTrackingController(ShipmentRepository(Get.find<DioClient>())),
    );
  }
}
