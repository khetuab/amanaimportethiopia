import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/review_repository.dart';
import 'create_review_controller.dart';

class CreateReviewBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateReviewController>(
      () => CreateReviewController(ReviewRepository(Get.find<DioClient>())),
    );
  }
}
