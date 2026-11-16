import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/importer_repository.dart';
import 'importer_dashboard_controller.dart';

class ImporterDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImporterDashboardController>(
      () => ImporterDashboardController(
        Get.find<AuthService>(),
        ImporterRepository(Get.find<DioClient>()),
      ),
    );
  }
}
