import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/category_repository.dart';
import '../../../data/repositories/request_repository.dart';
import 'browse_requests_controller.dart';

class BrowseRequestsBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<BrowseRequestsController>(
      () => BrowseRequestsController(
        Get.find<AuthService>(),
        CategoryRepository(dio),
        RequestRepository(dio),
      ),
    );
  }
}
