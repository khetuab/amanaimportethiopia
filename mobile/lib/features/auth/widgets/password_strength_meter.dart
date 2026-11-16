import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PasswordStrengthMeter extends StatelessWidget {
  const PasswordStrengthMeter({super.key, required this.controller});
  final TextEditingController controller;

  static int _score(String p) {
    if (p.isEmpty) return 0;
    var s = 0;
    if (p.length >= 8) s++;
    if (RegExp(r'[a-z]').hasMatch(p) && RegExp(r'[A-Z]').hasMatch(p)) s++;
    if (RegExp(r'\d').hasMatch(p)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(p)) s++;
    if (p.length < 8) s = s.clamp(0, 1);
    return s;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final labels = [
      'auth.passwordStrength.tooShort'.tr,
      'auth.passwordStrength.weak'.tr,
      'auth.passwordStrength.fair'.tr,
      'auth.passwordStrength.good'.tr,
      'auth.passwordStrength.strong'.tr,
    ];

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, v, _) {
        final score = _score(v.text);
        return AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: v.text.isEmpty
              ? const SizedBox(width: double.infinity)
              : Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(4, (i) {
                    final on = i < score;
                    return Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                        height: 4,
                        margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: on
                              ? scheme.primary
                              .withValues(alpha: .45 + .15 * score)
                              : scheme.onSurface.withValues(alpha: .1),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 6),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    labels[score],
                    key: ValueKey(score),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface.withValues(alpha: .75),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}