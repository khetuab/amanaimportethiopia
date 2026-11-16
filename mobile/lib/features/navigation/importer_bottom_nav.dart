import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'floating_nav_bar.dart';

class ImporterBottomNav extends StatelessWidget {
  const ImporterBottomNav({
    super.key,
    required this.currentIndex,
    required this.onIndex,
  });

  final int currentIndex;
  final ValueChanged<int> onIndex;

  @override
  Widget build(BuildContext context) {
    return FloatingNavBar(
      currentIndex: currentIndex,
      onIndex: onIndex,
      items: [
        NavItem(
          icon: Icons.space_dashboard_outlined,
          selectedIcon: Icons.space_dashboard_rounded,
          label: 'nav.dashboard'.tr,
        ),
        NavItem(
          icon: Icons.search_outlined,
          selectedIcon: Icons.search_rounded,
          label: 'nav.browse'.tr,
        ),
        NavItem(
          icon: Icons.price_check_outlined,
          selectedIcon: Icons.price_check_rounded,
          label: 'nav.quotes'.tr,
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long_rounded,
          label: 'nav.orders'.tr,
        ),
        NavItem(
          icon: Icons.school_outlined,
          selectedIcon: Icons.school_rounded,
          label: 'nav.guide'.tr,
        ),
      ],
    );
  }
}