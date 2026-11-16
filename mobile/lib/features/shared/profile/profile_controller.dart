import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/utils/error_handler.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../routes/app_routes.dart';

class ProfileController extends GetxController {
  ProfileController(this._auth, this._users);
  final AuthService _auth;
  final UserRepository _users;

  final RxBool loading = true.obs;
  final RxnString error = RxnString();
  final Rxn<UserModel> user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      user.value = await _users.getMe();
    } catch (e) {
      error.value = ErrorHandler.messageFor(e);
    } finally {
      loading.value = false;
    }
  }

  void openSettings() => Get.toNamed(AppRoutes.settings);
  void openNotifications() => Get.toNamed(AppRoutes.notifications);
  void openMessages() => Get.toNamed(AppRoutes.conversations);

  Future<void> logout() async {
    await _auth.logout();
    Get.offAllNamed('/auth/login');
  }
}
