import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../constants/auth_palette.dart';
// Adjust this path if your auth feature folder lives elsewhere.
import '../../../features/auth/widgets/premium_button.dart';

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  /// Shows the dialog and runs [onConfirmed] only if the user confirms.
  static Future<void> confirm(VoidCallback onConfirmed) async {
    HapticFeedback.lightImpact();
    final confirmed = await Get.dialog<bool>(
      const LogoutDialog(),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: .45),
    );
    if (confirmed == true) onConfirmed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: theme.dividerColor.withValues(alpha: .8)),
          boxShadow: [
            BoxShadow(
              color: AuthPalette.emeraldDeep.withValues(alpha: .25),
              blurRadius: 32,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: .08),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AuthPalette.emeraldMid,
                      AuthPalette.emerald,
                      AuthPalette.emeraldDeep,
                    ],
                  ),
                ),
                child: const Icon(Icons.logout_rounded,
                    color: Colors.white, size: 26),
              ),
            )
                .animate()
                .scale(
              begin: const Offset(.7, .7),
              duration: 350.ms,
              curve: Curves.easeOutBack,
            )
                .fadeIn(duration: 250.ms),
            const SizedBox(height: 20),
            Text(
              'core.widgets.logout.title'.tr,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'core.widgets.logout.body'.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: scheme.onSurface.withValues(alpha: .65),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () => Get.back(result: false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: scheme.onSurface,
                        side: BorderSide(
                            color: theme.dividerColor.withValues(alpha: .9)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        textStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      child: Text('common.cancel'.tr),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PremiumButton(
                    label: 'auth.signOut'.tr,
                    icon: Icons.logout_rounded,
                    onPressed: () {
                      HapticFeedback.mediumImpact();
                      Get.back(result: true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ).animate().fadeIn(duration: 200.ms).slideY(
          begin: .06,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        ),
      ),
    );
  }
}