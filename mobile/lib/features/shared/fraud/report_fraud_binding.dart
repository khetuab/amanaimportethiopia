import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../data/repositories/report_repository.dart';
import 'report_fraud_controller.dart';

class ReportFraudBinding extends Bindings {
  @override
  void dependencies() {
    final dio = Get.find<DioClient>();
    Get.lazyPut<ReportFraudController>(
      () => ReportFraudController(ReportRepository(dio), dio),
    );
  }
}
