import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/quotation_repository.dart';
import 'compare_quotations_controller.dart';

class CompareQuotationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompareQuotationsController>(
      () => CompareQuotationsController(
        QuotationRepository(Get.find<DioClient>()),
      ),
    );
  }
}
