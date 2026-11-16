import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notifications_service.dart';
import '../../../core/services/session_guard.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/error_handler.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  LoginController(this._auth, this._guard, this._local);
  final AuthService _auth;
  final SessionGuard _guard;
  final LocalStorage _local;

  final formKey = GlobalKey<FormState>();
  final identifierCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  final RxBool loading = false.obs;
  final RxBool obscure = true.obs;

  void toggleObscure() => obscure.toggle();

  Future<void> submit() async {
    if (loading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;

    loading.value = true;
    try {
      final user = await _auth.login(
        identifier: identifierCtrl.text.trim(),
        password: passwordCtrl.text,
      );
      await _local.setString(StorageKeys.lastUserRole, user.role);
      SnackbarHelper.success(
        'auth.login.welcomeBackName'
            .trParams({'name': user.fullName.split(' ').first}),
      );
      Get.find<NotificationsService>().refresh();
      Get.offAllNamed(_guard.routeForAuthenticated());
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      loading.value = false;
    }
  }

  String? validateIdentifier(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'auth.login.identifierRequired'.tr;
    // Allow email or Ethiopian phone.
    if (s.contains('@')) return Validators.email(s);
    return Validators.ethiopianPhone(s);
  }

  String? validatePassword(String? v) {
    if ((v ?? '').isEmpty) return 'auth.login.passwordRequired'.tr;
    return null;
  }

  void goToRegister() => Get.toNamed(AppRoutes.register);
  void goToForgotPassword() => Get.toNamed(AppRoutes.forgotPassword);

  @override
  void onClose() {
    identifierCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}
