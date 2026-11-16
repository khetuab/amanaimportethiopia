import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/quotation_repository.dart';
import 'edit_quotation_controller.dart';

class EditQuotationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EditQuotationController>(
      () => EditQuotationController(QuotationRepository(Get.find<DioClient>())),
    );
  }
}
