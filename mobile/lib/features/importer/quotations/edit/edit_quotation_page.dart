import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import '../../../buyer/requests/widgets/request_image.dart';
import 'edit_quotation_controller.dart';

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

class EditQuotationPage extends GetView<EditQuotationController> {
  const EditQuotationPage({super.key});

  static const _conditions = [
    'new',
    'used_like_new',
    'used_good',
    'used_fair',
    'refurbished',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ProPage(
      showBack: true,
      eyebrow: 'importer.quotationEdit.eyebrow'.tr,
      title: 'importer.quotationEdit.title'.tr,
      subtitle: 'importer.quotationEdit.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.edit_note_rounded,
        satellites: [
          Icons.payments_outlined,
          Icons.schedule_rounded,
          Icons.verified_outlined,
        ],
      ),
      bottomBar: Obx(
            () => ProBottomBar(children: [
          PremiumButton(
            label: 'importer.quotationEdit.saveChanges'.tr,
            icon: Icons.check_rounded,
            loading: controller.submitting.value,
            onPressed: controller.save,
          ),
          TextButton.icon(
            onPressed: controller.withdraw,
            icon: Icon(Icons.undo_rounded, size: 18, color: scheme.error),
            label: Text('importer.quotationEdit.withdrawQuotation'.tr,
                style: TextStyle(color: scheme.error)),
          ),
        ]),
      ),
      body: Form(
        key: controller.formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final urls = controller.imageUrls.toList();
              if (urls.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: RequestGallery(urls: urls),
              );
            }),
            ProStagger(
              gap: 18,
              children: [
                PremiumField(
                  controller: controller.totalCtrl,
                  label: 'importer.quotation.totalPrice'.tr,
                  icon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: controller.validateTotal,
                ),
                PremiumField(
                  controller: controller.deliveryDaysCtrl,
                  label: 'importer.quotation.deliveryDays'.tr,
                  icon: Icons.schedule_rounded,
                  keyboardType: TextInputType.number,
                  validator: controller.validateDays,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProSectionTitle('importer.quotationEdit.condition'.tr,
                        icon: Icons.verified_outlined),
                    const SizedBox(height: 12),
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
                  ],
                ),
                PremiumField(
                  controller: controller.warrantyCtrl,
                  label: 'importer.quotation.warranty'.tr,
                  icon: Icons.shield_outlined,
                ),
                PremiumField(
                  controller: controller.notesCtrl,
                  label: 'importer.quotationEdit.notes'.tr,
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                Obx(
                      () => ProDateTile(
                    label: 'importer.quotation.validUntil'.tr,
                    value: Formatters.date(controller.validUntil.value),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 60)),
                        initialDate: controller.validUntil.value,
                      );
                      if (picked != null) controller.pickValidUntil(picked);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}