import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../buyer/requests/widgets/request_image.dart';
import 'browse_requests_controller.dart';

class BrowseRequestsPage extends GetView<BrowseRequestsController> {
  const BrowseRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProPage(
      eyebrow: 'importer.browse.eyebrow'.tr,
      title: 'importer.browse.title'.tr,
      subtitle: 'importer.browse.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.travel_explore_rounded,
        satellites: [
          Icons.inventory_2_outlined,
          Icons.local_offer_outlined,
          Icons.flight_takeoff_rounded,
        ],
      ),
      onRefresh: controller.refresh,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProSearchField(
            hint: 'importer.browse.searchHint'.tr,
            onChanged: controller.setSearch,
            onSubmitted: (_) => controller.load(refresh: true),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                _sortChip('importer.browse.sort.newest'.tr, 'newest',
                    Icons.fiber_new_rounded),
                const SizedBox(width: 8),
                _sortChip(
                    'importer.browse.sort.expiringSoon'.tr,
                    'expiring_soon',
                    Icons.timer_outlined),
                const SizedBox(width: 8),
                _sortChip(
                    'importer.browse.sort.highestBudget'.tr,
                    'highest_budget',
                    Icons.trending_up_rounded),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => ProStateSwitcher(child: _body(context))),
        ],
      ),
    );
  }

  Widget _sortChip(String label, String key, IconData icon) {
    return Obx(
          () => ProSelectChip(
        label: label,
        icon: icon,
        selected: controller.sort.value == key,
        onTap: () => controller.setSort(key),
      ),
    );
  }

  Widget _body(BuildContext context) {
    if (controller.loading.value && controller.items.isEmpty) {
      return const ProSkeletonList(
          key: ValueKey('loading'), count: 5, itemHeight: 120);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.refresh,
      );
    }
    if (controller.items.isEmpty) {
      return ProEmptyState(
        key: const ValueKey('empty'),
        title: 'importer.browse.emptyTitle'.tr,
        description: 'importer.browse.emptyBody'.tr,
        icon: Icons.search_off_rounded,
        satellites: const [
          Icons.search_rounded,
          Icons.tune_rounded,
          Icons.inventory_2_outlined,
        ],
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProStagger(
      key: ValueKey('items-${controller.sort.value}'),
      gap: 12,
      children: [
        for (final r in controller.items)
          ProCard(
            onTap: () => controller.openDetail(r),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProductThumb(
                      url: imageUrlFor(r),
                      icon: Icons.inventory_2_outlined,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        r.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ProPill(
                      label: 'importer.browse.quotesCount'
                          .trParams({'count': '${r.quotationsCount}'}),
                      tone: AppBadgeTone.purple,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _Meta(Icons.place_outlined, r.deliveryCity),
                    _Meta(Icons.numbers_rounded,
                        '${r.quantity} ${r.unitOfMeasurement}'),
                    _Meta(Icons.schedule_rounded,
                        'importer.browse.expires'.trParams(
                            {'date': Formatters.date(r.expiresAt)})),
                  ],
                ),
                if (r.quotationsCount == 0) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded,
                          size: 15, color: scheme.primary),
                      const SizedBox(width: 6),
                      Text(
                        'importer.browse.beFirstToQuote'.tr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.onSurface.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Text(label,
              style:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}