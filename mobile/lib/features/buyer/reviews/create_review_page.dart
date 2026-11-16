import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../auth/widgets/premium_button.dart';
import '../../auth/widgets/premium_field.dart';
import 'create_review_controller.dart';

class CreateReviewPage extends GetView<CreateReviewController> {
  const CreateReviewPage({super.key});

  static String _label(int r) => switch (r) {
    0 => 'buyer.reviews.tapStar'.tr,
    1 => 'buyer.reviews.poor'.tr,
    2 => 'buyer.reviews.fair'.tr,
    3 => 'buyer.reviews.good'.tr,
    4 => 'buyer.reviews.veryGood'.tr,
    _ => 'buyer.reviews.excellent'.tr,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ProPage(
      showBack: true,
      eyebrow: 'buyer.reviews.eyebrow'.tr,
      title: 'buyer.reviews.title'.tr,
      subtitle: 'buyer.reviews.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.star_rounded,
        satellites: [
          Icons.thumb_up_alt_outlined,
          Icons.chat_bubble_outline_rounded,
          Icons.verified_outlined,
        ],
      ),
      bottomBar: Obx(
            () => ProBottomBar(children: [
          PremiumButton(
            label: 'buyer.reviews.submit'.tr,
            icon: Icons.send_rounded,
            loading: controller.submitting.value,
            onPressed: controller.submit,
          ),
        ]),
      ),
      body: ProStagger(
        gap: 18,
        children: [
          ProCard(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Obx(() {
              final r = controller.rating.value;
              return Column(
                children: [
                  Text('buyer.reviews.howWasExperience'.tr,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 18),
                  FittedBox(
                    child: ProStarRating(
                      rating: r,
                      size: 46,
                      onChanged: controller.setRating,
                    ),
                  ),
                  const SizedBox(height: 14),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (c, a) => FadeTransition(
                      opacity: a,
                      child: SlideTransition(
                        position: Tween(
                            begin: const Offset(0, .3), end: Offset.zero)
                            .animate(a),
                        child: c,
                      ),
                    ),
                    child: Text(
                      _label(r.clamp(0, 5)),
                      key: ValueKey(r),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: r == 0
                            ? scheme.onSurface.withValues(alpha: .5)
                            : scheme.primary,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          PremiumField(
            controller: controller.commentCtrl,
            label: 'buyer.reviews.commentOptional'.tr,
            icon: Icons.chat_bubble_outline_rounded,
            maxLines: 4,
            keyboardType: TextInputType.multiline,
          ),
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('buyer.reviews.rateDetails'.tr,
                    icon: Icons.tune_rounded),
                const SizedBox(height: 14),
                _RateRow(
                  icon: Icons.forum_outlined,
                  label: 'buyer.reviews.communication'.tr,
                  child: Obx(() => ProStarRating(
                    rating: controller.communication.value,
                    onChanged: controller.setComm,
                    size: 26,
                  )),
                ),
                const Divider(height: 24),
                _RateRow(
                  icon: Icons.local_shipping_outlined,
                  label: 'buyer.reviews.delivery'.tr,
                  child: Obx(() => ProStarRating(
                    rating: controller.delivery.value,
                    onChanged: controller.setDel,
                    size: 26,
                  )),
                ),
                const Divider(height: 24),
                _RateRow(
                  icon: Icons.high_quality_outlined,
                  label: 'buyer.reviews.quality'.tr,
                  child: Obx(() => ProStarRating(
                    rating: controller.quality.value,
                    onChanged: controller.setQual,
                    size: 26,
                  )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RateRow extends StatelessWidget {
  const _RateRow({required this.icon, required this.label, required this.child});
  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: scheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        FittedBox(child: child),
      ],
    );
  }
}