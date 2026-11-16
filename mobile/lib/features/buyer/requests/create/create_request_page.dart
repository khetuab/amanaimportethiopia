import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_image_picker.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../../../auth/widgets/premium_field.dart';
import 'create_request_controller.dart';

class CreateRequestPage extends GetView<CreateRequestController> {
  const CreateRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProPage(
      showBack: true,
      eyebrow: 'buyer.requests.create.eyebrow'.tr,
      title: 'buyer.requests.newRequest'.tr,
      subtitle: 'buyer.requests.create.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.add_shopping_cart_rounded,
        satellites: [
          Icons.smartphone_rounded,
          Icons.settings_suggest_outlined,
          Icons.checkroom_rounded,
        ],
      ),
      bottomBar: Obx(() {
        if (controller.loadingCats.value) return const SizedBox.shrink();
        final busy = controller.submitting.value;
        return ProBottomBar(children: [
          if (busy && controller.uploadProgress.value > 0 && controller.uploadProgress.value < 1)
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: controller.uploadProgress.value,
                minHeight: 6,
              ),
            ),
          Row(
            children: [
              Expanded(
                child: PremiumButton(
                  label: 'buyer.requests.create.saveDraft'.tr,
                  style: PremiumButtonStyle.outlined,
                  loading: busy,
                  onPressed: () => controller.save(publish: false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PremiumButton(
                  label: 'buyer.requests.create.publish'.tr,
                  icon: Icons.rocket_launch_rounded,
                  loading: busy,
                  onPressed: () => controller.save(publish: true),
                ),
              ),
            ],
          ),
        ]);
      }),
      body: Obx(
            () => ProStateSwitcher(
          child: controller.loadingCats.value
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 4, itemHeight: 150)
              : _form(context),
        ),
      ),
    );
  }

  Widget _form(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: ProStagger(
        key: const ValueKey('form'),
        gap: 18,
        children: [
          _Section(
            title: 'buyer.requests.create.sectionProduct'.tr,
            icon: Icons.inventory_2_outlined,
            children: [
              PremiumField(
                controller: controller.titleCtrl,
                label: 'buyer.requests.create.titleLabel'.tr,
                hint: 'buyer.requests.create.titleHint'.tr,
                icon: Icons.title_rounded,
                textInputAction: TextInputAction.next,
                validator: controller.validateTitle,
              ),
              PremiumField(
                controller: controller.descriptionCtrl,
                label: 'buyer.requests.field.description'.tr,
                hint: 'buyer.requests.create.descriptionHint'.tr,
                icon: Icons.notes_rounded,
                maxLines: 4,
                keyboardType: TextInputType.multiline,
                validator: controller.validateDescription,
              ),
              ProPickerField<String>(
                label: 'buyer.requests.field.category'.tr,
                hint: 'buyer.requests.create.categoryHint'.tr,
                icon: Icons.category_outlined,
                value: controller.selectedCategory.value?.id,
                options: [
                  for (final c in controller.categories)
                    ProOption<String>(c.id, c.name),
                ],
                onChanged: (id) {
                  final cat =
                  controller.categories.firstWhereOrNull((c) => c.id == id);
                  controller.pickCategory(cat);
                },
              ),
              PremiumField(
                controller: controller.brandCtrl,
                label: 'buyer.requests.create.brandLabel'.tr,
                icon: Icons.sell_outlined,
                textInputAction: TextInputAction.next,
              ),
              PremiumField(
                controller: controller.modelCtrl,
                label: 'buyer.requests.create.modelLabel'.tr,
                icon: Icons.memory_rounded,
                textInputAction: TextInputAction.next,
              ),
              PremiumField(
                controller: controller.referenceUrlCtrl,
                label: 'buyer.requests.create.referenceUrlLabel'.tr,
                hint: 'buyer.requests.create.referenceUrlHint'.tr,
                icon: Icons.link_rounded,
                keyboardType: TextInputType.url,
                validator: controller.validateUrl,
              ),
              PremiumField(
                controller: controller.specificationsCtrl,
                label: 'buyer.requests.create.specificationsLabel'.tr,
                icon: Icons.list_alt_rounded,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
          _Section(
            title: 'buyer.requests.create.sectionQuantityBudget'.tr,
            icon: Icons.payments_outlined,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PremiumField(
                      controller: controller.quantityCtrl,
                      label: 'buyer.requests.field.quantity'.tr,
                      icon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number,
                      validator: controller.validateQuantity,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PremiumField(
                      controller: controller.unitCtrl,
                      label: 'buyer.requests.create.unitLabel'.tr,
                      hint: 'buyer.requests.create.unitHint'.tr,
                      icon: Icons.straighten_rounded,
                    ),
                  ),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: PremiumField(
                      controller: controller.budgetMinCtrl,
                      label: 'buyer.requests.create.minBudgetLabel'.tr,
                      hint: 'ETB',
                      icon: Icons.south_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PremiumField(
                      controller: controller.budgetMaxCtrl,
                      label: 'buyer.requests.create.maxBudgetLabel'.tr,
                      hint: 'ETB',
                      icon: Icons.north_rounded,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _Section(
            title: 'buyer.common.delivery'.tr,
            icon: Icons.local_shipping_outlined,
            children: [
              PremiumField(
                controller: controller.deliveryCityCtrl,
                label: 'buyer.requests.field.deliveryCity'.tr,
                icon: Icons.location_city_rounded,
                textInputAction: TextInputAction.next,
                validator: controller.validateCity,
              ),
              PremiumField(
                controller: controller.deliveryAddressCtrl,
                label: 'buyer.requests.create.deliveryAddressLabel'.tr,
                icon: Icons.home_outlined,
                maxLines: 2,
                keyboardType: TextInputType.multiline,
              ),
              ProGrid2(
                gap: 10,
                children: [
                  ProDateTile(
                    label: 'buyer.requests.create.preferredDelivery'.tr,
                    value: controller.requiredDeliveryDate.value == null
                        ? 'buyer.requests.create.notSet'.tr
                        : Formatters.date(controller.requiredDeliveryDate.value),
                    icon: Icons.event_available_outlined,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                        initialDate: controller.requiredDeliveryDate.value ??
                            DateTime.now().add(const Duration(days: 30)),
                      );
                      controller.pickDeliveryDate(picked);
                    },
                  ),
                  ProDateTile(
                    label: 'buyer.requests.field.offersUntil'.tr,
                    value: Formatters.date(controller.expiresAt.value),
                    icon: Icons.timer_outlined,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        initialDate: controller.expiresAt.value,
                      );
                      controller.pickExpiry(picked);
                    },
                  ),
                ],
              ),
            ],
          ),
          _Section(
            title: 'buyer.requests.create.sectionQualityWarranty'.tr,
            icon: Icons.verified_outlined,
            children: [
              ProSwitchTile(
                title: 'buyer.requests.create.warrantyRequired'.tr,
                subtitle: 'buyer.requests.create.warrantyRequiredSubtitle'.tr,
                icon: Icons.shield_outlined,
                value: controller.warrantyRequired.value,
                onChanged: controller.toggleWarranty,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: controller.warrantyRequired.value
                    ? PremiumField(
                  controller: controller.warrantyDetailsCtrl,
                  label: 'buyer.requests.create.warrantyDetailsLabel'.tr,
                  icon: Icons.assignment_outlined,
                )
                    : const SizedBox(width: double.infinity),
              ),
              PremiumField(
                controller: controller.qualityCtrl,
                label: 'buyer.requests.create.qualityLabel'.tr,
                icon: Icons.high_quality_outlined,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              PremiumField(
                controller: controller.instructionsCtrl,
                label: 'buyer.requests.create.instructionsLabel'.tr,
                icon: Icons.info_outline_rounded,
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
            ],
          ),
          _Section(
            title: 'buyer.requests.create.sectionImages'.tr,
            icon: Icons.photo_library_outlined,
            children: [
              AppImagePicker(
                files: controller.images.toList(),
                onAdd: controller.addImage,
                onRemove: controller.removeImage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });
  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProSectionTitle(title, icon: icon),
          const SizedBox(height: 16),
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            children[i],
          ],
        ],
      ),
    );
  }
}