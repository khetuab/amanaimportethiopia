import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/core/widgets/pro/pro.dart';
import '../../../routes/app_routes.dart';
import '../../services/notifications_service.dart';
import 'pro_kit.dart';

class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final svc = Get.find<NotificationsService>();
    return Obx(() {
      final n = svc.unread.value;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          ProIconButton(
            icon: Icons.notifications_none_rounded,
            tooltip: 'nav.notifications'.tr,
            onTap: () => Get.toNamed(AppRoutes.notifications),
          ),
          if (n > 0)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: Text(
                  n > 99 ? '99+' : '$n',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}