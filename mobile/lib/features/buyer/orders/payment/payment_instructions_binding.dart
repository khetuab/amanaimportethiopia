import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/payment_repository.dart';
import 'payment_instructions_controller.dart';

class PaymentInstructionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PaymentInstructionsController>(
      () => PaymentInstructionsController(
        PaymentRepository(Get.find<DioClient>()),
      ),
    );
  }
}
