import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../network/api_exception.dart';
import 'snackbar_helper.dart';

/// Central place for surfacing errors. Never print stack traces
/// to the UI — only friendly messages.
class ErrorHandler {
  ErrorHandler._();

  static String messageFor(Object error) {
    if (error is ApiException) {
      switch (error.code) {
        case 'NETWORK':
          return 'error.network'.tr;
        case 'TIMEOUT':
          return 'error.timeout'.tr;
        case 'INVALID_CREDENTIALS':
          return 'error.invalidCredentials'.tr;
        case 'IMPORTER_NOT_APPROVED':
          return 'error.importerNotApproved'.tr;
        case 'ALREADY_ACCEPTED':
          return 'error.alreadyAccepted'.tr;
        case 'INVALID_STATE_TRANSITION':
          return 'error.invalidStateTransition'.tr;
        case 'PAYMENT_ALREADY_SUBMITTED':
          return 'error.paymentAlreadySubmitted'.tr;
        default:
          return error.message;
      }
    }
    return 'error.generic'.tr;
  }

  static void toast(Object error) {
    SnackbarHelper.error(messageFor(error));
  }

  static Future<void> dialog(Object error) async {
    await Get.dialog(
      AlertDialog(
        title: Text('state.error.title'.tr),
        content: Text(messageFor(error)),
        actions: [TextButton(onPressed: Get.back, child: Text('common.ok'.tr))],
      ),
    );
  }
}
