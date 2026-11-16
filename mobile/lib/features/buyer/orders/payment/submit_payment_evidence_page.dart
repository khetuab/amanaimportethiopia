import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import 'submit_payment_evidence_controller.dart';

class SubmitPaymentEvidencePage
    extends GetView<SubmitPaymentEvidenceController> {
  const SubmitPaymentEvidencePage({super.key});

  static const _channels = [
    'bank_transfer',
    'telebirr',
    'cbe_birr',
    'awash_birr',
    'other',
  ];

  static IconData _icon(String c) => switch (c) {
    'bank_transfer' => Icons.account_balance_rounded,
    'telebirr' => Icons.phone_android_rounded,
    'cbe_birr' || 'awash_birr' => Icons.account_balance_wallet_rounded,
    _ => Icons.more_horiz_rounded,
  };

  static String _channelLabel(String c) => switch (c) {
    'bank_transfer' => 'buyer.orders.payment.channelBankTransfer'.tr,
    'telebirr' => 'buyer.orders.payment.channelTelebirr'.tr,
    'cbe_birr' => 'buyer.orders.payment.channelCbeBirr'.tr,
    'awash_birr' => 'buyer.orders.payment.channelAwashBirr'.tr,
    _ => 'buyer.orders.payment.channelOther'.tr,
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final channel = controller.channel.value;
      final paidAt = controller.paidAt.value;
      final receipts = controller.receipts.toList();
      final submitting = controller.submitting.value;

      return ProPage(
        showBack: true,
        eyebrow: 'buyer.orders.payment.eyebrow'.tr,
        title: 'buyer.orders.payment.submitEvidence'.tr,
        subtitle: 'buyer.orders.payment.submitSubtitle'.tr,
        art: const HeroArt(
          icon: Icons.fact_check_rounded,
          satellites: [
            Icons.receipt_long_outlined,
            Icons.photo_camera_outlined,
            Icons.verified_outlined,
          ],
        ),
        body: Form(
          key: controller.formKey,
          child: ProStagger(
            gap: 18,
            children: [
              PremiumField(
                controller: controller.referenceCtrl,
                label: 'buyer.orders.payment.referenceLabel'.tr,
                hint: 'buyer.orders.payment.referenceHint'.tr,
                icon: Icons.tag_rounded,
                textInputAction: TextInputAction.next,
                validator: controller.validateReference,
              ),
              PremiumField(
                controller: controller.amountCtrl,
                label: 'buyer.orders.payment.amountLabel'.tr,
                icon: Icons.payments_outlined,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: controller.validateAmount,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProSectionTitle('buyer.orders.payment.channelTitle'.tr,
                      icon: Icons.swap_horiz_rounded),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in _channels)
                        ProSelectChip(
                          label: _channelLabel(c),
                          icon: _icon(c),
                          selected: channel == c,
                          onTap: () => controller.pickChannel(c),
                        ),
                    ],
                  ),
                ],
              ),
              AppCardDate(
                label: 'buyer.orders.payment.paidAt'.tr,
                value: paidAt,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate:
                    DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                    initialDate: controller.paidAt.value,
                  );
                  if (picked != null) controller.pickPaidAt(picked);
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProSectionTitle('buyer.orders.payment.receipt'.tr,
                      icon: Icons.receipt_long_outlined),
                  const SizedBox(height: 4),
                  Text(
                    'buyer.orders.payment.receiptOptional'.tr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  AppImagePicker(
                    files: receipts,
                    onAdd: controller.addReceipt,
                    onRemove: controller.removeReceipt,
                    maxCount: 1,
                  ),
                ],
              ),
              PremiumButton(
                label: 'buyer.orders.payment.submitEvidenceButton'.tr,
                icon: Icons.send_rounded,
                loading: submitting,
                onPressed: controller.submit,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class AppCardDate extends StatelessWidget {
  const AppCardDate({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final DateTime value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.calendar_month_outlined, color: scheme.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  Formatters.date(value),
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_calendar_outlined,
              size: 20, color: scheme.onSurface.withValues(alpha: .5)),
        ],
      ),
    );
  }
}