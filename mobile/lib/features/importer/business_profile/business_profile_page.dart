import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/pro/logout_dialog.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../auth/widgets/premium_button.dart';
import 'business_profile_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

/// Maps a raw business type value to its localized display label.
String _typeLabel(String t) {
  const keys = {
    'individual': 'importer.verification.type.individual',
    'company': 'importer.verification.type.company',
    'partnership': 'importer.verification.type.partnership',
  };
  final k = keys[t];
  return k == null ? Formatters.humanize(t) : k.tr;
}

class BusinessProfilePage extends GetView<BusinessProfileController> {
  const BusinessProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProPage(
      showBack: true,
      eyebrow: 'importer.profile.eyebrow'.tr,
      title: 'importer.profile.title'.tr,
      subtitle: 'importer.profile.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.storefront_rounded,
        satellites: [
          Icons.verified_outlined,
          Icons.star_rounded,
          Icons.public_rounded,
        ],
      ),
      actions: [
        ProIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'importer.actions.signOut'.tr,
          onTap: () => LogoutDialog.confirm(controller.logout),
        ),
      ],
      onRefresh: controller.load,
      bottomBar: Obx(() {
        if (controller.loading.value || controller.error.value != null) {
          return const SizedBox.shrink();
        }
        final p = controller.profile.value;
        if (p == null) {
          return ProBottomBar(children: [
            PremiumButton(
              label: 'importer.verification.submit'.tr,
              icon: Icons.verified_outlined,
              onPressed: controller.editProfile,
            ),
          ]);
        }
        return ProBottomBar(children: [
          PremiumButton(
            label: 'importer.profile.editProfile'.tr,
            icon: Icons.edit_outlined,
            onPressed: controller.editProfile,
          ),
          PremiumButton(
            label: 'importer.verification.statusTitle'.tr,
            style: PremiumButtonStyle.outlined,
            onPressed: controller.viewVerificationStatus,
          ),
        ]);
      }),
      body: Obx(() => ProStateSwitcher(child: _content(context))),
    );
  }

  Widget _content(BuildContext context) {
    if (controller.loading.value) {
      return const ProSkeletonList(
          key: ValueKey('loading'), count: 3, itemHeight: 150);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final p = controller.profile.value;
    final name = controller.userName;
    final initial = name.trim().isEmpty ? 'U' : name.trim()[0].toUpperCase();

    final account = ProCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(colors: [
                    scheme.primary,
                    Color.lerp(scheme.primary, Colors.black, .25)!,
                  ]),
                ),
                child: Text(
                  initial,
                  style: TextStyle(
                    color: scheme.onPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: theme.textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text('importer.profile.accountOwner'.tr,
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ProInfoList(rows: [
            ProInfoRow(
                label: 'auth.email'.tr,
                icon: Icons.mail_outline_rounded,
                value: controller.userEmail),
            ProInfoRow(
                label: 'auth.phone'.tr,
                icon: Icons.phone_outlined,
                value: controller.userPhone),
          ]),
        ],
      ),
    );

    if (p == null) {
      return ProStagger(
        key: const ValueKey('data'),
        gap: 20,
        children: [
          account,
          ProEmptyState(
            title: 'importer.profile.emptyTitle'.tr,
            description: 'importer.profile.emptyBody'.tr,
            icon: Icons.badge_outlined,
            satellites: const [
              Icons.verified_outlined,
              Icons.description_outlined,
              Icons.storefront_outlined,
            ],
          ),
        ],
      );
    }

    final tone = p.verificationStatus == 'approved'
        ? AppBadgeTone.green
        : AppBadgeTone.amber;

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        account,
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      p.businessName,
                      style: theme.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  ProPill(
                    label: _statusLabel(p.verificationStatus),
                    tone: tone,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ProVerifyStepper(status: p.verificationStatus),
            ],
          ),
        ),
        ProGrid2(children: [
          ProFactTile(
            icon: Icons.star_rounded,
            label: 'importer.profile.rating'.tr,
            child: ProCountUp(
              value: asDouble(p.ratingAverage),
              format: (v) => v.toStringAsFixed(1),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          ),
          ProFactTile(
            icon: Icons.rate_review_outlined,
            label: 'importer.profile.reviews'.tr,
            child: ProCountUp(
              value: asDouble(p.ratingCount),
              format: (v) => v.toStringAsFixed(0),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          ),
          ProFactTile(
            icon: Icons.task_alt_rounded,
            label: 'importer.profile.completedOrders'.tr,
            child: ProCountUp(
              value: asDouble(p.completedOrdersCount),
              format: (v) => v.toStringAsFixed(0),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: scheme.primary,
              ),
            ),
          ),
          ProFactTile(
            icon: Icons.business_center_outlined,
            label: 'importer.profile.businessType'.tr,
            value: _typeLabel(p.businessType),
          ),
        ]),
        if (p.tinNumber != null)
          ProCard(
            child: ProInfoRow(
              label: 'importer.profile.tin'.tr,
              icon: Icons.numbers_rounded,
              value: p.tinNumber!,
              bold: true,
            ),
          ),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('importer.verification.serviceAreas'.tr,
                  icon: Icons.map_outlined),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in p.serviceAreas)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_outlined,
                              size: 14, color: scheme.primary),
                          const SizedBox(width: 5),
                          Text(s.toString(),
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}