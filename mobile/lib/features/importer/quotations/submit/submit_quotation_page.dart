import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import '../../../buyer/requests/widgets/request_image.dart';
import 'submit_quotation_controller.dart';

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

class SubmitQuotationPage extends GetView<SubmitQuotationController> {
  const SubmitQuotationPage({super.key});

  static const _conditions = [
    'new',
    'used_like_new',
    'used_good',
    'used_fair',
    'refurbished',
  ];

  @override
  Widget build(BuildContext context) {
    final r = controller.request;
    final urls = imageUrlsFor(r);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ProPage(
      showBack: true,
      eyebrow: 'importer.quotationSubmit.eyebrow'.tr,
      title: 'importer.quotationSubmit.title'.tr,
      subtitle: 'importer.quotationSubmit.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.request_quote_rounded,
        satellites: [
          Icons.payments_outlined,
          Icons.local_shipping_outlined,
          Icons.verified_outlined,
        ],
      ),
      bottomBar: Obx(
            () => ProBottomBar(children: [
          PremiumButton(
            label: 'importer.quotationSubmit.title'.tr,
            icon: Icons.send_rounded,
            loading: controller.submitting.value,
            onPressed: controller.submit,
          ),
        ]),
      ),
      body: Form(
        key: controller.formKey,
        child: ProStagger(
          gap: 18,
          children: [
            // Request banner.
            if (urls.isNotEmpty) RequestGallery(urls: urls),
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AuthPalette.emeraldMid, AuthPalette.emeraldDeep],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HeroPill(
                        label: 'importer.quotationSubmit.quotingFor'.tr,
                        icon: Icons.request_quote_outlined),
                    const SizedBox(height: 12),
                    Text(
                      r.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${r.quantity} ${r.unitOfMeasurement} · ${r.deliveryCity}',
                      style: TextStyle(
                          color: AuthPalette.mint.withValues(alpha: .95),
                          fontWeight: FontWeight.w600),
                    ),
                    if (r.description.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        r.description,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .8),
                            height: 1.45,
                            fontSize: 13),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            ProCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProSectionTitle('importer.quotationSubmit.pricing'.tr,
                      icon: Icons.payments_outlined),
                  const SizedBox(height: 16),
                  PremiumField(
                    controller: controller.totalCtrl,
                    label: 'importer.quotation.totalPrice'.tr,
                    icon: Icons.payments_outlined,
                    keyboardType: TextInputType.number,
                    validator: controller.validateTotal,
                  ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: controller.addLine,
                      icon: const Icon(Icons.add_rounded),
                      label: Text('importer.quotationSubmit.addItemizedCost'.tr),
                    ),
                  ),
                  Obx(
                        () => Column(
                      children: List.generate(controller.lines.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: PremiumField(
                                  label: 'importer.quotationSubmit.label'.tr,
                                  onChanged: (v) =>
                                      controller.updateLine(i, label: v),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: PremiumField(
                                  label: 'importer.quotationSubmit.amount'.tr,
                                  keyboardType: TextInputType.number,
                                  onChanged: (v) => controller.updateLine(
                                    i,
                                    amount: double.tryParse(v) ?? 0,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: 'importer.quotationSubmit.remove'.tr,
                                icon: Icon(Icons.remove_circle_outline,
                                    color: scheme.error),
                                onPressed: () => controller.removeLine(i),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 250.ms)
                            .slideY(begin: .2, end: 0);
                      }),
                    ),
                  ),
                  Obx(
                        () => Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: scheme.primary.withValues(alpha: .08),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calculate_outlined,
                              size: 18, color: scheme.primary),
                          const SizedBox(width: 8),
                          Text('importer.quotationSubmit.itemizedTotal'.tr,
                              style: theme.textTheme.bodyMedium),
                          const Spacer(),
                          ProCountUp(
                            value: asDouble(controller.linesTotal),
                            duration: const Duration(milliseconds: 400),
                            format: (v) => Formatters.etb(v),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: scheme.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ProCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProSectionTitle(
                      'importer.quotationSubmit.productDetails'.tr,
                      icon: Icons.inventory_2_outlined),
                  const SizedBox(height: 16),
                  Obx(
                        () => Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final c in _conditions)
                          ProSelectChip(
                            label: _condLabel(c),
                            selected: controller.condition.value == c,
                            onTap: () => controller.setCondition(c),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  PremiumField(
                    controller: controller.specsCtrl,
                    label: 'importer.quotationSubmit.specifications'.tr,
                    icon: Icons.list_alt_rounded,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 14),
                  PremiumField(
                    controller: controller.warrantyCtrl,
                    label: 'importer.quotation.warranty'.tr,
                    hint: 'importer.quotationSubmit.warrantyHint'.tr,
                    icon: Icons.shield_outlined,
                  ),
                  const SizedBox(height: 14),
                  PremiumField(
                    controller: controller.returnCtrl,
                    label: 'importer.quotationSubmit.returnPolicy'.tr,
                    hint: 'importer.quotationSubmit.returnHint'.tr,
                    icon: Icons.assignment_return_outlined,
                  ),
                ],
              ),
            ),
            ProCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProSectionTitle('importer.quotationSubmit.delivery'.tr,
                      icon: Icons.local_shipping_outlined),
                  const SizedBox(height: 16),
                  PremiumField(
                    controller: controller.deliveryDaysCtrl,
                    label: 'importer.quotationSubmit.deliveryDays'.tr,
                    icon: Icons.schedule_rounded,
                    keyboardType: TextInputType.number,
                    validator: controller.validateDays,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                        () => ProDateTile(
                      label: 'importer.quotationSubmit.validUntil'.tr,
                      value: Formatters.date(controller.validUntil.value),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          firstDate:
                          DateTime.now().add(const Duration(days: 1)),
                          lastDate:
                          DateTime.now().add(const Duration(days: 60)),
                          initialDate: controller.validUntil.value,
                        );
                        if (picked != null) controller.pickValidUntil(picked);
                      },
                    ),
                  ),
                ],
              ),
            ),
            ProCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ProSectionTitle('importer.quotationSubmit.notesTerms'.tr,
                      icon: Icons.sticky_note_2_outlined),
                  const SizedBox(height: 16),
                  PremiumField(
                    controller: controller.notesCtrl,
                    label: 'importer.quotationSubmit.notes'.tr,
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 14),
                  PremiumField(
                    controller: controller.exclusionsCtrl,
                    label: 'importer.quotationSubmit.exclusions'.tr,
                    icon: Icons.block_rounded,
                    maxLines: 2,
                    keyboardType: TextInputType.multiline,
                  ),
                  const SizedBox(height: 14),
                  Obx(
                        () => ProSwitchTile(
                      title: 'importer.quotationSubmit.finalCosts'.tr,
                      subtitle: 'importer.quotationSubmit.finalCostsHint'.tr,
                      icon: Icons.lock_outline_rounded,
                      value: controller.estimateFinal.value,
                      onChanged: controller.setEstimateFinal,
                    ),
                  ),
                ],
              ),
            ),
            ProCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProSectionTitle('importer.quotationSubmit.attachments'.tr,
                      icon: Icons.attach_file_rounded),
                  const SizedBox(height: 4),
                  Text('importer.quotationSubmit.attachmentsHint'.tr,
                      style: theme.textTheme.bodySmall),
                  const SizedBox(height: 14),
                  Obx(
                        () => AppImagePicker(
                      files: controller.attachments.toList(),
                      onAdd: controller.addAttachment,
                      onRemove: controller.removeAttachment,
                      maxCount: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}