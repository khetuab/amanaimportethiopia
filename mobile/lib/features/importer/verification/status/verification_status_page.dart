import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import 'verification_status_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

class VerificationStatusPage extends GetView<VerificationStatusController> {
  const VerificationStatusPage({super.key});

  static IconData _icon(String s) => switch (s) {
    'approved' => Icons.verified_rounded,
    'pending' => Icons.hourglass_top_rounded,
    'rejected' => Icons.cancel_rounded,
    'suspended' => Icons.block_rounded,
    _ => Icons.shield_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final p = controller.profile.value;
      final loading = controller.loading.value;
      final error = controller.error.value;
      final status = p?.verificationStatus ?? '';
      final ready = !loading && error == null;

      final actions = <Widget>[
        if (ready && p == null)
          PremiumButton(
            label: 'importer.verification.submit'.tr,
            icon: Icons.verified_outlined,
            onPressed: controller.resubmit,
          ),
        if (ready && status == 'rejected')
          PremiumButton(
            label: 'importer.verification.fixResubmit'.tr,
            icon: Icons.refresh_rounded,
            onPressed: controller.resubmit,
          ),
        if (ready && status == 'approved') ...[
          PremiumButton(
            label: 'importer.verification.goToDashboard'.tr,
            icon: Icons.space_dashboard_rounded,
            onPressed: controller.backToDashboard,
          ),
          PremiumButton(
            label: 'importer.verification.editBusinessProfile'.tr,
            style: PremiumButtonStyle.outlined,
            onPressed: controller.resubmit,
          ),
        ],
      ];

      return ProPage(
        showBack: true,
        eyebrow: 'importer.verification.eyebrow'.tr,
        title: 'importer.verification.statusTitle'.tr,
        subtitle: 'importer.verification.statusSubtitle'.tr,
        art: HeroArt(
          icon: _icon(status),
          satellites: const [
            Icons.description_outlined,
            Icons.badge_outlined,
            Icons.verified_user_outlined,
          ],
        ),
        onRefresh: controller.load,
        bottomBar: actions.isEmpty ? null : ProBottomBar(children: actions),
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 2, itemHeight: 150)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : p == null
              ? ProEmptyState(
            key: const ValueKey('empty'),
            title: 'importer.verification.notSubmittedTitle'.tr,
            description: 'importer.verification.notSubmittedBody'.tr,
            icon: Icons.shield_outlined,
            satellites: const [
              Icons.description_outlined,
              Icons.badge_outlined,
              Icons.verified_outlined,
            ],
          )
              : _content(context, p, status),
        ),
      );
    });
  }

  Widget _content(BuildContext context, dynamic p, String status) {
    final theme = Theme.of(context);
    final tone = switch (status) {
      'approved' => AppBadgeTone.green,
      'pending' => AppBadgeTone.amber,
      'rejected' || 'suspended' => AppBadgeTone.red,
      _ => AppBadgeTone.slate,
    };

    Widget? message;
    if (status == 'pending') {
      message = ProCallout(
        icon: Icons.hourglass_top_rounded,
        child: Text(
          'importer.verification.pendingNote'.tr,
        ),
      );
    } else if (status == 'suspended') {
      message = ProCallout(
        icon: Icons.block_rounded,
        color: const Color(0xFFDC2626),
        child: Text(
          'importer.verification.suspendedNote'.tr,
        ),
      );
    } else if (status == 'rejected') {
      message = ProCallout(
        icon: Icons.error_outline_rounded,
        color: const Color(0xFFDC2626),
        child: Text(
          'importer.verification.rejectedNote'.tr,
        ),
      );
    } else if (status == 'approved') {
      message = ProCallout(
        icon: Icons.verified_rounded,
        color: const Color(0xFF059669),
        child: Text('importer.verification.approvedNote'.tr),
      );
    }

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
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
                  ProPill(label: _statusLabel(status), tone: tone),
                ],
              ),
              const SizedBox(height: 20),
              ProVerifyStepper(status: status),
            ],
          ),
        ),
        if (p.verificationNotes != null && p.verificationNotes!.isNotEmpty)
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('importer.verification.reviewerNotes'.tr,
                    icon: Icons.sticky_note_2_outlined),
                const SizedBox(height: 10),
                Text(
                  p.verificationNotes!,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        if (message != null) message,
      ],
    );
  }
}