import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import 'shipment_tracking_controller.dart';

class ShipmentTrackingPage extends GetView<ShipmentTrackingController> {
  const ShipmentTrackingPage({super.key});

  static const _stages = [
    ('picked_up', 'tracking.stage.pickedUp', Icons.inventory_2_outlined),
    ('departed_origin', 'tracking.stage.departed', Icons.flight_takeoff_rounded),
    ('in_transit', 'tracking.stage.inTransit', Icons.public_rounded),
    ('customs', 'tracking.stage.customs', Icons.assignment_turned_in_outlined),
    ('arrived_destination', 'tracking.stage.arrived', Icons.home_rounded),
  ];

  static int _stageIndex(String s) => _stages.indexWhere((e) => e.$1 == s);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = controller.shipment.value;
      final events = s == null ? <dynamic>[] : List<dynamic>.from(s.events);
      events.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
      final latest = events.isEmpty ? null : events.first;

      return ProPage(
        showBack: true,
        eyebrow: 'tracking.eyebrow'.tr,
        title: 'tracking.title'.tr,
        heroExtra: latest == null
            ? null
            : HeroPill(
          label: Formatters.humanize(latest.stage),
          icon: Icons.my_location_rounded,
        ),
        subtitle: latest == null ? 'tracking.subtitle'.tr : null,
        art: const HeroArt(
          icon: Icons.local_shipping_rounded,
          satellites: [
            Icons.flight_takeoff_rounded,
            Icons.public_rounded,
            Icons.home_rounded,
          ],
        ),
        onRefresh: controller.load,
        body: ProStateSwitcher(child: _body(context, s, events)),
      );
    });
  }

  Widget _body(BuildContext context, dynamic s, List<dynamic> events) {
    if (controller.loading.value) {
      return const ProSkeletonList(
          key: ValueKey('loading'), count: 3, itemHeight: 120);
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }
    if (s == null || events.isEmpty) {
      return ProEmptyState(
        key: const ValueKey('empty'),
        title: 'tracking.emptyTitle'.tr,
        description: 'tracking.emptyBody'.tr,
        icon: Icons.local_shipping_outlined,
        satellites: [
          Icons.inventory_2_outlined,
          Icons.flight_takeoff_rounded,
          Icons.public_rounded,
        ],
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    var stage = -1;
    for (final e in events) {
      final i = _stageIndex(e.stage.toString());
      if (i > stage) stage = i;
    }

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        ProCard(
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.local_shipping_rounded,
                    color: scheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.carrier ?? 'tracking.defaultCarrier'.tr,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    if (s.trackingNumber != null) ...[
                      const SizedBox(height: 3),
                      Text('tracking.trackingNumber'
                              .trParams({'number': s.trackingNumber.toString()}),
                          style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              if (s.trackingNumber != null)
                IconButton(
                  tooltip: 'tracking.copyTooltip'.tr,
                  icon: Icon(Icons.copy_rounded,
                      size: 20, color: scheme.primary),
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: s.trackingNumber.toString()));
                    HapticFeedback.lightImpact();
                    Get.snackbar('tracking.copiedTitle'.tr,
                        'tracking.copiedBody'.tr);
                  },
                ),
            ],
          ),
        ),
        _RouteCard(stage: stage),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('tracking.updates'.tr,
                  icon: Icons.timeline_rounded),
              const SizedBox(height: 16),
              for (var i = 0; i < events.length; i++)
                _EventTile(
                  stage: events[i].stage.toString(),
                  description: events[i].description,
                  time: Formatters.relative(events[i].occurredAt),
                  latest: i == 0,
                  last: i == events.length - 1,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RouteCard extends StatelessWidget {
  const _RouteCard({required this.stage});
  final int stage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const stages = ShipmentTrackingPage._stages;
    final frac = stage < 0 ? 0.0 : stage / (stages.length - 1);

    return ProCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProSectionTitle(
            'tracking.journey'.tr,
            icon: Icons.route_rounded,
            trailing: Text(
              stage < 0 ? 'tracking.starting'.tr : '${stage + 1}/${stages.length}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, box) {
              const pad = 22.0;
              final w = box.maxWidth - pad * 2;
              double x(int i) => pad + w * i / (stages.length - 1);
              return SizedBox(
                height: 86,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Track.
                    Positioned(
                      left: pad,
                      width: w,
                      top: 21,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Stack(
                          children: [
                            Container(
                                color: scheme.primary.withValues(alpha: .15)),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: frac),
                              duration: const Duration(milliseconds: 1200),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: v,
                                child: Container(color: scheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    for (var i = 0; i < stages.length; i++)
                      Positioned(
                        left: x(i) - 36,
                        width: 72,
                        top: 0,
                        child: Column(
                          children: [
                            _Node(
                              icon: stages[i].$3,
                              done: i <= stage,
                              current: i == stage,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              stages[i].$2.tr,
                              maxLines: 1,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: i <= stage
                                    ? FontWeight.w800
                                    : FontWeight.w500,
                                color: scheme.onSurface.withValues(
                                    alpha: i <= stage ? .9 : .5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Node extends StatelessWidget {
  const _Node({required this.icon, required this.done, required this.current});
  final IconData icon;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final circle = Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? scheme.primary : scheme.surface,
        border: Border.all(
          color: done
              ? scheme.primary
              : scheme.onSurface.withValues(alpha: .2),
          width: 2,
        ),
      ),
      child: Icon(
        icon,
        size: 21,
        color: done ? scheme.onPrimary : scheme.onSurface.withValues(alpha: .4),
      ),
    );
    if (!current) return circle;
    return ProLooper(
      duration: const Duration(seconds: 2),
      builder: (_, t) => Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: .4 * (1 - t)),
              spreadRadius: 10 * t,
            ),
          ],
        ),
        child: circle,
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.stage,
    required this.description,
    required this.time,
    required this.latest,
    required this.last,
  });
  final String stage;
  final String? description;
  final String time;
  final bool latest;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final idx = ShipmentTrackingPage._stageIndex(stage);
    final icon = idx >= 0
        ? ShipmentTrackingPage._stages[idx].$3
        : Icons.radio_button_checked_rounded;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: latest
                        ? scheme.primary
                        : scheme.primary.withValues(alpha: .12),
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: latest ? scheme.onPrimary : scheme.primary,
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.primary.withValues(alpha: .2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18, top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.humanize(stage),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight:
                            latest ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(time, style: theme.textTheme.bodySmall),
                    ],
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 3),
                    Text(description!,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(height: 1.4)),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}