import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../widgets/request_card.dart';
import 'my_requests_controller.dart';

class MyRequestsPage extends GetView<MyRequestsController> {
  const MyRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProPage(
      eyebrow: 'nav.requests'.tr,
      title: 'buyer.requests.list.title'.tr,
      subtitle: 'buyer.requests.list.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.request_quote_rounded,
        satellites: [
          Icons.smartphone_rounded,
          Icons.local_shipping_outlined,
          Icons.price_check_rounded,
        ],
      ),
      onRefresh: controller.refresh,
      fab: ProFab(
        label: 'buyer.requests.newRequest'.tr,
        icon: Icons.add_rounded,
        onTap: controller.goToCreate,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final filters = controller.filters;
            final selected = controller.filter.value;
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = filters[i];
                  return ProSelectChip(
                    label: _label(f),
                    selected: selected == f,
                    onTap: () => controller.setFilter(f),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 20),
          Obx(() => ProStateSwitcher(child: _body())),
        ],
      ),
    );
  }

  Widget _body() {
    if (controller.loading.value && controller.requests.isEmpty) {
      return const ProSkeletonList(
          key: ValueKey('loading'), count: 4, itemHeight: 120);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.refresh,
      );
    }
    if (controller.requests.isEmpty) {
      return ProEmptyState(
        key: const ValueKey('empty'),
        title: 'buyer.requests.list.emptyTitle'.tr,
        description: 'buyer.requests.list.emptyDescription'.tr,
        icon: Icons.request_quote_outlined,
        satellites: const [
          Icons.smartphone_rounded,
          Icons.local_shipping_outlined,
          Icons.verified_outlined,
        ],
        actionLabel: 'buyer.requests.createAction'.tr,
        onAction: controller.goToCreate,
      );
    }
    return ProStagger(
      key: ValueKey('requests-${controller.filter.value}'),
      gap: 12,
      children: [
        for (final r in controller.requests)
          RequestCard(request: r, onTap: () => controller.openDetail(r)),
      ],
    );
  }

  static String _label(String key) {
    switch (key) {
      case 'all':
        return 'common.all'.tr;
      case 'draft':
        return 'status.draft'.tr;
      case 'published':
        return 'status.published'.tr;
      case 'receiving_offers':
        return 'buyer.requests.list.filterOffers'.tr;
      case 'offer_selected':
        return 'buyer.requests.list.filterSelected'.tr;
      case 'fulfilled':
        return 'status.fulfilled'.tr;
      default:
        return key;
    }
  }
}