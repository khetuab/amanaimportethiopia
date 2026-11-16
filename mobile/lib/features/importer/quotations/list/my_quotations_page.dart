import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../buyer/requests/widgets/order_image.dart';
import 'my_quotations_controller.dart';

/// Maps a raw status value to its localized display label, falling back to
/// the plain humanized value when no translation exists for the status.
String _statusLabel(String s) {
  if (s.isEmpty) return '—';
  final k = 'status.${s.toLowerCase()}';
  final v = k.tr;
  return v == k ? Formatters.humanize(s) : v;
}

class MyQuotationsPage extends GetView<MyQuotationsController> {
  const MyQuotationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ProPage(
      eyebrow: 'importer.quotations.eyebrow'.tr,
      title: 'importer.quotations.title'.tr,
      subtitle: 'importer.quotations.subtitle'.tr,
      art: const HeroArt(
        icon: Icons.price_check_rounded,
        satellites: [
          Icons.send_rounded,
          Icons.handshake_outlined,
          Icons.schedule_rounded,
        ],
      ),
      onRefresh: controller.load,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            final selected = controller.filter.value;
            return SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: MyQuotationsController.filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final f = MyQuotationsController.filters[i];
                  return ProSelectChip(
                    label: f == 'all' ? 'common.all'.tr : _statusLabel(f),
                    selected: selected == f,
                    onTap: () => controller.setFilter(f),
                  );
                },
              ),
            );
          }),
          const SizedBox(height: 20),
          Obx(() => ProStateSwitcher(child: _body(context))),
        ],
      ),
    );
  }

  static IconData _icon(String s) => switch (s) {
    'accepted' => Icons.handshake_rounded,
    'rejected' => Icons.thumb_down_alt_outlined,
    'withdrawn' => Icons.undo_rounded,
    'expired' => Icons.timer_off_outlined,
    _ => Icons.send_rounded,
  };

  Widget _body(BuildContext context) {
    if (controller.loading.value) {
      return const ProSkeletonList(key: ValueKey('loading'), itemHeight: 110);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }
    if (controller.items.isEmpty) {
      return ProEmptyState(
        key: const ValueKey('empty'),
        title: 'importer.quotations.emptyTitle'.tr,
        description: 'importer.quotations.emptyBody'.tr,
        icon: Icons.price_check_outlined,
        satellites: const [
          Icons.search_rounded,
          Icons.send_rounded,
          Icons.handshake_outlined,
        ],
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProStagger(
      key: ValueKey('quotes-${controller.filter.value}'),
      gap: 12,
      children: [
        for (final q in controller.items)
          Builder(builder: (_) {
            final editable = ['submitted', 'updated'].contains(q.status);
            final tone = switch (q.status) {
              'accepted' => AppBadgeTone.green,
              'rejected' => AppBadgeTone.red,
              'withdrawn' => AppBadgeTone.slate,
              'expired' => AppBadgeTone.amber,
              _ => AppBadgeTone.blue,
            };
            return ProCard(
              onTap: editable ? () => controller.openEdit(q) : null,
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      RequestIdThumb(
                        requestId: q.requestId,
                        icon: _icon(q.status),
                        size: 48,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              q.referenceNumber,
                              style: theme.textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            ProPill(
                                label: _statusLabel(q.status),
                                tone: tone),
                          ],
                        ),
                      ),
                      Text(
                        Formatters.etb(q.totalPriceETB),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Divider(
                      height: 1,
                      color: theme.dividerColor.withValues(alpha: .5)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(Icons.schedule_rounded,
                          size: 14,
                          color: scheme.onSurface.withValues(alpha: .5)),
                      const SizedBox(width: 6),
                      Text(
                        'importer.quotations.validUntilDate'.trParams(
                            {'date': Formatters.date(q.quotationValidUntil)}),
                        style: theme.textTheme.bodySmall,
                      ),
                      const Spacer(),
                      if (editable) ...[
                        Icon(Icons.edit_outlined,
                            size: 14, color: scheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          'importer.quotations.tapToEdit'.tr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}