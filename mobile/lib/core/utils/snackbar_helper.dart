import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_theme.dart';

enum _Kind { success, error, info, warning }

class SnackbarHelper {
  SnackbarHelper._();

  static void success(String message) => _show(message, _Kind.success);

  static void error(String message) => _show(message, _Kind.error);

  static void info(String message) => _show(message, _Kind.info);

  static void warning(String message) => _show(message, _Kind.warning);

  static void _show(String message, _Kind kind) {
    final ctx = Get.context;
    final isDark = ctx == null
        ? false
        : Theme.of(ctx).brightness == Brightness.dark;
    final theme = isDark ? AppTheme.dark() : AppTheme.light();
    final color = switch (kind) {
      _Kind.success => const Color(0xFF3BA57A),
      _Kind.error => const Color(0xFFCA5A5A),
      _Kind.info => const Color(0xFF5C87B2),
      _Kind.warning => const Color(0xFFD9A34B),
    };
    final icon = switch (kind) {
      _Kind.success => Icons.check_circle_rounded,
      _Kind.error => Icons.error_rounded,
      _Kind.info => Icons.info_rounded,
      _Kind.warning => Icons.warning_amber_rounded,
    };

    Get.snackbar(
      '',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: theme.snackBarTheme.backgroundColor,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      icon: Icon(icon, color: color),
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}
