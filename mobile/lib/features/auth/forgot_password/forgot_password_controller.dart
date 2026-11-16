import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/utils/error_handler.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/utils/validators.dart';
import '../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._dio);
  final DioClient _dio;

  final formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final newPasswordCtrl = TextEditingController();
  final tokenCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final RxInt step = 0.obs; // 0 = request, 1 = reset
  final RxBool loading = false.obs;
  final RxBool obscureNew = true.obs;

  void toggleNew() => obscureNew.toggle();

  Future<void> requestReset() async {
    if (loading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    loading.value = true;
    try {
      final res = await _dio.dio.post(
        ApiEndpoints.forgotPassword,
        data: {'email': emailCtrl.text.trim()},
      );
      final data = (res.data is Map) ? (res.data['data'] as Map?) : null;
      final devToken = data?['devResetToken']?.toString();
      if (devToken != null && devToken.isNotEmpty) {
        // Dev convenience — pre-fill so testing is smooth.
        tokenCtrl.text = devToken;
      }
      SnackbarHelper.success('auth.forgot.resetLinkSent'.tr);
      step.value = 1;
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> resetPassword() async {
    if (loading.value) return;
    if (!(formKey.currentState?.validate() ?? false)) return;
    if (newPasswordCtrl.text != confirmCtrl.text) {
      SnackbarHelper.warning('auth.passwordsDoNotMatch'.tr);
      return;
    }
    loading.value = true;
    try {
      await _dio.dio.post(
        ApiEndpoints.resetPassword,
        data: {
          'token': tokenCtrl.text.trim(),
          'password': newPasswordCtrl.text,
        },
      );
      SnackbarHelper.success(
        'auth.forgot.passwordUpdated'.tr,
      );
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      ErrorHandler.toast(e);
    } finally {
      loading.value = false;
    }
  }

  String? validateEmail(String? v) => Validators.email(v);
  String? validatePassword(String? v) => Validators.password(v);
  String? validateToken(String? v) {
    if ((v ?? '').trim().isEmpty) return 'auth.forgot.resetCodeRequired'.tr;
    return null;
  }

  String? validateConfirm(String? v) {
    if ((v ?? '').isEmpty) return 'auth.confirmPasswordRequired'.tr;
    if (v != newPasswordCtrl.text) return 'auth.passwordsDoNotMatch'.tr;
    return null;
  }

  void back() {
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
    emailCtrl.dispose();
    newPasswordCtrl.dispose();
    tokenCtrl.dispose();
    confirmCtrl.dispose();
    super.onClose();
  }
}
