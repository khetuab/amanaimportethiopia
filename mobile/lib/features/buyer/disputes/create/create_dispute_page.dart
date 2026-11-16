import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import 'create_dispute_controller.dart';

class CreateDisputePage extends GetView<CreateDisputeController> {
  const CreateDisputePage({super.key});

  static IconData _icon(String r) {
    final s = r.toLowerCase();
    if (s.contains('damage') || s.contains('broken')) {
      return Icons.broken_image_outlined;
    }
    if (s.contains('receiv') || s.contains('missing')) {
      return Icons.inventory_2_outlined;
    }
    if (s.contains('wrong') || s.contains('described') || s.contains('match')) {
      return Icons.compare_arrows_rounded;
    }
    if (s.contains('fake') || s.contains('counterfeit')) {
      return Icons.gpp_bad_outlined;
    }
    if (s.contains('quality') || s.contains('defect')) {
      return Icons.build_circle_outlined;
    }
    if (s.contains('payment') || s.contains('refund')) {
      return Icons.payments_outlined;
    }
    if (s.contains('delay') || s.contains('late')) {
      return Icons.schedule_rounded;
    }
    return Icons.report_problem_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reason = controller.reason.value;
      final images = controller.images.toList();
      final submitting = controller.submitting.value;

      return ProPage(
        showBack: true,
        eyebrow: 'buyer.disputes.eyebrow'.tr,
        title: 'buyer.disputes.create.title'.tr,
        subtitle: 'buyer.disputes.create.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.gavel_rounded,
          satellites: [
            Icons.shield_outlined,
            Icons.photo_camera_outlined,
            Icons.support_agent_rounded,
          ],
        ),
        body: Form(
          key: controller.formKey,
          child: ProStagger(
            gap: 20,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProSectionTitle('buyer.disputes.create.reason'.tr,
                      icon: Icons.flag_outlined),
                  const SizedBox(height: 12),
                  ProGrid2(
                    gap: 10,
                    children: [
                      for (final r in CreateDisputeController.reasons)
                        ProCard(
                          highlight: reason == r,
                          padding: const EdgeInsets.all(14),
                          onTap: () => controller.pickReason(r),
                          child: Row(
                            children: [
                              Icon(
                                _icon(r),
                                size: 22,
                                color: reason == r
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: .6),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  controller.humanReason(r),
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: reason == r
                                        ? FontWeight.w800
                                        : FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              PremiumField(
                controller: controller.descriptionCtrl,
                label: 'buyer.disputes.create.describeIssue'.tr,
                icon: Icons.edit_note_rounded,
                maxLines: 5,
                keyboardType: TextInputType.multiline,
                validator: controller.validateDescription,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProSectionTitle('buyer.disputes.create.evidence'.tr,
                      icon: Icons.photo_library_outlined),
                  const SizedBox(height: 4),
                  Text('buyer.disputes.create.evidenceOptional'.tr,
                      style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(height: 12),
                  AppImagePicker(
                    files: images,
                    onAdd: controller.addImage,
                    onRemove: controller.removeImage,
                    maxCount: 6,
                  ),
                ],
              ),
              PremiumButton(
                label: 'buyer.disputes.create.submit'.tr,
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