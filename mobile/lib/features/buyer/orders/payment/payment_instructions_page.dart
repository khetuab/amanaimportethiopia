import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import 'payment_instructions_controller.dart';

class PaymentInstructionsPage extends GetView<PaymentInstructionsController> {
  const PaymentInstructionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.loading.value;
      final error = controller.error.value;
      final i = controller.instructions;
      final ready = !loading && error == null && i.isNotEmpty;

      return ProPage(
        showBack: true,
        eyebrow: 'buyer.orders.payment.eyebrow'.tr,
        title: 'buyer.orders.payment.title'.tr,
        subtitle: 'buyer.orders.payment.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.account_balance_wallet_rounded,
          satellites: [
            Icons.lock_outline_rounded,
            Icons.phone_android_rounded,
            Icons.account_balance_outlined,
          ],
        ),
        bottomBar: ready
            ? ProBottomBar(children: [
          PremiumButton(
            label: 'buyer.orders.payment.iHavePaid'.tr,
            icon: Icons.upload_file_rounded,
            onPressed: controller.goToSubmit,
          ),
        ])
            : null,
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 2, itemHeight: 200)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : i.isEmpty
              ? ProEmptyState(
            key: const ValueKey('empty'),
            title: 'buyer.orders.payment.emptyTitle'.tr,
            description: 'buyer.orders.payment.emptyDescription'.tr,
            icon: Icons.account_balance_wallet_outlined,
            satellites: [
              Icons.lock_outline_rounded,
              Icons.payments_outlined,
            ],
          )
              : _content(context, i),
        ),
      );
    });
  }

  Widget _content(BuildContext context, Map i) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final amount = (i['amountETB'] as num?)?.toDouble();

    return ProStagger(
      key: const ValueKey('data'),
      gap: 20,
      children: [
        // Ticket.
        ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AuthPalette.emeraldMid, AuthPalette.emeraldDeep],
                  ),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HeroPill(
                            label: 'buyer.orders.payment.payVia'.trParams({
                              'channel': Formatters.humanize(
                                  (i['channel'] ?? '').toString()),
                            }),
                            icon: Icons.payments_outlined,
                          ),
                          const SizedBox(height: 18),
                          Text('buyer.orders.payment.amountToPay'.tr,
                              style: TextStyle(
                                  color: Colors.white.withValues(alpha: .75),
                                  fontSize: 13)),
                          const SizedBox(height: 4),
                          ProCountUp(
                            value: amount ?? 0,
                            format: (v) => Formatters.etb(v),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Perforation.
                    Row(
                      children: [
                        for (var k = 0; k < 28; k++)
                          Expanded(
                            child: Container(
                              height: 1.5,
                              margin:
                              const EdgeInsets.symmetric(horizontal: 2),
                              color: k.isEven
                                  ? Colors.white.withValues(alpha: .35)
                                  : Colors.transparent,
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 14, 12, 14),
                      child: Column(
                        children: [
                          _TicketRow(
                              label: 'buyer.orders.payment.recipient'.tr,
                              value: (i['recipientName'] ?? '').toString()),
                          if (i['bankName'] != null)
                            _TicketRow(
                                label: 'buyer.orders.payment.bank'.tr,
                                value: i['bankName'].toString()),
                          _TicketRow(
                            label: 'buyer.orders.payment.account'.tr,
                            value: (i['recipientAccount'] ?? '').toString(),
                            copy: true,
                          ),
                          _TicketRow(
                            label: 'buyer.orders.payment.reference'.tr,
                            value: (i['reference'] ?? '').toString(),
                            copy: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Notches.
              Positioned(
                left: -12,
                top: 138,
                child: CircleAvatar(radius: 12, backgroundColor: bg),
              ),
              Positioned(
                right: -12,
                top: 138,
                child: CircleAvatar(radius: 12, backgroundColor: bg),
              ),
            ],
          ),
        ),
        if (i['notes'] is List)
          ProCallout(
            icon: Icons.info_outline_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('buyer.orders.payment.important'.tr,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                for (final n in (i['notes'] as List))
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 7, right: 10),
                          child: Icon(Icons.circle, size: 5),
                        ),
                        Expanded(child: Text(n.toString())),
                      ],
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TicketRow extends StatelessWidget {
  const _TicketRow({required this.label, required this.value, this.copy = false});
  final String label;
  final String value;
  final bool copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .7), fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
              ),
            ),
          ),
          if (copy)
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: 'buyer.orders.payment.copyField'
                  .trParams({'label': label}),
              icon: const Icon(Icons.copy_rounded,
                  size: 18, color: AuthPalette.mint),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                HapticFeedback.lightImpact();
                Get.snackbar(
                  'buyer.orders.payment.copied'.tr,
                  'buyer.orders.payment.copiedToClipboard'
                      .trParams({'label': label}),
                );
              },
            )
          else
            const SizedBox(width: 12),
        ],
      ),
    );
  }
}