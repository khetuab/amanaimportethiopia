import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import 'forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<DioClient>()),
    );
  }
}
