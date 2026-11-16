
import 'package:get/get.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../data/repositories/quotation_repository.dart';
import '../../../../data/repositories/request_repository.dart';
import 'quotation_detail_controller.dart';

class QuotationDetailBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();

    Get.lazyPut<QuotationDetailController>(
          () => QuotationDetailController(
        QuotationRepository(dio),
        dio,
        requests: RequestRepository(dio),
      ),
    );
  }
}
