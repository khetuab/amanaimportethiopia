import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/auth_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/pro/logout_dialog.dart';
import '../../../core/widgets/pro/notification_bell.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../../data/models/importer_profile_model.dart';
import '../../../routes/app_routes.dart';
import '../../auth/widgets/premium_button.dart';
import 'importer_dashboard_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

class ImporterDashboardPage extends GetView<ImporterDashboardController> {
  const ImporterDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProPage(
      eyebrow: 'importer.dashboard.eyebrow'.tr,
      title: controller.userName,
      subtitle: 'importer.dashboard.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.space_dashboard_rounded,
        satellites: [
          Icons.inventory_2_outlined,
          Icons.public_rounded,
          Icons.price_check_rounded,
        ],
      ),
      heroExtra: Obx(() {
        if (controller.loading.value) return const SizedBox.shrink();
        final p = controller.profile.value;
        return HeroPill(
          label: p == null
              ? 'importer.dashboard.verificationNeeded'.tr
              : _statusLabel(p.verificationStatus),
          icon: p == null
              ? Icons.warning_amber_rounded
              : Icons.verified_user_outlined,
        );
      }),
      actions: [
        const NotificationBell(),
        const SizedBox(width: 8),
        ProIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'importer.actions.signOut'.tr,
          onTap: () => LogoutDialog.confirm(controller.logout),
        ),
      ],
      onRefresh: controller.load,
      body: Obx(() => ProStateSwitcher(child: _content(context))),
    );
  }

  Widget _content(BuildContext context) {
    if (controller.loading.value) {
      return const Column(
        key: ValueKey('loading'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProSkeleton(height: 220, radius: 28),
          SizedBox(height: 24),
          ProSkeletonList(count: 3, itemHeight: 76),
        ],
      );
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }

    final profile = controller.profile.value;
    final theme = Theme.of(context);

    return ProStagger(
      key: const ValueKey('data'),
      gap: 26,
      children: [
        if (profile == null)
          _VerifyCta(
            onSubmit: () => Get.toNamed(AppRoutes.submitVerification)
                ?.then((_) => controller.load()),
          )
        else
          _ProfileSummary(
            profile: profile,
            onEdit: () => Get.toNamed(AppRoutes.submitVerification)
                ?.then((_) => controller.load()),
            onViewStatus: () => Get.toNamed(AppRoutes.verificationStatus)
                ?.then((_) => controller.load()),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProSectionTitle('importer.dashboard.quickActions'.tr,
                icon: Icons.bolt_rounded),
            const SizedBox(height: 14),
            _QuickActions(enabled: profile?.isApproved ?? false),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProSectionTitle('importer.dashboard.account'.tr,
                icon: Icons.manage_accounts_outlined),
            const SizedBox(height: 14),
            ProCard(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              child: Column(
                children: [
                  _AccountRow(
                    icon: Icons.badge_outlined,
                    label: 'importer.profile.title'.tr,
                    onTap: () => Get.toNamed(AppRoutes.businessProfile)
                        ?.then((_) => controller.load()),
                  ),
                  Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: .5)),
                  _AccountRow(
                    icon: Icons.forum_outlined,
                    label: 'nav.messages'.tr,
                    onTap: () => Get.toNamed(AppRoutes.conversations),
                  ),
                  Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: .5)),
                  _AccountRow(
                    icon: Icons.settings_outlined,
                    label: 'importer.dashboard.settings'.tr,
                    onTap: () => Get.toNamed(AppRoutes.settings),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _VerifyCta extends StatelessWidget {
  const _VerifyCta({required this.onSubmit});
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeroPill(
                label: 'importer.dashboard.actionNeeded'.tr,
                icon: Icons.shield_outlined),
            const SizedBox(height: 14),
            Text(
              'importer.dashboard.verificationRequired'.tr,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'importer.dashboard.verificationBody'.tr,
              style: TextStyle(
                color: Colors.white.withValues(alpha: .85),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            PremiumButton(
              label: 'importer.dashboard.startVerification'.tr,
              icon: Icons.verified_outlined,
              style: PremiumButtonStyle.light,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  const _ProfileSummary({
    required this.profile,
    required this.onEdit,
    required this.onViewStatus,
  });

  final ImporterProfileModel profile;
  final VoidCallback onEdit;
  final VoidCallback onViewStatus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final status = profile.verificationStatus;
    final tone = switch (status) {
      'approved' => AppBadgeTone.green,
      'pending' => AppBadgeTone.amber,
      'rejected' || 'suspended' => AppBadgeTone.red,
      _ => AppBadgeTone.slate,
    };

    Widget stat(String label, double v, String Function(double) f) => Expanded(
      child: Column(
        children: [
          ProCountUp(
            value: v,
            format: f,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodySmall),
        ],
      ),
    );

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  profile.businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              ProPill(label: _statusLabel(status), tone: tone),
            ],
          ),
          const SizedBox(height: 18),
          ProVerifyStepper(status: status),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .07),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                stat('importer.profile.rating'.tr, asDouble(profile.ratingAverage),
                        (v) => '${v.toStringAsFixed(1)} ★'),
                stat('importer.profile.reviews'.tr, asDouble(profile.ratingCount),
                        (v) => v.toStringAsFixed(0)),
                stat('importer.profile.completed'.tr, asDouble(profile.completedOrdersCount),
                        (v) => v.toStringAsFixed(0)),
              ],
            ),
          ),
          if (profile.serviceAreas.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in profile.serviceAreas)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: .06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.place_outlined,
                            size: 13, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(s.toString(),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (profile.verificationNotes != null &&
              profile.verificationNotes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            ProCallout(
              icon: Icons.sticky_note_2_outlined,
              child: Text(profile.verificationNotes!,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.5)),
            ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'importer.dashboard.statusButton'.tr,
                  style: PremiumButtonStyle.outlined,
                  onPressed: onViewStatus,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: PremiumButton(
                  label: 'importer.dashboard.editButton'.tr,
                  icon: Icons.edit_outlined,
                  onPressed: onEdit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.enabled});
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final items = <({IconData icon, String label, String sub, String route})>[
      (
      icon: Icons.search_rounded,
      label: 'importer.browse.title'.tr,
      sub: 'importer.dashboard.qaBrowseSub'.tr,
      route: AppRoutes.browseRequests,
      ),
      (
      icon: Icons.price_check_rounded,
      label: 'importer.quotations.title'.tr,
      sub: 'importer.dashboard.qaQuotesSub'.tr,
      route: AppRoutes.myQuotations,
      ),
      (
      icon: Icons.receipt_long_rounded,
      label: 'importer.orders.title'.tr,
      sub: 'importer.dashboard.qaOrdersSub'.tr,
      route: AppRoutes.importerOrders,
      ),
    ];

    return Column(
      children: [
        for (final e in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Builder(builder: (_) {
              final locked = !enabled && e.route != AppRoutes.importerOrders;
              return ProCard(
                padding: const EdgeInsets.all(14),
                onTap: () {
                  if (locked) {
                    Get.snackbar(
                      'importer.dashboard.verificationRequired'.tr,
                      'importer.dashboard.lockedBody'
                          .trParams({'action': e.label.toLowerCase()}),
                      duration: const Duration(seconds: 3),
                    );
                    return;
                  }
                  Get.toNamed(e.route);
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: locked
                            ? null
                            : LinearGradient(colors: [
                          scheme.primary,
                          Color.lerp(scheme.primary, Colors.black, .2)!,
                        ]),
                        color: locked
                            ? scheme.onSurface.withValues(alpha: .08)
                            : null,
                      ),
                      child: Icon(
                        locked ? Icons.lock_outline_rounded : e.icon,
                        color: locked
                            ? scheme.onSurface.withValues(alpha: .4)
                            : scheme.onPrimary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.label,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: locked
                                  ? scheme.onSurface.withValues(alpha: .5)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(e.sub, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    if (locked)
                      ProPill(
                          label: 'importer.dashboard.locked'.tr,
                          tone: AppBadgeTone.amber)
                    else
                      Icon(Icons.chevron_right_rounded,
                          color: scheme.onSurface.withValues(alpha: .4)),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }
}

class _AccountRow extends StatelessWidget {
  const _AccountRow({
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
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: scheme.primary.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 19, color: scheme.primary),
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