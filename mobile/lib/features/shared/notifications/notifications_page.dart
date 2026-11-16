import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import 'notifications_controller.dart';

class NotificationsPage extends GetView<NotificationsController> {
  const NotificationsPage({super.key});

  static IconData _icon(String text) {
    final s = text.toLowerCase();
    if (s.contains('quot') || s.contains('offer')) {
      return Icons.price_check_rounded;
    }
    if (s.contains('payment')) return Icons.payments_outlined;
    if (s.contains('dispute')) return Icons.gavel_rounded;
    if (s.contains('message') || s.contains('chat')) {
      return Icons.forum_outlined;
    }
    if (s.contains('verif') || s.contains('approved')) {
      return Icons.verified_user_outlined;
    }
    if (s.contains('ship') || s.contains('deliver') || s.contains('transit')) {
      return Icons.local_shipping_outlined;
    }
    if (s.contains('order')) return Icons.receipt_long_outlined;
    if (s.contains('request')) return Icons.request_quote_outlined;
    return Icons.notifications_none_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unread = controller.unread.value;
      return ProPage(
        showBack: true,
        eyebrow: 'notifications.eyebrow'.tr,
        title: 'nav.notifications'.tr,
        subtitle: unread > 0
            ? 'common.unreadCount'.trParams({'count': unread.toString()})
            : 'notifications.caughtUp'.tr,
        art: const HeroArt(
          icon: Icons.notifications_active_rounded,
          satellites: [
            Icons.receipt_long_outlined,
            Icons.forum_outlined,
            Icons.local_shipping_outlined,
          ],
        ),
        actions: [
          if (unread > 0) _MarkAll(onTap: controller.markAllRead),
        ],
        onRefresh: controller.load,
        body: ProStateSwitcher(child: _body(context)),
      );
    });
  }

  Widget _body(BuildContext context) {
    if (controller.loading.value) {
      return const ProSkeletonList(key: ValueKey('loading'), itemHeight: 92);
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
        title: 'notifications.emptyTitle'.tr,
        description: 'notifications.emptyBody'.tr,
        icon: Icons.notifications_none_rounded,
        satellites: [
          Icons.receipt_long_outlined,
          Icons.forum_outlined,
          Icons.local_shipping_outlined,
        ],
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ProStagger(
      key: const ValueKey('data'),
      gap: 10,
      children: [
        for (final n in controller.items)
          ProCard(
            highlight: !n.isRead,
            onTap: () => controller.openTarget(n),
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: n.isRead
                        ? null
                        : LinearGradient(colors: [
                      scheme.primary,
                      Color.lerp(scheme.primary, Colors.black, .2)!,
                    ]),
                    color: n.isRead
                        ? scheme.onSurface.withValues(alpha: .07)
                        : null,
                  ),
                  child: Icon(
                    _icon('${n.title} ${n.body}'),
                    size: 22,
                    color: n.isRead
                        ? scheme.onSurface.withValues(alpha: .5)
                        : scheme.onPrimary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: n.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!n.isRead)
                            Container(
                              width: 9,
                              height: 9,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: scheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        n.body,
                        style: theme.textTheme.bodySmall?.copyWith(
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 13,
                              color: scheme.onSurface.withValues(alpha: .45)),
                          const SizedBox(width: 4),
                          Text(Formatters.relative(n.createdAt),
                              style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MarkAll extends StatelessWidget {
  const _MarkAll({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .14),
      shape: StadiumBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: .3)),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.done_all_rounded, size: 17, color: Colors.white),
              SizedBox(width: 6),
              Text(
                'notifications.markAllRead'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}