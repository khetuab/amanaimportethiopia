import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_sizes.dart';

/// Show a themed bottom sheet. Pass any widget.
Future<T?> showAppBottomSheet<T>({
  required Widget child,
  bool isScrollControlled = true,
}) {
  return Get.bottomSheet<T>(
    Container(
      decoration: BoxDecoration(
        color: Get.theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.lg,
            AppSizes.sm,
            AppSizes.lg,
            AppSizes.lg,
          ),
          child: child,
        ),
      ),
    ),
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
  );
}
