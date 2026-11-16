import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../data/repositories/payment_repository.dart';
import 'submit_payment_evidence_controller.dart';

class SubmitPaymentEvidenceBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<CloudinaryService>(() => CloudinaryService(), fenix: true);
    Get.lazyPut<SubmitPaymentEvidenceController>(
          () => SubmitPaymentEvidenceController(
        PaymentRepository(dio),            // keep however you build it today
        Get.find<CloudinaryService>(),
      ),
    );
  }
}
