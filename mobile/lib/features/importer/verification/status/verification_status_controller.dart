import 'package:get/get.dart';

import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/importer_profile_model.dart';
import '../../../../data/repositories/importer_repository.dart';
import '../../../../routes/app_routes.dart';

class VerificationStatusController extends GetxController {
  VerificationStatusController(this._repo);
  final ImporterRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<ImporterProfileModel> profile = Rxn<ImporterProfileModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _repo.getMyProfile();
      profile.value = res.profile;
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  void resubmit() =>
      Get.toNamed(AppRoutes.submitVerification)?.then((_) => load());

  void backToDashboard() => Get.offAllNamed(AppRoutes.importerShell);
}
