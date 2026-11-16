import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'floating_nav_bar.dart';

class BuyerBottomNav extends StatelessWidget {
  const BuyerBottomNav({
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
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'nav.home'.tr,
        ),
        NavItem(
          icon: Icons.request_quote_outlined,
          selectedIcon: Icons.request_quote_rounded,
          label: 'nav.requests'.tr,
        ),
        NavItem(
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long_rounded,
          label: 'nav.orders'.tr,
        ),
        NavItem(
          icon: Icons.person_outline,
          selectedIcon: Icons.person_rounded,
          label: 'nav.profile'.tr,
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