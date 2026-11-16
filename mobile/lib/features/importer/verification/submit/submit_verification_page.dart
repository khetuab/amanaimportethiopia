import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import 'submit_verification_controller.dart';

/// Maps a raw business type value to its localized display label.
String _typeLabel(String t) {
  const keys = {
    'individual': 'importer.verification.type.individual',
    'company': 'importer.verification.type.company',
    'partnership': 'importer.verification.type.partnership',
  };
  final k = keys[t];
  return k == null ? Formatters.humanize(t) : k.tr;
}

class SubmitVerificationPage extends GetView<SubmitVerificationController> {
  const SubmitVerificationPage({super.key});

  static const _areas = [
    'Addis Ababa',
    'Adama',
    'Bahir Dar',
    'Hawassa',
    'Mekelle',
    'Dire Dawa',
    'Gondar',
    'Jimma',
  ];

  static const _docs = [
    ('business_license', 'importer.verification.doc.businessLicense',
        Icons.business_center_outlined),
    ('tin_certificate', 'importer.verification.doc.tinCertificate',
        Icons.numbers_rounded),
    ('national_id', 'importer.verification.doc.nationalId', Icons.badge_outlined),
    ('import_license', 'importer.verification.doc.importLicense',
        Icons.flight_land_rounded),
  ];

  static IconData _typeIcon(String t) => switch (t) {
    'individual' => Icons.person_outline_rounded,
    'company' => Icons.apartment_rounded,
    _ => Icons.handshake_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return ProPage(
      showBack: true,
      eyebrow: 'importer.verification.submitEyebrow'.tr,
      title: 'importer.verification.submitTitle'.tr,
      subtitle: 'importer.verification.submitSubtitle'.tr,
      art: const HeroArt(
        icon: Icons.verified_user_rounded,
        satellites: [
          Icons.description_outlined,
          Icons.badge_outlined,
          Icons.storefront_outlined,
        ],
      ),
      bottomBar: Obx(() {
        if (controller.loading.value) return const SizedBox.shrink();
        return ProBottomBar(children: [
          PremiumButton(
            label: 'importer.verification.submit'.tr,
            icon: Icons.send_rounded,
            loading: controller.submitting.value,
            onPressed: controller.submit,
          ),
        ]);
      }),
      body: Obx(
            () => ProStateSwitcher(
          child: controller.loading.value
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 3, itemHeight: 160)
              : _form(context),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Form(
      key: controller.formKey,
      child: ProStagger(
        key: const ValueKey('form'),
        gap: 18,
        children: [
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProSectionTitle('importer.profile.title'.tr,
                    icon: Icons.storefront_outlined),
                const SizedBox(height: 16),
                PremiumField(
                  controller: controller.businessNameCtrl,
                  label: 'importer.verification.businessName'.tr,
                  icon: Icons.business_rounded,
                  textInputAction: TextInputAction.next,
                  validator: controller.validateBusinessName,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in const ['individual', 'company', 'partnership'])
                      ProSelectChip(
                        label: _typeLabel(t),
                        icon: _typeIcon(t),
                        selected: controller.businessType.value == t,
                        onTap: () => controller.setBusinessType(t),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                PremiumField(
                  controller: controller.tinCtrl,
                  label: 'importer.verification.tinNumber'.tr,
                  icon: Icons.numbers_rounded,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                PremiumField(
                  controller: controller.licenseCtrl,
                  label: 'importer.verification.licenseNumber'.tr,
                  icon: Icons.workspace_premium_outlined,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                PremiumField(
                  controller: controller.yearCtrl,
                  label: 'importer.verification.yearEstablished'.tr,
                  icon: Icons.event_outlined,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 14),
                PremiumField(
                  controller: controller.descriptionCtrl,
                  label: 'importer.verification.description'.tr,
                  icon: Icons.notes_rounded,
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                ),
                const SizedBox(height: 14),
                PremiumField(
                  controller: controller.contactPhoneCtrl,
                  label: 'importer.verification.phone'.tr,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: controller.validatePhone,
                ),
              ],
            ),
          ),
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('importer.verification.serviceAreas'.tr,
                    icon: Icons.map_outlined),
                const SizedBox(height: 4),
                Text('importer.verification.whereDeliver'.tr,
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in _areas)
                      ProSelectChip(
                        label: c,
                        icon: controller.serviceAreas.contains(c)
                            ? Icons.check_rounded
                            : Icons.add_rounded,
                        selected: controller.serviceAreas.contains(c),
                        onTap: () => controller.toggleServiceArea(c),
                      ),
                  ],
                ),
              ],
            ),
          ),
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProSectionTitle('importer.verification.documents'.tr,
                    icon: Icons.folder_open_outlined),
                const SizedBox(height: 4),
                Text('importer.verification.documentsHint'.tr,
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 14),
                for (final d in _docs)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ProCard(
                      padding: const EdgeInsets.all(12),
                      onTap: () => controller.pickDocument(
                          type: d.$1, label: d.$2.tr),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child:
                            Icon(d.$3, size: 21, color: scheme.primary),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                                'importer.verification.uploadDoc'.trParams(
                                    {'doc': d.$2.tr}),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700)),
                          ),
                          Icon(Icons.add_a_photo_outlined,
                              size: 20, color: scheme.primary),
                        ],
                      ),
                    ),
                  ),
                if (controller.documents.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text('importer.verification.uploaded'.tr,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  for (final d in controller.documents)
                    Builder(builder: (_) {
                      final isApproved = d['isApproved'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                          decoration: BoxDecoration(
                            color: scheme.onSurface.withValues(alpha: .04),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.description_outlined,
                                  color: scheme.primary),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      Formatters.humanize(
                                          (d['type'] ?? '').toString()),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const SizedBox(height: 4),
                                    ProPill(
                                      label: isApproved == true
                                          ? 'status.approved'.tr
                                          : isApproved == false
                                          ? 'status.rejected'.tr
                                          : 'status.pendingReview'.tr,
                                      tone: isApproved == true
                                          ? AppBadgeTone.green
                                          : isApproved == false
                                          ? AppBadgeTone.red
                                          : AppBadgeTone.amber,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: isApproved == true
                                    ? null
                                    : () => controller.removeDocument(
                                    (d['_id'] ?? '').toString()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}