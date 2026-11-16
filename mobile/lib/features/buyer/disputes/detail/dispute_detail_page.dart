import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import 'dispute_detail_controller.dart';

class DisputeDetailPage extends GetView<DisputeDetailController> {
  const DisputeDetailPage({super.key});

  static AppBadgeTone _tone(String status) {
    final s = status.toLowerCase();
    if (s.contains('resolved')) return AppBadgeTone.green;
    if (s.contains('reject')) return AppBadgeTone.red;
    if (s.contains('closed')) return AppBadgeTone.slate;
    return AppBadgeTone.amber;
  }

  /// Display label for a dispute reason value (enum -> localized text).
  static String _reasonLabel(String r) => switch (r) {
    'non_delivery' => 'buyer.disputes.reason.nonDelivery'.tr,
    'damaged_goods' => 'buyer.disputes.reason.damagedGoods'.tr,
    'incorrect_product' => 'buyer.disputes.reason.incorrectProduct'.tr,
    'spec_mismatch' => 'buyer.disputes.reason.specMismatch'.tr,
    'excessive_delay' => 'buyer.disputes.reason.excessiveDelay'.tr,
    'unapproved_charges' => 'buyer.disputes.reason.unapprovedCharges'.tr,
    'cancellation' => 'buyer.disputes.reason.cancellation'.tr,
    'payment_evidence' => 'buyer.disputes.reason.paymentEvidence'.tr,
    'other' => 'buyer.disputes.reason.other'.tr,
    _ => Formatters.humanize(r),
  };

  /// Display label for a dispute status value (enum -> localized text).
  static String _statusLabel(String s) => switch (s) {
    'open' => 'buyer.disputes.status.open'.tr,
    'under_review' => 'buyer.disputes.status.underReview'.tr,
    'resolved' => 'buyer.disputes.status.resolved'.tr,
    'rejected' => 'buyer.disputes.status.rejected'.tr,
    'closed' => 'buyer.disputes.status.closed'.tr,
    _ => Formatters.humanize(s),
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.loading.value;
      final error = controller.error.value;
      final items = controller.disputes;

      return ProPage(
        showBack: true,
        eyebrow: 'buyer.disputes.eyebrow'.tr,
        title: 'buyer.disputes.detail.title'.tr,
        subtitle: 'buyer.disputes.detail.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.shield_rounded,
          satellites: [
            Icons.gavel_rounded,
            Icons.support_agent_rounded,
            Icons.verified_outlined,
          ],
        ),
        onRefresh: controller.load,
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
              : items.isEmpty
              ? ProEmptyState(
            key: const ValueKey('empty'),
            title: 'buyer.disputes.detail.emptyTitle'.tr,
            description: 'buyer.disputes.detail.emptyDescription'.tr,
            icon: Icons.verified_user_outlined,
            satellites: [
              Icons.check_circle_outline_rounded,
              Icons.shield_outlined,
              Icons.thumb_up_alt_outlined,
            ],
          )
              : _list(context, items),
        ),
      );
    });
  }

  Widget _list(BuildContext context, List items) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProStagger(
      key: const ValueKey('data'),
      gap: 14,
      children: [
        for (final d in items)
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.gavel_rounded,
                          size: 20, color: scheme.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _reasonLabel(d.reason),
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    ProPill(
                      label: _statusLabel(d.status),
                      tone: _tone(d.status),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: .04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    d.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 14,
                        color: scheme.onSurface.withValues(alpha: .5)),
                    const SizedBox(width: 6),
                    Text(Formatters.relative(d.createdAt),
                        style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }
}