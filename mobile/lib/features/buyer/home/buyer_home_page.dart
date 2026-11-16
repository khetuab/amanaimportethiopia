import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:mobile/routes/app_routes.dart';
import '../../../core/constants/auth_palette.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/pro/logout_dialog.dart';
import '../../../core/widgets/pro/notification_bell.dart';
import '../../../core/widgets/pro/pro.dart';
import '../../../core/widgets/pro/pro_kit.dart';
import '../../../core/widgets/pro/pro_states.dart';
import '../../../data/models/category_model.dart';
import '../../auth/widgets/premium_button.dart';
import '../requests/widgets/request_image.dart';
import 'buyer_home_controller.dart';

class BuyerHomePage extends GetView<BuyerHomeController> {
  const BuyerHomePage({super.key});

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'buyer.home.greetingMorning'.tr;
    if (h < 17) return 'buyer.home.greetingAfternoon'.tr;
    return 'buyer.home.greetingEvening'.tr;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
          () => ProPage(
        heroHeight: 236,
        eyebrow: _greeting(),
        title: controller.userName,
        subtitle: 'buyer.home.subtitle'.tr,
        art: const HeroArt(
          icon: Icons.public_rounded,
          satellites: [
            Icons.inventory_2_outlined,
            Icons.flight_takeoff_rounded,
            Icons.directions_boat_outlined,
          ],
        ),
        actions: [
          const NotificationBell(),
          const SizedBox(width: 8),
          ProIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'buyer.home.signOut'.tr,
            onTap: () => LogoutDialog.confirm(controller.logout),
          ),
        ],
        onRefresh: controller.load,
        body: ProStateSwitcher(child: _content(context)),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final theme = Theme.of(context);

    if (controller.loading.value) {
      return const Column(
        key: ValueKey('loading'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ProSkeleton(height: 190, radius: 28),
          SizedBox(height: 24),
          ProSkeleton(height: 28, radius: 10),
          SizedBox(height: 12),
          ProSkeleton(height: 44, radius: 22),
          SizedBox(height: 24),
          ProSkeletonList(count: 3, itemHeight: 78),
        ],
      );
    }
    if (controller.error.value != null) {
      return ProErrorState(
        key: const ValueKey('error'),
        message: controller.error.value!,
        onRetry: controller.load,
      );
    }

    final chips = controller.categories
        .map((c) => _CategoryChip(name: c.name))
        .toList();

    return ProStagger(
      key: const ValueKey('data'),
      gap: 26,
      children: [
        const _CreateCard(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProSectionTitle('buyer.home.browseByCategory'.tr,
                icon: Icons.grid_view_rounded),
            const SizedBox(height: 14),
            CategoryGrid(categories: controller.categories.toList()),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProSectionTitle('buyer.home.recentRequests'.tr,
                icon: Icons.history_rounded),
            const SizedBox(height: 14),
            if (controller.recentRequests.isEmpty)
              ProEmptyState(
                title: 'buyer.home.emptyRequestsTitle'.tr,
                description:
                'buyer.home.emptyRequestsDescription'.tr,
                icon: Icons.request_quote_outlined,
                satellites: [
                  Icons.smartphone_rounded,
                  Icons.local_shipping_outlined,
                  Icons.verified_outlined,
                ],
              )
            else
              Column(
                children: [
                  for (final r in controller.recentRequests)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ProCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            ProductThumb(
                              url: imageUrlFor(r),
                              icon: Icons.request_quote_outlined,
                              size: 56,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    r.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.place_outlined,
                                          size: 14,
                                          color: theme.colorScheme.onSurface
                                              .withValues(alpha: .55)),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          '${r.deliveryCity} · ${Formatters.relative(r.createdAt)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

IconData _catIcon(String n) {
  final s = n.toLowerCase();
  if (s.contains('phone') || s.contains('mobile') || s.contains('electronic')) {
    return Icons.smartphone_rounded;
  }
  if (s.contains('computer') || s.contains('laptop')) {
    return Icons.laptop_mac_rounded;
  }
  if (s.contains('part') || s.contains('spare') || s.contains('auto') ||
      s.contains('car')) {
    return Icons.settings_suggest_outlined;
  }
  if (s.contains('machin') || s.contains('equip') || s.contains('industr')) {
    return Icons.precision_manufacturing_outlined;
  }
  if (s.contains('shoe') || s.contains('foot') || s.contains('cloth') ||
      s.contains('fashion') || s.contains('apparel')) {
    return Icons.checkroom_rounded;
  }
  if (s.contains('home') || s.contains('furnit') || s.contains('kitchen')) {
    return Icons.chair_outlined;
  }
  return Icons.category_outlined;
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: theme.dividerColor.withValues(alpha: .8)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              shape: BoxShape.circle,
            ),
            child: Icon(_catIcon(name), size: 16, color: scheme.primary),
          ),
          const SizedBox(width: 8),
          Text(name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13.5)),
        ],
      ),
    );
  }
}

class _CreateCard extends StatelessWidget {
  const _CreateCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AuthPalette.emeraldMid,
              AuthPalette.emerald,
              AuthPalette.emeraldDeep,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated flight route behind the content.
            Positioned.fill(
              child: ProLooper(
                duration: const Duration(seconds: 7),
                builder: (context, t) => LayoutBuilder(
                  builder: (_, box) {
                    final size = Size(box.maxWidth, box.maxHeight);
                    final path = Path()
                      ..moveTo(size.width * .42, size.height * .95)
                      ..quadraticBezierTo(size.width * .7, -size.height * .1,
                          size.width * .95, size.height * .2);
                    final metric = path.computeMetrics().first;
                    final u = Curves.easeInOut.transform(t);
                    final tan = metric.getTangentForOffset(metric.length * u)!;
                    return Stack(
                      children: [
                        CustomPaint(
                          size: size,
                          painter: _DashedPathPainter(path),
                        ),
                        Positioned(
                          left: tan.position.dx - 16,
                          top: tan.position.dy - 16,
                          child: Transform.rotate(
                            angle: tan.vector.direction + math.pi / 2,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AuthPalette.mint,
                                boxShadow: [
                                  BoxShadow(
                                    color: AuthPalette.mint
                                        .withValues(alpha: .6),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.flight_rounded,
                                  size: 18, color: AuthPalette.emeraldDeep),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroPill(
                      label: 'buyer.requests.newRequest'.tr,
                      icon: Icons.bolt_rounded),
                  const SizedBox(height: 14),
                  FractionallySizedBox(
                    widthFactor: .72,
                    child: Text(
                      'buyer.home.needToImport'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: .78,
                    child: Text(
                      'buyer.home.postRequestDescription'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .85),
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: 200,
                    child: PremiumButton(
                      label: 'buyer.requests.createAction'.tr,
                      icon: Icons.add_rounded,
                      style: PremiumButtonStyle.light,
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Get.toNamed(AppRoutes.createRequest);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedPathPainter extends CustomPainter {
  _DashedPathPainter(this.path);
  final Path path;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .35);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 14) {
        canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), p);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter old) => false;
}


/// Set to true for a different accent colour per category.
/// false keeps everything in the app's primary colour (matches a mono theme).
const bool _colorfulIcons = false;

/// Two-column grid of category cards for the buyer home page.
///
/// Pass a plain list (`controller.categories.toList()`) from inside the
/// page's `Obx` so GetX keeps tracking changes.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({super.key, required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[
      for (final c in categories) _CategoryCard(category: c),
    ];

    return GridView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 122,
      ),
      children: tiles
          .animate(interval: 60.ms, delay: 300.ms)
          .fadeIn(duration: 350.ms)
          .slideY(begin: .12, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final style = _styleFor(category.name);
    final accent = _colorfulIcons ? style.color : scheme.primary;
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(22);

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(color: theme.dividerColor.withValues(alpha: .8)),
        boxShadow: isDark
            ? null
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            // The tapped category is passed along; read it with Get.arguments
            // in CreateRequestController if you want to preselect it.
            Get.toNamed(AppRoutes.createRequest, arguments: category);
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: .12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(style.icon, size: 22, color: accent),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.north_east_rounded,
                      size: 16,
                      color: scheme.onSurface.withValues(alpha: .35),
                    ),
                  ],
                ),
                Text(
                  category.name,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CatStyle {
  const _CatStyle(this.icon, this.color);
  final IconData icon;
  final Color color;
}

/// Picks an icon per category name. Order matters: more specific matches first.
/// (The old matcher treated "Personal Care" as a car because it contains "car".)
_CatStyle _styleFor(String name) {
  final s = name.toLowerCase();
  bool has(List<String> keys) => keys.any(s.contains);

  if (has(['phone', 'mobile'])) {
    return const _CatStyle(Icons.smartphone_rounded, Color(0xFF6366F1));
  }
  if (has(['computer', 'laptop'])) {
    return const _CatStyle(Icons.laptop_mac_rounded, Color(0xFF6366F1));
  }
  if (has(['electronic'])) {
    return const _CatStyle(Icons.memory_rounded, Color(0xFF3B82F6));
  }
  if (has(['vehicle', 'automotive', 'spare part', 'motor'])) {
    return const _CatStyle(
        Icons.directions_car_filled_rounded, Color(0xFFF97316));
  }
  if (has(['construction', 'building', 'cement'])) {
    return const _CatStyle(Icons.construction_rounded, Color(0xFFF59E0B));
  }
  if (has(['machin', 'industrial', 'tool'])) {
    return const _CatStyle(
        Icons.precision_manufacturing_rounded, Color(0xFF64748B));
  }
  if (has(['cloth', 'footwear', 'shoe', 'fashion', 'apparel', 'textile'])) {
    return const _CatStyle(Icons.checkroom_rounded, Color(0xFFEC4899));
  }
  if (has(['beauty', 'cosmetic', 'personal care', 'skin'])) {
    return const _CatStyle(Icons.spa_rounded, Color(0xFFA855F7));
  }
  if (has(['home', 'household', 'appliance', 'furnit', 'kitchen'])) {
    return const _CatStyle(Icons.kitchen_rounded, Color(0xFF14B8A6));
  }
  if (has(['food', 'beverage', 'grocer'])) {
    return const _CatStyle(Icons.restaurant_rounded, Color(0xFFEF4444));
  }
  if (has(['health', 'medical', 'pharma'])) {
    return const _CatStyle(Icons.medical_services_rounded, Color(0xFF10B981));
  }
  if (has(['agri', 'farm'])) {
    return const _CatStyle(Icons.agriculture_rounded, Color(0xFF65A30D));
  }
  if (has(['toy', 'baby', 'kid'])) {
    return const _CatStyle(Icons.toys_rounded, Color(0xFFF43F5E));
  }
  if (has(['sport', 'fitness'])) {
    return const _CatStyle(Icons.sports_soccer_rounded, Color(0xFF0EA5E9));
  }
  if (has(['book', 'office', 'station'])) {
    return const _CatStyle(Icons.menu_book_rounded, Color(0xFF8B5CF6));
  }
  return const _CatStyle(Icons.category_rounded, Color(0xFF64748B));
}