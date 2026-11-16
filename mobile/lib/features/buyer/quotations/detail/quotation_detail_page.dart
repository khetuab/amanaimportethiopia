import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import 'quotation_detail_controller.dart';

class QuotationDetailPage extends GetView<QuotationDetailController> {
  const QuotationDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final q = controller.quotation.value;
      final loading = controller.loading.value;
      final error = controller.error.value;
      final ready = !loading && error == null && q != null;

      return ProPage(
        showBack: true,
        eyebrow: 'buyer.quotations.detail.eyebrow'.tr,
        title: q?.importerBusinessName ?? 'auth.role.importer'.tr,
        heroExtra: q == null
            ? null
            : ProCountUp(
          value: asDouble(q.totalPriceETB),
          format: (v) => Formatters.etb(v),
          style: const TextStyle(
            color: AuthPalette.mint,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
          ),
        ),
        art: const HeroArt(
          icon: Icons.price_check_rounded,
          satellites: [
            Icons.schedule_rounded,
            Icons.verified_outlined,
            Icons.shield_outlined,
          ],
        ),
        bottomBar: ready
            ? ProBottomBar(children: [
          PremiumButton(
            label: 'buyer.quotations.detail.acceptButton'.tr,
            icon: Icons.check_circle_outline_rounded,
            onPressed: controller.accept,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded,
                  size: 14,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: .55)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  'buyer.quotations.detail.contactNote'.tr,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ])
            : null,
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 3, itemHeight: 130)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : q == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : _content(context, q),
        ),
      );
    });
  }

  Widget _content(BuildContext context, dynamic q) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final costs = q.itemizedCosts as List;
    final sum = costs.fold<double>(0, (s, c) => s + asDouble(c.amountETB));
    final denom = sum > 0 ? sum : 1.0;

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        ProGrid2(children: [
          _FactTile(
            icon: Icons.schedule_rounded,
            label: 'buyer.common.delivery'.tr,
            value: 'buyer.quotations.detail.deliveryDays'
                .trParams({'days': '${q.estimatedDeliveryDays}'}),
          ),
          _FactTile(
            icon: Icons.verified_outlined,
            label: 'buyer.quotations.detail.conditionLabel'.tr,
            value: 'condition.${q.productCondition}'.tr,
          ),
          if (q.warrantyOffered != null)
            _FactTile(
              icon: Icons.shield_outlined,
              label: 'buyer.quotations.detail.warrantyLabel'.tr,
              value: q.warrantyOffered!,
            ),
          if (q.returnPolicy != null)
            _FactTile(
              icon: Icons.assignment_return_outlined,
              label: 'buyer.quotations.detail.returnPolicyLabel'.tr,
              value: q.returnPolicy!,
            ),
        ]),
        if (costs.isNotEmpty)
          ProCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProSectionTitle('buyer.quotations.detail.itemizedCosts'.tr,
                    icon: Icons.receipt_outlined),
                const SizedBox(height: 16),
                for (var i = 0; i < costs.length; i++)
                  Padding(
                    padding:
                    EdgeInsets.only(bottom: i == costs.length - 1 ? 0 : 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(costs[i].label,
                                  style: theme.textTheme.bodyMedium),
                            ),
                            Text(
                              Formatters.etb(costs[i].amountETB),
                              style: theme.textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: (asDouble(costs[i].amountETB) / denom)
                                  .clamp(0.0, 1.0),
                            ),
                            duration:
                            Duration(milliseconds: 700 + i * 120),
                            curve: Curves.easeOutCubic,
                            builder: (_, v, __) => LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              backgroundColor:
                              scheme.primary.withValues(alpha: .1),
                              valueColor:
                              AlwaysStoppedAnimation(scheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        if (q.notes != null && q.notes!.isNotEmpty)
          _TextBlock(
              title: 'buyer.quotations.detail.notes'.tr,
              icon: Icons.sticky_note_2_outlined,
              text: q.notes!),
        if (q.exclusions != null && q.exclusions!.isNotEmpty)
          ProCallout(
            icon: Icons.block_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('buyer.quotations.detail.exclusions'.tr,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(q.exclusions!, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
      ],
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: scheme.primary),
          ),
          const SizedBox(height: 12),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.title, required this.icon, required this.text});
  final String title;
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProSectionTitle(title, icon: icon),
          const SizedBox(height: 10),
          Text(text,
              style:
              Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
      ),
    );
  }
}