import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../utils/dialog_helper.dart';

/// Convenience wrapper that returns a Future<bool>.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String? confirmLabel,
  String? cancelLabel,
  bool destructive = false,
}) => DialogHelper.confirm(
  title: title,
  message: message,
  confirmLabel: confirmLabel,
  cancelLabel: cancelLabel,
  destructive: destructive,
);

/// Also expose a small widget form so widgets can host a dialog
/// without needing Get.
class ConfirmDialog extends StatelessWidget {
  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    this.destructive = false,
  });

  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
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
    );
  }
}
