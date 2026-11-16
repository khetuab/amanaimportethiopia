import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../widgets/quotation_card.dart';
import 'compare_quotations_controller.dart';

class CompareQuotationsPage extends GetView<CompareQuotationsController> {
  const CompareQuotationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final qs = controller.quotations;
      final loading = controller.loading.value;
      final error = controller.error.value;

      return ProPage(
        showBack: true,
        eyebrow: 'buyer.quotations.compare.eyebrow'.tr,
        title: 'nav.quotations'.tr,
        subtitle: (!loading && error == null && qs.isNotEmpty)
            ? (qs.length == 1
                ? 'buyer.quotations.compare.offerCountSubtitle'
                    .trParams({'count': '${qs.length}'})
                : 'buyer.quotations.compare.offersCountSubtitle'
                    .trParams({'count': '${qs.length}'}))
            : 'buyer.quotations.compare.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.balance_rounded,
          satellites: [
            Icons.verified_outlined,
            Icons.schedule_rounded,
            Icons.star_rounded,
          ],
        ),
        onRefresh: controller.load,
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 3, itemHeight: 170)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : qs.isEmpty
              ? ProEmptyState(
            key: const ValueKey('empty'),
            title: 'buyer.quotations.compare.emptyTitle'.tr,
            description:
            'buyer.quotations.compare.emptyDescription'.tr,
            icon: Icons.hourglass_top_rounded,
            satellites: [
              Icons.local_shipping_outlined,
              Icons.verified_outlined,
              Icons.price_check_rounded,
            ],
          )
              : _list(qs),
        ),
      );
    });
  }

  Widget _list(List qs) {
    final lowest = qs
        .map((q) => asDouble(q.totalPriceETB))
        .reduce((a, b) => math.min(a, b));
    return ProStagger(
      key: const ValueKey('data'),
      gap: 14,
      children: [
        for (final q in qs)
          QuotationCard(
            quotation: q,
            recommended: controller.isLowest(q),
            deltaFromBest: asDouble(q.totalPriceETB) - lowest,
            onTap: () => controller.openDetail(q),
          ),
      ],
    );
  }
}