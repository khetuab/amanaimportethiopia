import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../../routes/app_routes.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../requests/widgets/request_image.dart';
import 'buyer_order_detail_controller.dart';

class BuyerOrderDetailPage extends GetView<BuyerOrderDetailController> {
  const BuyerOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final o = controller.order.value;
      final loading = controller.loading.value;
      final error = controller.error.value;

      final isAwaitingPayment = o?.status == 'awaiting_payment_confirmation';
      final isDelivered = o?.status == 'delivered';
      final isCompleted = o?.status == 'completed';
      final canDispute = o != null &&
          !['completed', 'cancelled', 'refunded'].contains(o.status);

      final actions = <Widget>[
        if (isAwaitingPayment) ...[
          PremiumButton(
            label: 'buyer.orders.detail.viewPaymentInstructions'.tr,
            icon: Icons.account_balance_wallet_outlined,
            onPressed: controller.goToPayment,
          ),
          PremiumButton(
            label: 'buyer.orders.payment.submitEvidence'.tr,
            style: PremiumButtonStyle.outlined,
            onPressed: controller.goToSubmitEvidence,
          ),
        ],
        if (isDelivered)
          PremiumButton(
            label: 'buyer.orders.detail.confirmReceipt'.tr,
            icon: Icons.task_alt_rounded,
            onPressed: controller.confirmReceipt,
          ),
        if (isCompleted)
          PremiumButton(
            label: 'buyer.reviews.title'.tr,
            icon: Icons.star_outline_rounded,
            style: PremiumButtonStyle.outlined,
            onPressed: controller.goToReview,
          ),
      ];

      return ProPage(
          showBack: true,
          onBack: () {
            if (Get.previousRoute.isNotEmpty) {
              Get.back();
            } else {
              Get.offAllNamed('/buyer'); // shell route; use your AppRoutes constant if you have one
            }
          },
        eyebrow: o?.referenceNumber ?? 'buyer.orders.detail.order'.tr,
        title: o?.snapshot.title ?? 'buyer.orders.detail.title'.tr,
        heroExtra: o == null
            ? null
            : HeroPill(
          label: _statusLabel(o.status),
          icon: Icons.radio_button_checked_rounded,
        ),
        art: const HeroArt(
          icon: Icons.inventory_2_rounded,
          satellites: [
            Icons.local_shipping_outlined,
            Icons.verified_user_outlined,
            Icons.payments_outlined,
          ],
        ),
        onRefresh: controller.load,
        bottomBar: actions.isEmpty ? null : ProBottomBar(children: actions),
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
              : _content(context, o, canDispute),
        ),
      );
    });
  }

  Widget _content(BuildContext context, dynamic o, bool canDispute) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final history = o.statusHistory as List;
    final urls = controller.imageUrls.toList();

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        if (urls.isNotEmpty) RequestGallery(urls: urls),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('buyer.orders.detail.title'.tr,
                  icon: Icons.inventory_2_outlined),
              const SizedBox(height: 6),
              ProInfoList(rows: [
                ProInfoRow(
                  label: 'buyer.orders.detail.quantity'.tr,
                  value:
                  '${o.snapshot.quantity} ${o.snapshot.unitOfMeasurement}',
                ),
                ProInfoRow(
                    label: 'buyer.orders.detail.deliveryCity'.tr,
                    value: o.snapshot.deliveryCity),
                ProInfoRow(
                  label: 'buyer.orders.detail.condition'.tr,
                  value: Formatters.humanize(o.snapshot.productCondition),
                ),
                if (o.snapshot.warrantyOffered != null)
                  ProInfoRow(
                      label: 'buyer.orders.detail.warranty'.tr,
                      value: o.snapshot.warrantyOffered!),
                ProInfoRow(
                    label: 'buyer.orders.detail.importer'.tr,
                    value: o.snapshot.importerBusinessName),
              ]),
            ],
          ),
        ),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('buyer.orders.detail.costBreakdown'.tr,
                  icon: Icons.receipt_outlined),
              const SizedBox(height: 6),
              ProInfoList(rows: [
                for (final c in o.snapshot.itemizedCosts)
                  ProInfoRow(
                      label: c.label, value: Formatters.etb(c.amountETB)),
              ]),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Text('buyer.orders.detail.total'.tr,
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
                label: 'buyer.orders.detail.platformFee'.tr,
                value:
                '${Formatters.etb(o.platformFeeETB)} (${o.platformFeePayer})',
              ),
            ],
          ),
        ),
        if (o.counterparty != null && o.counterparty!.phone != null)
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('buyer.orders.detail.importerContact'.tr,
                    icon: Icons.support_agent_rounded),
                const SizedBox(height: 6),
                ProInfoList(rows: [
                  ProInfoRow(
                      label: 'buyer.orders.detail.business'.tr,
                      value: o.counterparty!.businessName ?? '—'),
                  ProInfoRow(
                      label: 'buyer.orders.detail.name'.tr,
                      value: o.counterparty!.fullName ?? '—'),
                  ProInfoRow(
                      label: 'buyer.orders.detail.phone'.tr,
                      icon: Icons.phone_outlined,
                      value: o.counterparty!.phone ?? '—'),
                  ProInfoRow(
                      label: 'buyer.orders.detail.email'.tr,
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
              ProSectionTitle('buyer.orders.detail.timeline'.tr,
                  icon: Icons.timeline_rounded),
              const SizedBox(height: 16),
              for (var i = 0; i < history.length; i++)
                _TimelineTile(
                  label: _statusLabel(history[i].to),
                  time: Formatters.relative(history[i].at),
                  last: i == history.length - 1,
                ),
            ],
          ),
        ),
        if (canDispute)
          Center(
            child: TextButton.icon(
              onPressed: controller.goToDispute,
              icon: Icon(Icons.flag_outlined, color: scheme.error, size: 18),
              label: Text('buyer.orders.detail.openDispute'.tr,
                  style: TextStyle(color: scheme.error)),
            ),
          ),
      ],
    );
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

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.label,
    required this.time,
    required this.last,
  });
  final String label;
  final String time;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                    boxShadow: [
                      if (last)
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: .35),
                          blurRadius: 0,
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.primary.withValues(alpha: .25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: last ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(time, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}