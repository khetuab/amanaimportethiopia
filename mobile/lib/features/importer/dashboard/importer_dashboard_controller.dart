// lib/features/importer/dashboard/importer_dashboard_controller.dart
import 'package:get/get.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/models/importer_profile_model.dart';
import '../../../data/repositories/importer_repository.dart';

class ImporterDashboardController extends GetxController {
  ImporterDashboardController(this._auth, this._repo);

  final AuthService _auth;
  final ImporterRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<ImporterProfileModel> profile = Rxn<ImporterProfileModel>();

  String get userName =>
      _auth.user?.fullName.split(' ').first ?? 'importer.dashboard.there'.tr;

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
    } on ApiException catch (e) {
      // 404 = no profile submitted yet — that's not an error state.
      if (e.isNotFound || e.code == 'NOT_FOUND') {
        profile.value = null;
      } else {
        error.value = ErrorHandler.messageFor(e);
      }
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    Get.offAllNamed('/auth/login');
  }
}