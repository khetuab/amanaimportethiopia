import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

enum AppButtonVariant { primary, secondary, ghost, danger }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expand = true,
    this.small = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final Widget? icon;
  final bool expand;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    late final Color bg;
    late final Color fg;
    BorderSide? side;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = scheme.primary;
        fg = isDark ? const Color(0xFF1E1618) : Colors.white;
        break;
      case AppButtonVariant.secondary:
        bg = Colors.transparent;
        fg = scheme.primary;
        side = BorderSide(color: scheme.primary);
        break;
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = scheme.onSurface;
        break;
      case AppButtonVariant.danger:
        bg = scheme.error;
        fg = Colors.white;
        break;
    }

    final height = small ? 44.0 : AppSizes.buttonHeight;
    final radius = BorderRadius.circular(AppSizes.radiusMd);

    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontWeight: FontWeight.w600,
                  fontSize: small ? 13 : 15,
                ),
              ),
            ],
          );

    return SizedBox(
      height: height,
      width: expand ? double.infinity : null,
      child: variant == AppButtonVariant.ghost
          ? TextButton(
              onPressed: loading ? null : onPressed,
              style: TextButton.styleFrom(
                foregroundColor: fg,
                shape: RoundedRectangleBorder(borderRadius: radius),
              ),
              child: child,
            )
          : ElevatedButton(
              onPressed: loading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: bg,
                foregroundColor: fg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: radius,
                  side: side ?? BorderSide.none,
                ),
              ),
              child: child,
            ),
    );
  }
}
