import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, required this.mine});
  final MessageModel message;
  final bool mine;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fresh = DateTime.now().difference(message.createdAt).inSeconds.abs() < 10;

    Widget bubble;

    // Admin messages: a distinct third role, full width.
    if (message.senderRole == 'admin') {
      bubble = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary.withValues(alpha: .14),
                scheme.primary.withValues(alpha: .05),
              ],
            ),
            border: Border.all(color: scheme.primary.withValues(alpha: .4)),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_rounded,
                        size: 14, color: scheme.onPrimary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'messaging.bubble.support'.tr,
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                message.body,
                style: TextStyle(color: scheme.onSurface, height: 1.4),
              ),
            ],
          ),
        ),
      );
    } else {
      bubble = Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.74,
          ),
          decoration: BoxDecoration(
            gradient: mine
                ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, Colors.black, .2)!,
              ],
            )
                : null,
            color: mine ? null : scheme.surface,
            border: mine
                ? null
                : Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: .7)),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(mine ? 18 : 4),
              bottomRight: Radius.circular(mine ? 4 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: mine ? .14 : .05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message.body,
            style: TextStyle(
              color: mine ? scheme.onPrimary : scheme.onSurface,
              height: 1.4,
            ),
          ),
        ),
      );
    }

    if (!fresh) return bubble;
    return bubble
        .animate()
        .fadeIn(duration: 250.ms)
        .slideX(
      begin: message.senderRole == 'admin' ? 0 : (mine ? .2 : -.2),
      end: 0,
      curve: Curves.easeOutCubic,
    )
        .scaleXY(begin: .94, end: 1, duration: 250.ms);
  }
}