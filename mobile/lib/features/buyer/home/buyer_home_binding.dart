import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/request_repository.dart';
import 'buyer_home_controller.dart';

class BuyerHomeBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<BuyerHomeController>(
      () => BuyerHomeController(
        Get.find<AuthService>(),
        CategoryRepository(dio),
        RequestRepository(dio),
      ),
    );
  }
}
