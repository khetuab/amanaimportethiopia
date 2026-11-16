import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DialogHelper {
  DialogHelper._();

  static Future<bool> confirm({
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool destructive = false,
  }) async {
    final ctx = Get.context;
    if (ctx == null) return false;
    final scheme = Theme.of(ctx).colorScheme;

    final result = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(cancelLabel ?? 'common.cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: destructive ? scheme.error : scheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(confirmLabel ?? 'common.confirm'.tr),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static void loading({String? message}) {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static void close() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}
