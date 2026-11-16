import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_image_picker.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../auth/widgets/premium_button.dart';
import '../../auth/widgets/premium_field.dart';
import 'report_fraud_controller.dart';

class ReportFraudPage extends GetView<ReportFraudController> {
  const ReportFraudPage({super.key});

  static IconData _icon(String c) {
    final s = c.toLowerCase();
    if (s.contains('fake') || s.contains('counterfeit')) {
      return Icons.gpp_bad_outlined;
    }
    if (s.contains('payment') || s.contains('money')) {
      return Icons.payments_outlined;
    }
    if (s.contains('imperson') || s.contains('identity')) {
      return Icons.person_off_outlined;
    }
    if (s.contains('scam') || s.contains('phish')) {
      return Icons.phishing_rounded;
    }
    if (s.contains('harass') || s.contains('abuse')) {
      return Icons.report_gmailerrorred_rounded;
    }
    if (s.contains('deliver') || s.contains('ship')) {
      return Icons.local_shipping_outlined;
    }
    return Icons.report_problem_outlined;
  }

  /// Display label for a category. Match values (e.g. 'payment_scam') are
  /// never translated — only the shown label goes through the lookup.
  static const _categoryKeys = <String, String>{
    'suspected_fraud': 'fraud.category.suspectedFraud',
    'fake_importer': 'fraud.category.fakeImporter',
    'counterfeit_product': 'fraud.category.counterfeitProduct',
    'payment_scam': 'fraud.category.paymentScam',
    'off_platform_deal': 'fraud.category.offPlatformDeal',
    'harassment': 'fraud.category.harassment',
    'other': 'fraud.category.other',
  };

  String _categoryLabel(String c) {
    final key = _categoryKeys[c];
    return key != null ? key.tr : controller.humanize(c);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ProPage(
      showBack: true,
      eyebrow: 'fraud.eyebrow'.tr,
      title: 'fraud.title'.tr,
      subtitle: 'fraud.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.shield_rounded,
        satellites: [
          Icons.report_problem_outlined,
          Icons.photo_camera_outlined,
          Icons.support_agent_rounded,
        ],
      ),
      bottomBar: Obx(
            () => ProBottomBar(children: [
          PremiumButton(
            label: 'fraud.submit'.tr,
            icon: Icons.send_rounded,
            loading: controller.submitting.value,
            onPressed: controller.submit,
          ),
        ]),
      ),
      body: Form(
        key: controller.formKey,
        child: ProStagger(
          gap: 20,
          children: [
            ProCallout(
              icon: Icons.info_outline_rounded,
              child: Text(
                'fraud.callout'.tr,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('fraud.whatHappened'.tr,
                    icon: Icons.flag_outlined),
                const SizedBox(height: 12),
                Obx(() {
                  final selected = controller.category.value;
                  return ProGrid2(
                    gap: 10,
                    children: [
                      for (final c in ReportFraudController.categories)
                        ProCard(
                          highlight: selected == c,
                          padding: const EdgeInsets.all(14),
                          onTap: () => controller.setCategory(c),
                          child: Row(
                            children: [
                              Icon(
                                _icon(c),
                                size: 22,
                                color: selected == c
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurface
                                    .withValues(alpha: .6),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _categoryLabel(c),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: selected == c
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                }),
              ],
            ),
            PremiumField(
              controller: controller.descriptionCtrl,
              label: 'fraud.describeIssue'.tr,
              icon: Icons.edit_note_rounded,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              validator: controller.validateDescription,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('fraud.evidence'.tr,
                    icon: Icons.photo_library_outlined),
                const SizedBox(height: 4),
                Text('fraud.evidenceHint'.tr,
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 12),
                Obx(
                      () => AppImagePicker(
                    files: controller.images.toList(),
                    onAdd: controller.addImage,
                    onRemove: controller.removeImage,
                    maxCount: 4,
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