import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/order_repository.dart';
import 'buyer_orders_controller.dart';

class BuyerOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyerOrdersController>(
      () => BuyerOrdersController(OrderRepository(Get.find<DioClient>())),
    );
  }
}
