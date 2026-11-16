import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/order_repository.dart';
import 'buyer_order_detail_controller.dart';

class BuyerOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BuyerOrderDetailController>(
      () => BuyerOrderDetailController(OrderRepository(Get.find<DioClient>())),
    );
  }
}
