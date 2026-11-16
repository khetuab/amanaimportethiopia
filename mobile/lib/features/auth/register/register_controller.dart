import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/storage_keys.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/notifications_service.dart';
import '../../../core/services/session_guard.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  RegisterController(this._auth, this._guard, this._local);
  final AuthService _auth;
  final SessionGuard _guard;
  final LocalStorage _local;

  final formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final RxString role = 'buyer'.obs;
  final RxBool loading = false.obs;
  final RxBool obscurePwd = true.obs;
  final RxBool obscureConfirm = true.obs;
  final RxBool agreed = false.obs;

  void setRole(String v) => role.value = v;
  void togglePwd() => obscurePwd.toggle();
  void toggleConfirm() => obscureConfirm.toggle();
  void toggleAgreed(bool? v) => agreed.value = v ?? false;

  Future<void> submit() async {
    if (loading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (!agreed.value) {
      SnackbarHelper.warning('auth.register.acceptTermsFirst'.tr);
      return;
    }
    loading.value = true;
    try {
      final user = await _auth.register(
        fullName: nameCtrl.text.trim(),
        email: emailCtrl.text.trim().toLowerCase(),
        phone: phoneCtrl.text.trim(),
        password: passwordCtrl.text,
        role: role.value,
      );
      await _local.setString(StorageKeys.lastUserRole, user.role);
      Get.find<NotificationsService>().refresh();
      SnackbarHelper.success('auth.register.accountCreated'.tr);
      Get.offAllNamed(_guard.routeForAuthenticated());
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      loading.value = false;
    }
  }

  String? validateName(String? v) {
    final s = (v ?? '').trim();
    if (s.length < 2) return 'auth.register.nameRequired'.tr;
    if (s.length > 120) return 'auth.register.nameTooLong'.tr;
    return null;
  }

  String? validateEmail(String? v) => Validators.email(v);
  String? validatePhone(String? v) => Validators.ethiopianPhone(v);
  String? validatePassword(String? v) => Validators.password(v);
  String? validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'auth.confirmPasswordRequired'.tr;
    if (v != passwordCtrl.text) return 'auth.passwordsDoNotMatch'.tr;
    return null;
  }

  //void goToLogin() => Get.offAllNamed(AppRoutes.login);

  void goToLogin() {
    // Reuse the login page that is already in the stack.
    var found = false;
    Get.until((route) {
      if (route.settings.name == AppRoutes.login) {
        found = true;
        return true;
      }
      return route.isFirst;
    });
    if (!found) Get.offAllNamed(AppRoutes.login); // login wasn't in the stack
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    passwordCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
