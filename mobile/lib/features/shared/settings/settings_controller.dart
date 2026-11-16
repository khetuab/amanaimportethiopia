import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/localization/localization_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../data/repositories/user_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._theme, this._loc, this._users, this._auth);
  final ThemeController _theme;
  final LocalizationService _loc;
  final UserRepository _users;
  final AuthService _auth;

  final oldPwdCtrl = TextEditingController();
  final newPwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();
  final RxBool changingPwd = false.obs;

  ThemeMode get mode => _theme.themeMode.value;
  void setTheme(ThemeMode m) => _theme.setMode(m);

  final RxString languageCode = 'en'.obs;

  Future<void> setLanguage(String code) async {
    await _loc.changeLanguage(code);
    languageCode.value = code;

    SnackbarHelper.success('settings.languageUpdated'.tr);
  }

  Future<void> changePassword() async {
    if (changingPwd.value) return;
    if (newPwdCtrl.text != confirmPwdCtrl.text) {
      SnackbarHelper.warning('settings.passwordsDoNotMatch'.tr);
      return;
    }
    changingPwd.value = true;
    try {
      await _users.changePassword(
        currentPassword: oldPwdCtrl.text,
        newPassword: newPwdCtrl.text,
      );
      SnackbarHelper.success('settings.passwordUpdated'.tr);
      oldPwdCtrl.clear();
      newPwdCtrl.clear();
      confirmPwdCtrl.clear();
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      changingPwd.value = false;
    }
  }

  Future<void> deleteAccount() async {
    final ok = await Get.dialog<bool>(
      AlertDialog(
        title: Text('settings.deleteAccountTitle'.tr),
        content: Text(
          'settings.deleteAccountBody'.tr,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).colorScheme.error,
            ),
            child: Text('common.delete'.tr),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      // Requires password confirmation in backend; we use a simple prompt.
      final pwd = await Get.dialog<String?>(
        AlertDialog(
          title: Text('settings.confirmPasswordTitle'.tr),
          content: TextField(
            controller: oldPwdCtrl,
            obscureText: true,
            decoration: InputDecoration(labelText: 'auth.password'.tr),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: null),
              child: Text('common.cancel'.tr),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: oldPwdCtrl.text),
              child: Text('common.confirm'.tr),
            ),
          ],
        ),
      );
      if (pwd == null || pwd.isEmpty) return;
      // Backend endpoint not yet exposed — sign out safely.
      await _auth.logout();
      Get.offAllNamed('/auth/login');
      SnackbarHelper.info('settings.signedOutForDeletion'.tr);
    } catch (e) {
      ErrorHandler.toast(e);
    }
  }

  @override
  void onClose() {
    oldPwdCtrl.dispose();
    newPwdCtrl.dispose();
    confirmPwdCtrl.dispose();
    super.onClose();
  }
}
