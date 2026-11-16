import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../buyer/requests/widgets/request_image.dart';
import 'importer_order_detail_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

/// Maps a raw product condition value to its localized display label.
String _condLabel(String c) {
  const keys = {
    'new': 'importer.condition.new',
    'used_like_new': 'importer.condition.usedLikeNew',
    'used_good': 'importer.condition.usedGood',
    'used_fair': 'importer.condition.usedFair',
    'refurbished': 'importer.condition.refurbished',
  };
  final k = keys[c.toLowerCase()];
  return k == null ? Formatters.humanize(c) : k.tr;
}

class ImporterOrderDetailPage extends GetView<ImporterOrderDetailController> {
  const ImporterOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final o = controller.order.value;
      final loading = controller.loading.value;
      final error = controller.error.value;

      final canAdvance = o != null &&
          _StageCard.stages.any((s) => s.$1 == o.status);

      return ProPage(
        showBack: true,
        eyebrow: o?.referenceNumber ?? 'importer.order.defaultTitle'.tr,
        title: o?.snapshot.title ?? 'importer.order.detailsTitle'.tr,
        heroExtra: o == null
            ? null
            : HeroPill(
          label: _statusLabel(o.status),
          icon: Icons.radio_button_checked_rounded,
        ),
        art: const HeroArt(
          icon: Icons.local_shipping_rounded,
          satellites: [
            Icons.flight_takeoff_rounded,
            Icons.inventory_2_outlined,
            Icons.verified_outlined,
          ],
        ),
        onRefresh: controller.load,
        bottomBar: (o == null || loading || error != null)
            ? null
            : ProBottomBar(children: [
          if (canAdvance)
            PremiumButton(
              label: 'importer.order.updateStatus'.tr,
              icon: Icons.published_with_changes_rounded,
              onPressed: controller.updateStatus,
            ),
          PremiumButton(
            label: 'importer.order.shipmentEvents'.tr,
            style: PremiumButtonStyle.outlined,
            onPressed: controller.viewShipment,
          ),
        ]),
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 4, itemHeight: 110)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : o == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : _content(context, o),
        ),
      );
    });
  }

  Widget _content(BuildContext context, dynamic o) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final history = o.statusHistory as List;
    final urls = controller.imageUrls.toList();

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        if (urls.isNotEmpty) RequestGallery(urls: urls),
        if (_StageCard.indexOf(o.status) >= 0) _StageCard(status: o.status),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('importer.order.detailsTitle'.tr,
                  icon: Icons.inventory_2_outlined),
              const SizedBox(height: 6),
              ProInfoList(rows: [
                ProInfoRow(
                  label: 'importer.order.quantity'.tr,
                  value:
                  '${o.snapshot.quantity} ${o.snapshot.unitOfMeasurement}',
                ),
                ProInfoRow(
                    label: 'importer.order.deliveryCity'.tr,
                    value: o.snapshot.deliveryCity),
                if (o.snapshot.deliveryAddress != null)
                  ProInfoRow(
                      label: 'importer.order.address'.tr,
                      value: o.snapshot.deliveryAddress!),
                ProInfoRow(
                  label: 'importer.order.condition'.tr,
                  value: _condLabel(o.snapshot.productCondition),
                ),
                if (o.snapshot.warrantyOffered != null)
                  ProInfoRow(
                      label: 'importer.quotation.warranty'.tr,
                      value: o.snapshot.warrantyOffered!),
              ]),
            ],
          ),
        ),
        if (o.counterparty != null)
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('importer.order.buyerContact'.tr,
                    icon: Icons.support_agent_rounded),
                const SizedBox(height: 6),
                ProInfoList(rows: [
                  ProInfoRow(
                      label: 'importer.order.name'.tr,
                      value: o.counterparty!.fullName ?? '—'),
                  ProInfoRow(
                      label: 'auth.phone'.tr,
                      icon: Icons.phone_outlined,
                      value: o.counterparty!.phone ?? '—'),
                  ProInfoRow(
                      label: 'auth.email'.tr,
                      icon: Icons.mail_outline_rounded,
                      value: o.counterparty!.email ?? '—'),
                ]),
              ],
            ),
          ),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('importer.order.value'.tr,
                  icon: Icons.receipt_outlined),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text('importer.order.total'.tr,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const Spacer(),
                    ProCountUp(
                      value: asDouble(o.totalPriceETB),
                      format: (v) => Formatters.etb(v),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scheme.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              ProInfoRow(
                label: 'importer.order.platformFee'.tr,
                value:
                '${Formatters.etb(o.platformFeeETB)} (${o.platformFeePayer})',
              ),
            ],
          ),
        ),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('importer.order.timeline'.tr,
                  icon: Icons.timeline_rounded),
              const SizedBox(height: 16),
              for (var i = 0; i < history.length; i++)
                ProTimelineTile(
                  label: _statusLabel(history[i].to),
                  time: Formatters.relative(history[i].at),
                  last: i == history.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({required this.status});
  final String status;

  static const stages = [
    ('payment_condition_satisfied', 'importer.order.stage.paymentCleared'),
    ('processing', 'status.processing'),
    ('import_shipment_in_progress', 'importer.order.stage.importShipment'),
    ('customs_clearance', 'importer.order.stage.customsClearance'),
    ('in_transit', 'status.in_transit'),
    ('ready_for_delivery', 'importer.order.stage.readyForDelivery'),
    ('delivered', 'status.delivered'),
  ];

  static int indexOf(String s) {
    if (s == 'completed') return stages.length - 1;
    return stages.indexWhere((e) => e.$1 == s);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final idx = indexOf(status);
    final done = idx >= stages.length - 1;
    final frac = (idx + 1) / stages.length;

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProSectionTitle(
            'importer.order.fulfilmentProgress'.tr,
            icon: Icons.route_rounded,
            trailing: Text(
              '${idx + 1}/${stages.length}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: frac),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => LinearProgressIndicator(
                value: v,
                minHeight: 10,
                backgroundColor: scheme.primary.withValues(alpha: .12),
                valueColor: AlwaysStoppedAnimation(scheme.primary),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                done ? Icons.check_circle_rounded : Icons.my_location_rounded,
                size: 18,
                color: scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  stages[idx].$2.tr,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          if (!done) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Text(
                  'importer.order.nextStage'.trParams(
                      {'stage': stages[idx + 1].$2.tr}),
                  style: theme.textTheme.bodySmall),
            ),
          ],
        ],
      ),
    );
  }
}