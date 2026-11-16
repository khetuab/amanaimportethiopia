import 'package:get/get.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/quotation_repository.dart';
import 'my_quotations_controller.dart';

class MyQuotationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MyQuotationsController>(
      () => MyQuotationsController(QuotationRepository(Get.find<DioClient>())),
    );
  }
}
