import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../chat/chat_controller.dart';

class ChatInput extends StatefulWidget {
  const ChatInput({super.key});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final ChatController c = Get.find<ChatController>();
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focused = _focus.hasFocus;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: focused
                        ? scheme.surface
                        : scheme.onSurface.withValues(alpha: .05),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: focused
                          ? scheme.primary
                          : theme.dividerColor.withValues(alpha: .6),
                      width: focused ? 1.6 : 1,
                    ),
                    boxShadow: [
                      if (focused)
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: .18),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                    ],
                  ),
                  child: TextField(
                    controller: c.bodyCtrl,
                    focusNode: _focus,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => c.send(),
                    decoration: InputDecoration(
                      hintText: 'messaging.chat.inputHint'.tr,
                      filled: false,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: c.bodyCtrl,
                builder: (_, v, __) => Obx(() {
                  final sending = c.sending.value;
                  final enabled = v.text.trim().isNotEmpty && !sending;
                  return GestureDetector(
                    onTap: enabled
                        ? () {
                      HapticFeedback.lightImpact();
                      c.send();
                    }
                        : null,
                    child: AnimatedScale(
                      scale: enabled ? 1 : .9,
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: enabled || sending
                              ? LinearGradient(colors: [
                            scheme.primary,
                            Color.lerp(scheme.primary, Colors.black, .2)!,
                          ])
                              : null,
                          color: enabled || sending
                              ? null
                              : scheme.onSurface.withValues(alpha: .12),
                          boxShadow: [
                            if (enabled)
                              BoxShadow(
                                color: scheme.primary.withValues(alpha: .4),
                                blurRadius: 14,
                                offset: const Offset(0, 6),
                              ),
                          ],
                        ),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: sending
                              ? Padding(
                            key: const ValueKey('spin'),
                            padding: const EdgeInsets.all(15),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.4,
                              color: scheme.onPrimary,
                            ),
                          )
                              : Icon(
                            Icons.send_rounded,
                            key: const ValueKey('send'),
                            color: enabled
                                ? scheme.onPrimary
                                : scheme.onSurface.withValues(alpha: .35),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}