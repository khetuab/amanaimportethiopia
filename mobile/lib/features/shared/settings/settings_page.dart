import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../auth/widgets/premium_button.dart';
import '../../auth/widgets/premium_field.dart';
import 'settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ProPage(
      showBack: true,
      eyebrow: 'settings.eyebrow'.tr,
      title: 'settings.title'.tr,
      subtitle: 'settings.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.tune_rounded,
        satellites: [
          Icons.dark_mode_outlined,
          Icons.translate_rounded,
          Icons.lock_outline_rounded,
        ],
      ),
      body: ProStagger(
        gap: 18,
        children: [
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('settings.appearance'.tr,
                    icon: Icons.palette_outlined),
                const SizedBox(height: 14),
                Obx(
                      () => _ThemeSelector(
                    mode: controller.mode,
                    onChanged: controller.setTheme,
                  ),
                ),
              ],
            ),
          ),
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('settings.language'.tr,
                    icon: Icons.translate_rounded),
                const SizedBox(height: 14),
                Obx(() {
                  final language = controller.languageCode.value;
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ProSelectChip(
                        label: 'English',
                        selected: language == 'en',
                        onTap: () => controller.setLanguage('en'),
                      ),
                      ProSelectChip(
                        label: 'አማርኛ',
                        selected: language == 'am',
                        onTap: () => controller.setLanguage('am'),
                      ),
                      ProSelectChip(
                        label: 'العربية',
                        selected: language == 'ar',
                        onTap: () => controller.setLanguage('ar'),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProSectionTitle('settings.security'.tr,
                    icon: Icons.lock_outline_rounded),
                const SizedBox(height: 16),
                _PasswordSection(controller: controller),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: scheme.error.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: scheme.error.withValues(alpha: .35)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: scheme.error),
                    const SizedBox(width: 10),
                    Text(
                      'settings.dangerZone'.tr,
                      style: TextStyle(
                        color: scheme.error,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'settings.dangerZoneBody'.tr,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 14),
                _DangerButton(
                  label: 'settings.deleteAccount'.tr,
                  onTap: controller.deleteAccount,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeSelector extends StatelessWidget {
  const _ThemeSelector({required this.mode, required this.onChanged});
  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = [
      (ThemeMode.system, 'settings.theme.system'.tr, Icons.brightness_auto_rounded),
      (ThemeMode.light, 'settings.theme.light'.tr, Icons.light_mode_rounded),
      (ThemeMode.dark, 'settings.theme.dark'.tr, Icons.dark_mode_rounded),
    ];
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                onChanged(items[i].$1);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: mode == items[i].$1
                      ? scheme.primary
                      : scheme.onSurface.withValues(alpha: .05),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    if (mode == items[i].$1)
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: .35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                  ],
                ),
                child: Column(
                  children: [
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (c, a) => ScaleTransition(
                        scale: CurvedAnimation(
                            parent: a, curve: Curves.easeOutBack),
                        child: c,
                      ),
                      child: Icon(
                        items[i].$3,
                        key: ValueKey(mode == items[i].$1),
                        size: 26,
                        color: mode == items[i].$1
                            ? scheme.onPrimary
                            : scheme.onSurface.withValues(alpha: .6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      items[i].$2,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: mode == items[i].$1
                            ? scheme.onPrimary
                            : scheme.onSurface.withValues(alpha: .8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _PasswordSection extends StatefulWidget {
  const _PasswordSection({required this.controller});
  final SettingsController controller;

  @override
  State<_PasswordSection> createState() => _PasswordSectionState();
}

class _PasswordSectionState extends State<_PasswordSection> {
  bool _old = true;
  bool _new = true;
  bool _confirm = true;

  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PremiumField(
          controller: c.oldPwdCtrl,
          label: 'settings.currentPassword'.tr,
          icon: Icons.lock_outline_rounded,
          obscureText: _old,
          textInputAction: TextInputAction.next,
          suffix: PasswordToggle(
              obscured: _old, onTap: () => setState(() => _old = !_old)),
        ),
        const SizedBox(height: 14),
        PremiumField(
          controller: c.newPwdCtrl,
          label: 'settings.newPassword'.tr,
          icon: Icons.key_rounded,
          obscureText: _new,
          textInputAction: TextInputAction.next,
          suffix: PasswordToggle(
              obscured: _new, onTap: () => setState(() => _new = !_new)),
        ),
        PasswordStrengthMeter(controller: c.newPwdCtrl),
        const SizedBox(height: 14),
        PremiumField(
          controller: c.confirmPwdCtrl,
          label: 'settings.confirmNewPassword'.tr,
          icon: Icons.key_rounded,
          obscureText: _confirm,
          textInputAction: TextInputAction.done,
          suffix: PasswordToggle(
              obscured: _confirm,
              onTap: () => setState(() => _confirm = !_confirm)),
        ),
        const SizedBox(height: 18),
        Obx(
              () => PremiumButton(
            label: 'settings.changePassword'.tr,
            icon: Icons.check_rounded,
            loading: c.changingPwd.value,
            onPressed: c.changePassword,
          ),
        ),
      ],
    );
  }
}

class _DangerButton extends StatefulWidget {
  const _DangerButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<_DangerButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.mediumImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.error.withValues(alpha: _down ? .18 : .08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.error, width: 1.4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline_rounded, color: scheme.error),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: scheme.error,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}