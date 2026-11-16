import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../data/repositories/category_repository.dart';
import '../../../../data/repositories/request_repository.dart';
import 'create_request_controller.dart';

class CreateRequestBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();

    Get.lazyPut<CloudinaryService>(() => CloudinaryService(), fenix: true);

    Get.lazyPut<CreateRequestController>(
          () => CreateRequestController(
        CategoryRepository(dio),
        RequestRepository(dio),
        Get.find<CloudinaryService>(),
      ),
    );
  }
}