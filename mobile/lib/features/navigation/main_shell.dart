import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/network/dio_client.dart';
import '../../core/services/auth_service.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/order_repository.dart';
import '../../data/repositories/quotation_repository.dart';
import '../../data/repositories/request_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../guide/guide_page.dart';
import '../buyer/home/buyer_home_page.dart';
import '../buyer/orders/list/buyer_orders_controller.dart';
import '../buyer/orders/list/buyer_orders_page.dart';
import '../buyer/requests/list/my_requests_controller.dart';
import '../buyer/requests/list/my_requests_page.dart';
import '../importer/browse_requests/browse_requests_controller.dart';
import '../importer/browse_requests/browse_requests_page.dart';
import '../importer/dashboard/importer_dashboard_page.dart';
import '../importer/orders/list/importer_orders_controller.dart';
import '../importer/orders/list/importer_orders_page.dart';
import '../importer/quotations/list/my_quotations_controller.dart';
import '../importer/quotations/list/my_quotations_page.dart';
import '../shared/profile/profile_controller.dart';
import '../shared/profile/profile_page.dart';
import 'buyer_bottom_nav.dart';
import 'importer_bottom_nav.dart';

enum MainShellRole { buyer, importer }

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.role});
  final MainShellRole role;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _registerTabControllers();
  }

  void _registerTabControllers() {
    final dio = Get.find<DioClient>();
    final auth = Get.find<AuthService>();

    if (widget.role == MainShellRole.buyer) {
      if (!Get.isRegistered<MyRequestsController>()) {
        Get.put(MyRequestsController(RequestRepository(dio)));
      }
      if (!Get.isRegistered<BuyerOrdersController>()) {
        Get.put(BuyerOrdersController(OrderRepository(dio)));
      }
      if (!Get.isRegistered<ProfileController>()) {
        Get.put(ProfileController(auth, UserRepository(dio)));
      }
    } else {
      if (!Get.isRegistered<BrowseRequestsController>()) {
        Get.put(BrowseRequestsController(
          auth,
          CategoryRepository(dio),
          RequestRepository(dio),
        ));
      }
      if (!Get.isRegistered<MyQuotationsController>()) {
        Get.put(MyQuotationsController(QuotationRepository(dio)));
      }
      if (!Get.isRegistered<ImporterOrdersController>()) {
        Get.put(ImporterOrdersController(OrderRepository(dio)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBuyer = widget.role == MainShellRole.buyer;

    final pages = isBuyer
        ? const <Widget>[
      BuyerHomePage(),
      MyRequestsPage(),
      BuyerOrdersPage(),
      ProfilePage(),
      GuideTab(isBuyer: true),
    ]
        : const <Widget>[
      ImporterDashboardPage(),
      BrowseRequestsPage(),
      MyQuotationsPage(),
      ImporterOrdersPage(),
      GuideTab(isBuyer: false),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          for (var i = 0; i < pages.length; i++)
            _TabFade(active: i == _index, child: pages[i]),
        ],
      ),
      bottomNavigationBar: isBuyer
          ? BuyerBottomNav(
        currentIndex: _index,
        onIndex: (i) => setState(() => _index = i),
      )
          : ImporterBottomNav(
        currentIndex: _index,
        onIndex: (i) => setState(() => _index = i),
      ),
    );
  }
}

/// Replays a short fade + rise whenever its tab becomes active.
class _TabFade extends StatefulWidget {
  const _TabFade({required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  State<_TabFade> createState() => _TabFadeState();
}

class _TabFadeState extends State<_TabFade>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 340),
    value: widget.active ? 1 : 0,
  );
  late final Animation<double> _curve =
  CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(covariant _TabFade old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TickerMode mutes the tickers of hidden tabs so looping guide
    // animations do not burn battery while another tab is open.
    return TickerMode(
      enabled: widget.active,
      child: FadeTransition(
        opacity: _curve,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .02), end: Offset.zero)
              .animate(_curve),
          child: widget.child,
        ),
      ),
    );
  }
}