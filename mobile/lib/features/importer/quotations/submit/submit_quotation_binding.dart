import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/quotation_repository.dart';
import 'submit_quotation_controller.dart';

class SubmitQuotationBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<SubmitQuotationController>(
      () => SubmitQuotationController(QuotationRepository(dio), dio),
    );
  }
}
