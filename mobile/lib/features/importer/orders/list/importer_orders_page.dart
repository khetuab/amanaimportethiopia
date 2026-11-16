import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../buyer/requests/widgets/order_image.dart';
import '../../../buyer/requests/widgets/request_image.dart';
import 'importer_orders_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

class ImporterOrdersPage extends GetView<ImporterOrdersController> {
  const ImporterOrdersPage({super.key});

  static IconData _icon(String s) => switch (s) {
    'completed' => Icons.verified_rounded,
    'delivered' => Icons.inventory_2_rounded,
    'cancelled' || 'refunded' => Icons.cancel_outlined,
    'disputed' || 'refund_pending' => Icons.gavel_rounded,
    'awaiting_payment_confirmation' => Icons.hourglass_top_rounded,
    _ => Icons.local_shipping_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return ProPage(
      eyebrow: 'importer.orders.eyebrow'.tr,
      title: 'importer.orders.title'.tr,
      subtitle: 'importer.orders.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.receipt_long_rounded,
        satellites: [
          Icons.local_shipping_outlined,
          Icons.flight_takeoff_rounded,
          Icons.verified_outlined,
        ],
      ),
      onRefresh: controller.load,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final selected = controller.filter.value;
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: ImporterOrdersController.filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = ImporterOrdersController.filters[i];
                  return ProSelectChip(
                    label: f == 'all' ? 'common.all'.tr : _statusLabel(f),
                    selected: selected == f,
                    onTap: () => controller.setFilter(f),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 20),
          Obx(() => ProStateSwitcher(child: _body(context))),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (controller.loading.value) {
      return const ProSkeletonList(key: ValueKey('loading'), itemHeight: 108);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }
    if (controller.items.isEmpty) {
      return ProEmptyState(
        key: const ValueKey('empty'),
        title: 'importer.orders.emptyTitle'.tr,
        description: 'importer.orders.emptyBody'.tr,
        icon: Icons.receipt_long_outlined,
        satellites: const [
          Icons.handshake_outlined,
          Icons.local_shipping_outlined,
          Icons.payments_outlined,
        ],
      );
    }

    final theme = Theme.of(context);
    return ProStagger(
      key: ValueKey('orders-${controller.filter.value}'),
      gap: 12,
      children: [
        for (final o in controller.items)
          Builder(builder: (_) {
            final tone = switch (o.status) {
              'completed' || 'delivered' => AppBadgeTone.green,
              'cancelled' || 'refunded' => AppBadgeTone.slate,
              'disputed' || 'refund_pending' => AppBadgeTone.red,
              'awaiting_payment_confirmation' => AppBadgeTone.amber,
              _ => AppBadgeTone.blue,
            };
            return ProCard(
              onTap: () => controller.open(o),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  OrderThumb(
                    order: o,
                    icon: _icon(o.status),
                    size: 56,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          o.snapshot.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 3),
                        Text(o.referenceNumber,
                            style: theme.textTheme.bodySmall),
                        const SizedBox(height: 8),
                        ProPill(
                            label: _statusLabel(o.status), tone: tone),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.etb(o.totalPriceETB),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Icon(Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: .4)),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}