import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../requests/widgets/order_image.dart';
import '../../requests/widgets/request_image.dart';
import 'buyer_orders_controller.dart';

class BuyerOrdersPage extends GetView<BuyerOrdersController> {
  const BuyerOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => ProPage(
        eyebrow: 'buyer.orders.list.purchases'.tr,
        title: 'buyer.orders.list.title'.tr,
        subtitle: 'buyer.orders.list.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.receipt_long_rounded,
          satellites: [
            Icons.local_shipping_outlined,
            Icons.payments_outlined,
            Icons.verified_outlined,
          ],
        ),
        onRefresh: controller.load,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: controller.filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = controller.filters[i];
                  return ProSelectChip(
                    label: _label(f),
                    selected: controller.filter.value == f,
                    onTap: () => controller.setFilter(f),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ProStateSwitcher(child: _body(context)),
          ],
        ),
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
    if (controller.orders.isEmpty) {
      return ProEmptyState(
        key: const ValueKey('empty'),
        title: 'buyer.orders.list.emptyTitle'.tr,
        description: 'buyer.orders.list.emptyDescription'.tr,
        icon: Icons.receipt_long_outlined,
        satellites: [
          Icons.local_shipping_outlined,
          Icons.payments_outlined,
          Icons.verified_outlined,
        ],
      );
    }

    final theme = Theme.of(context);
    return ProStagger(
      key: ValueKey('orders-${controller.filter.value}'),
      gap: 12,
      children: [
        for (final o in controller.orders)
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
                    icon: _statusIcon(o.status),
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

  static IconData _statusIcon(String s) => switch (s) {
    'completed' => Icons.verified_rounded,
    'delivered' => Icons.inventory_2_rounded,
    'cancelled' || 'refunded' => Icons.cancel_outlined,
    'disputed' || 'refund_pending' => Icons.gavel_rounded,
    'awaiting_payment_confirmation' => Icons.hourglass_top_rounded,
    _ => Icons.local_shipping_outlined,
  };

  static String _label(String key) {
    if (key == 'all') return 'common.all'.tr;
    return _statusLabel(key);
  }

  /// Display label for an order status value (server enum -> localized text).
  static String _statusLabel(String s) => switch (s) {
    'awaiting_payment_confirmation' =>
      'status.awaitingPaymentConfirmation'.tr,
    'payment_condition_satisfied' =>
      'status.paymentConditionSatisfied'.tr,
    'processing' => 'status.processing'.tr,
    'import_shipment_in_progress' =>
      'status.importShipmentInProgress'.tr,
    'customs_clearance' => 'status.customsClearance'.tr,
    'in_transit' => 'status.inTransit'.tr,
    'ready_for_delivery' => 'status.readyForDelivery'.tr,
    'delivered' => 'status.delivered'.tr,
    'completed' => 'status.completed'.tr,
    'disputed' => 'status.disputed'.tr,
    'cancelled' => 'status.cancelled'.tr,
    'refunded' => 'status.refunded'.tr,
    'refund_pending' => 'status.refundPending'.tr,
    _ => Formatters.humanize(s),
  };
}