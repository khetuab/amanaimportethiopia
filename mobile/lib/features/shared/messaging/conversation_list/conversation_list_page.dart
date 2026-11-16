import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import 'conversation_list_controller.dart';

class ConversationListPage extends GetView<ConversationListController> {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.items.fold<int>(
        0,
            (s, c) => s + (c.buyerUnreadCount + c.importerUnreadCount) as int,
      );
      return ProPage(
        showBack: true,
        eyebrow: 'messaging.conversations.eyebrow'.tr,
        title: 'nav.messages'.tr,
        subtitle: total > 0
            ? 'common.unreadCount'.trParams({'count': total.toString()})
            : 'messaging.conversations.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.forum_rounded,
          satellites: [
            Icons.receipt_long_outlined,
            Icons.support_agent_rounded,
            Icons.verified_outlined,
          ],
        ),
        onRefresh: controller.load,
        body: ProStateSwitcher(child: _body(context)),
      );
    });
  }

  Widget _body(BuildContext context) {
    if (controller.loading.value) {
      return const ProSkeletonList(key: ValueKey('loading'), itemHeight: 84);
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
        title: 'messaging.conversations.emptyTitle'.tr,
        description: 'messaging.conversations.emptyBody'.tr,
        icon: Icons.forum_outlined,
        satellites: [
          Icons.chat_bubble_outline_rounded,
          Icons.handshake_outlined,
          Icons.receipt_long_outlined,
        ],
      );
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return ProStagger(
      key: const ValueKey('data'),
      gap: 10,
      children: [
        for (final c in controller.items)
          Builder(builder: (_) {
            final unread = (c.buyerUnreadCount + c.importerUnreadCount) as int;
            return ProCard(
              highlight: unread > 0,
              onTap: () => controller.openChat(c),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AuthPalette.emeraldMid,
                          AuthPalette.emeraldDeep,
                        ],
                      ),
                    ),
                    child: const Icon(Icons.receipt_long_outlined,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.orderReference ?? 'messaging.chat.orderConversation'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight:
                            unread > 0 ? FontWeight.w800 : FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          c.lastMessagePreview ?? 'messaging.conversations.noMessages'.tr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: unread > 0
                                ? scheme.onSurface.withValues(alpha: .85)
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(Formatters.relative(c.lastMessageAt),
                          style: theme.textTheme.bodySmall),
                      const SizedBox(height: 6),
                      if (unread > 0)
                        Container(
                          constraints: const BoxConstraints(minWidth: 22),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: .4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            '$unread',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: scheme.onPrimary,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        )
                      else
                        Icon(Icons.done_all_rounded,
                            size: 16,
                            color: scheme.onSurface.withValues(alpha: .35)),
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