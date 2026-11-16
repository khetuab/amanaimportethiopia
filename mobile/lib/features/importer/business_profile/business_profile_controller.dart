import 'package:get/get.dart';

import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../data/models/importer_profile_model.dart';
import '../../../../data/repositories/importer_repository.dart';
import '../../../../routes/app_routes.dart';

class BusinessProfileController extends GetxController {
  BusinessProfileController(this._auth, this._repo);
  final AuthService _auth;
  final ImporterRepository _repo;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<ImporterProfileModel> profile = Rxn<ImporterProfileModel>();
  final RxList<dynamic> documents = <dynamic>[].obs;

  String get userName => _auth.user?.fullName ?? 'importer.verification.eyebrow'.tr;
  String get userEmail => _auth.user?.email ?? '';
  String get userPhone => _auth.user?.phone ?? '';

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
      documents.assignAll(res.documents);
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  void editProfile() =>
      Get.toNamed(AppRoutes.submitVerification)?.then((_) => load());

  void viewVerificationStatus() => Get.toNamed(AppRoutes.verificationStatus);

  Future<void> logout() async {
    await _auth.logout();
    Get.offAllNamed('/auth/login');
  }
}
