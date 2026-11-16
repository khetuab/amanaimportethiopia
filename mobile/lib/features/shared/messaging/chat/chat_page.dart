import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_bubble.dart';
import 'chat_controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Column(
          children: [
            _ChatHeader(
              title: controller.conversation.orderReference ??
                  'messaging.chat.fallbackTitle'.tr,
            ),
            Expanded(
              child: Obx(
                    () => AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _messages(context),
                ),
              ),
            ),
            const ChatInput(),
          ],
        ),
      ),
    );
  }

  Widget _messages(BuildContext context) {
    if (controller.loading.value) {
      return const Padding(
        key: ValueKey('loading'),
        padding: EdgeInsets.all(20),
        child: ProSkeletonList(count: 4, itemHeight: 64),
      );
    }
    if (controller.error.value != null) {
      return SingleChildScrollView(
        key: const ValueKey('error'),
        padding: const EdgeInsets.all(20),
        child: ProErrorState(
          message: controller.error.value!,
          onRetry: controller.load,
        ),
      );
    }
    if (controller.messages.isEmpty) {
      return Center(
        key: const ValueKey('empty'),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ProEmptyState(
            title: 'messaging.chat.emptyTitle'.tr,
            description: 'messaging.chat.emptyBody'.tr,
            icon: Icons.chat_bubble_outline_rounded,
            satellites: [
              Icons.waving_hand_outlined,
              Icons.handshake_outlined,
              Icons.local_shipping_outlined,
            ],
          ),
        ),
      );
    }

    final scheme = Theme.of(context).colorScheme;
    return ListView.builder(
      key: const ValueKey('list'),
      controller: controller.scrollCtrl,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: controller.messages.length,
      itemBuilder: (_, i) {
        final m = controller.messages[i];
        final mine = m.senderId == controller.myUserId;
        final showStamp = i == 0 ||
            controller.messages[i - 1].createdAt
                .difference(m.createdAt)
                .inMinutes
                .abs() >
                15;
        return Column(
          crossAxisAlignment:
          mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (showStamp)
              Center(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: scheme.onSurface.withValues(alpha: .06),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    Formatters.relative(m.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            MessageBubble(message: m, mine: mine),
          ],
        );
      },
    );
  }
}

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(14, top + 10, 14, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AuthPalette.emeraldMid,
            AuthPalette.emerald,
            AuthPalette.emeraldDeep,
          ],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          ProIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            tooltip: 'common.back'.tr,
            onTap: Get.back,
          ),
          const SizedBox(width: 12),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [AuthPalette.mint, AuthPalette.emeraldMid],
              ),
              boxShadow: [
                BoxShadow(
                  color: AuthPalette.mint.withValues(alpha: .4),
                  blurRadius: 14,
                ),
              ],
            ),
            child: const Icon(Icons.receipt_long_outlined,
                color: AuthPalette.emeraldDeep),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'messaging.chat.orderConversation'.tr,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: .75),
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}