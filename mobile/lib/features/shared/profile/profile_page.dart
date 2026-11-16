import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/auth_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pro/logout_dialog.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final u = controller.user.value;
      return ProPage(
        eyebrow: 'nav.profile'.tr,
        title: u?.fullName ?? 'profile.fallbackTitle'.tr,
        subtitle: u?.email,
        art: _ProfileArt(name: u?.fullName ?? ''),
        onRefresh: controller.load,
        body: ProStateSwitcher(child: _content(context)),
      );
    });
  }

  Widget _content(BuildContext context) {
    if (controller.loading.value) {
      return const ProSkeletonList(
          key: ValueKey('loading'), count: 3, itemHeight: 110);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }
    final u = controller.user.value;
    if (u == null) return const SizedBox.shrink(key: ValueKey('none'));

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('profile.account'.tr, icon: Icons.person_outline),
              const SizedBox(height: 6),
              ProInfoList(rows: [
                ProInfoRow(
                    label: 'auth.phone'.tr,
                    icon: Icons.phone_outlined,
                    value: u.phone),
                ProInfoRow(
                    label: 'profile.role'.tr,
                    icon: Icons.badge_outlined,
                    value: Formatters.humanize(u.role)),
                ProInfoRow(
                  label: 'profile.language'.tr,
                  icon: Icons.translate_rounded,
                  value: u.preferredLanguage.toUpperCase(),
                ),
              ]),
            ],
          ),
        ),
        ProCard(
          padding: const EdgeInsets.all(6),
          child: Column(
            children: [
              _MenuRow(
                icon: Icons.notifications_none_rounded,
                label: 'nav.notifications'.tr,
                onTap: controller.openNotifications,
              ),
              Divider(
                  height: 1, color: theme.dividerColor.withValues(alpha: .5)),
              _MenuRow(
                icon: Icons.forum_outlined,
                label: 'nav.messages'.tr,
                onTap: controller.openMessages,
              ),
              Divider(
                  height: 1, color: theme.dividerColor.withValues(alpha: .5)),
              _MenuRow(
                icon: Icons.settings_outlined,
                label: 'profile.settings'.tr,
                onTap: controller.openSettings,
              ),
            ],
          ),
        ),
        ProCard(
          onTap: () => LogoutDialog.confirm(controller.logout),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: scheme.error),
              const SizedBox(width: 10),
              Text(
                'profile.signOut'.tr,
                style: TextStyle(
                  color: scheme.error,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileArt extends StatelessWidget {
  const _ProfileArt({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();
    return SizedBox(
      width: 124,
      height: 124,
      child: ProLooper(
        duration: const Duration(seconds: 6),
        builder: (context, t) {
          final pulse = 1 + .06 * sinT(t, 1);
          return Stack(
            alignment: Alignment.center,
            children: [
              Transform.scale(
                scale: pulse,
                child: Container(
                  width: 112,
                  height: 112,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: .2)),
                  ),
                ),
              ),
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AuthPalette.mint, AuthPalette.emeraldMid],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AuthPalette.mint.withValues(alpha: .5),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: AuthPalette.emeraldDeep,
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, size: 20, color: scheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
            Icon(Icons.chevron_right_rounded,
                color: scheme.onSurface.withValues(alpha: .4)),
          ],
        ),
      ),
    );
  }
}