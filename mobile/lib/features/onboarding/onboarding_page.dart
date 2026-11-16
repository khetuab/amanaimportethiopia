import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_palette.dart';
import '../../core/widgets/brand_mark.dart';
import '../auth/widgets/premium_button.dart';
import 'onboarding_controller.dart';

class OnboardingPage extends GetView<OnboardingController> {
  const OnboardingPage({super.key});

  static final _slides = [
    _Slide(
      icon: Icons.request_quote_outlined,
      title: 'onboarding.slide1.title'.tr,
      body: 'onboarding.slide1.body'.tr,
      scene: _RequestScene(),
    ),
    _Slide(
      icon: Icons.verified_user_outlined,
      title: 'onboarding.slide2.title'.tr,
      body: 'onboarding.slide2.body'.tr,
      scene: _QuotesScene(),
    ),
    _Slide(
      icon: Icons.local_shipping_outlined,
      title: 'onboarding.slide3.title'.tr,
      body: 'onboarding.slide3.body'.tr,
      scene: _TrackingScene(),
    ),
  ];

  /// Fractional page position (safe before the PageView attaches).
  double _page() {
    final pc = controller.pageController;
    if (pc.hasClients && pc.position.haveDimensions) {
      return pc.page ?? controller.index.value.toDouble();
    }
    return controller.index.value.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final panelH = (size.height * .47).clamp(280.0, 420.0);
    final controlsH = 124.0 + pad.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Emerald panel with page-linked parallax decor.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: panelH,
              child: AnimatedBuilder(
                animation: controller.pageController,
                builder: (_, __) => _Panel(page: _page()),
              ),
            ),

            // Slides.
            PageView.builder(
              controller: controller.pageController,
              itemCount: _slides.length,
              onPageChanged: (i) => controller.index.value = i,
              itemBuilder: (_, i) => _SlideView(
                slide: _slides[i],
                index: i,
                total: _slides.length,
                panelH: panelH,
                topInset: pad.top,
                bottomInset: controlsH,
                pageListenable: controller.pageController,
                page: _page,
              ),
            ),

            // Top bar: brand + Skip.
            Positioned(
              top: pad.top + 10,
              left: 20,
              right: 16,
              child: Row(
                children: [
                  const BrandMark(size: 38, radiusFactor: .32),
                  const SizedBox(width: 10),
                  const Text(
                    'Ethio Import ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                    ),
                  ),
                  const Spacer(),
                  Obx(() {
                    final last =
                        controller.index.value == OnboardingController.lastIndex;
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: last ? 0 : 1,
                      child: IgnorePointer(
                        ignoring: last,
                        child: Material(
                          color: Colors.white.withValues(alpha: .14),
                          shape: StadiumBorder(
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: .3)),
                          ),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: controller.skip,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 9),
                              child: Text(
                                'onboarding.skip'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ).animate().fadeIn(duration: 500.ms),

            // Indicators + buttons.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 8, 24, 16 + pad.bottom),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: controller.pageController,
                      builder: (_, __) => _Dots(
                        count: _slides.length,
                        page: _page(),
                        active: theme.colorScheme.primary,
                        inactive:
                        theme.colorScheme.onSurface.withValues(alpha: .18),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Obx(() {
                      final idx = controller.index.value;
                      final isLast = idx == OnboardingController.lastIndex;
                      return Row(
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (c, a) => SizeTransition(
                              sizeFactor: a,
                              axis: Axis.horizontal,
                              axisAlignment: -1,
                              child: FadeTransition(opacity: a, child: c),
                            ),
                            child: idx > 0
                                ? Padding(
                              key: const ValueKey('back'),
                              padding: const EdgeInsets.only(right: 12),
                              child:
                              _RoundBack(onTap: controller.previous),
                            )
                                : const SizedBox.shrink(key: ValueKey('none')),
                          ),
                          Expanded(
                            child: PremiumButton(
                              label: isLast
                                  ? 'onboarding.getStarted'.tr
                                  : 'common.next'.tr,
                              icon: isLast
                                  ? Icons.rocket_launch_rounded
                                  : Icons.arrow_forward_rounded,
                              onPressed: controller.next,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Layout pieces ─────────────────────────

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
    required this.scene,
  });
  final IconData icon;
  final String title;
  final String body;
  final Widget scene;
}

class _SlideView extends StatelessWidget {
  const _SlideView({
    required this.slide,
    required this.index,
    required this.total,
    required this.panelH,
    required this.topInset,
    required this.bottomInset,
    required this.pageListenable,
    required this.page,
  });

  final _Slide slide;
  final int index;
  final int total;
  final double panelH;
  final double topInset;
  final double bottomInset;
  final Listenable pageListenable;
  final double Function() page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: pageListenable,
      builder: (context, _) {
        final delta = (page() - index).clamp(-1.0, 1.0);
        final a = delta.abs();
        return Column(
          children: [
            SizedBox(
              height: panelH,
              child: Padding(
                padding: EdgeInsets.only(top: topInset + 56, bottom: 20),
                child: Transform.translate(
                  offset: Offset(delta * -60, 0),
                  child: Transform.scale(
                    scale: 1 - a * .15,
                    child: Opacity(
                      opacity: 1 - a * .8,
                      child: FittedBox(
                        child: SizedBox(
                            width: 300, height: 300, child: slide.scene),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Opacity(
                opacity: 1 - a,
                child: Transform.translate(
                  offset: Offset(0, a * 24),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24, 26, 24, bottomInset),
                    child: SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: .1),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(slide.icon,
                                    size: 16, color: scheme.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'common.stepOf'.trParams(
                                      {'step': '${index + 1}', 'total': '$total'}),
                                  style: TextStyle(
                                    color: scheme.primary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            slide.title,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.5,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            slide.body,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface.withValues(alpha: .7),
                              height: 1.55,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.page});
  final double page;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(44)),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, .5, 1],
            colors: [
              AuthPalette.emeraldMid,
              AuthPalette.emerald,
              AuthPalette.emeraldDeep,
            ],
          ),
        ),
        child: CustomPaint(
          size: Size.infinite,
          painter: _PanelPainter(page),
        ),
      ),
    );
  }
}

class _PanelPainter extends CustomPainter {
  _PanelPainter(this.page);
  final double page;

  @override
  void paint(Canvas canvas, Size s) {
    // Soft glow.
    final gc = Offset(s.width * .5 - page * 30, s.height * .55);
    canvas.drawCircle(
      gc,
      s.width * .6,
      Paint()
        ..shader = RadialGradient(
          colors: [AuthPalette.mint.withValues(alpha: .22), Colors.transparent],
        ).createShader(Rect.fromCircle(center: gc, radius: s.width * .6)),
    );

    // Rings (parallax at two speeds).
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: .08);
    final c1 = Offset(s.width * .95 - page * 40, s.height * .2);
    for (final r in [70.0, 120.0, 170.0]) {
      canvas.drawCircle(c1, r, ring);
    }
    final c2 = Offset(s.width * .02 - page * 25, s.height * .92);
    for (final r in [60.0, 100.0]) {
      canvas.drawCircle(c2, r, ring);
    }

    // Dot grid.
    final dot = Paint()..color = Colors.white.withValues(alpha: .16);
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 6; c++) {
        canvas.drawCircle(
          Offset(18 + c * 16 - page * 18, s.height * .6 + r * 16),
          1.6,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PanelPainter old) => old.page != page;
}

class _Dots extends StatelessWidget {
  const _Dots({
    required this.count,
    required this.page,
    required this.active,
    required this.inactive,
  });
  final int count;
  final double page;
  final Color active;
  final Color inactive;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final near = (1 - (page - i).abs()).clamp(0.0, 1.0);
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: 8 + 20 * near,
          decoration: BoxDecoration(
            color: Color.lerp(inactive, active, near),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _RoundBack extends StatelessWidget {
  const _RoundBack({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scheme.onSurface.withValues(alpha: .18)),
          ),
          child: Icon(Icons.arrow_back_rounded, color: scheme.onSurface),
        ),
      ),
    );
  }
}

// class _BrandBadge extends StatelessWidget {
//   const _BrandBadge();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 38,
//       height: 38,
//       alignment: Alignment.center,
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(12),
//         gradient: const LinearGradient(
//           colors: [AuthPalette.mint, AuthPalette.emeraldMid],
//         ),
//       ),
//       child: const Text(
//         'ኢ',
//         style: TextStyle(
//           color: AuthPalette.emeraldDeep,
//           fontWeight: FontWeight.w800,
//           fontSize: 18,
//         ),
//       ),
//     );
//   }
// }

// ───────────────────────── Animation helper ─────────────────────────

/// Drives a looping 0..1 value. Use integer multiples of t inside
/// sin/cos so loops are seamless.
class _Looper extends StatefulWidget {
  const _Looper({required this.duration, required this.builder});
  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<_Looper> createState() => _LooperState();
}

class _LooperState extends State<_Looper> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: widget.duration)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (ctx, _) => widget.builder(ctx, _c.value),
  );
}

const _ink = Color(0xFF04201A);
const _soft = Color(0xFFE6F4EE);

BoxDecoration _whiteCard(double r, {double shadow = .22}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(r),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withValues(alpha: shadow),
      blurRadius: 24,
      offset: const Offset(0, 12),
    ),
  ],
);

// ───────────────────────── Scene 1: Request ─────────────────────────

class _RequestScene extends StatelessWidget {
  const _RequestScene();

  static const _badges = [
    Icons.smartphone_rounded,
    Icons.settings_suggest_outlined,
    Icons.precision_manufacturing_outlined,
    Icons.shopping_bag_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    return _Looper(
      duration: const Duration(seconds: 24),
      builder: (context, t) {
        final back = <Widget>[];
        final front = <Widget>[];

        for (var i = 0; i < _badges.length; i++) {
          final a = i * math.pi / 2 + t * math.pi * 2;
          final depth = math.sin(a); // >0 = in front
          final bob = math.sin(t * math.pi * 2 * 6 + i) * 4;
          final scale = .85 + .15 * ((depth + 1) / 2);
          final w = Positioned(
            left: 150 + math.cos(a) * 130 - 23,
            top: 150 + math.sin(a) * 112 - 23 + bob,
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: .7 + .3 * ((depth + 1) / 2),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: _whiteCard(23, shadow: .18),
                  child: Icon(_badges[i], color: AuthPalette.emerald, size: 24),
                ),
              ),
            ),
          );
          (depth < 0 ? back : front).add(w);
        }

        final typing = Curves.easeOut.transform((t * 12) % 1);
        final pulse = 1 + .03 * math.sin(t * math.pi * 2 * 12);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final r in [78.0, 118.0, 150.0])
              Center(
                child: Transform.scale(
                  scale: 1 + .035 * math.sin(t * math.pi * 2 * 8 + r / 40),
                  child: Container(
                    width: r * 2,
                    height: r * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withValues(alpha: .13)),
                    ),
                  ),
                ),
              ),
            ...back,
            Center(
              child: Container(
                width: 176,
                padding: const EdgeInsets.all(12),
                decoration: _whiteCard(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            AuthPalette.mint.withValues(alpha: .45),
                            AuthPalette.emeraldMid.withValues(alpha: .18),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          const Center(
                            child: Icon(Icons.image_outlined,
                                size: 34, color: AuthPalette.emerald),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AuthPalette.emerald,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.add_a_photo_outlined,
                                  size: 13, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _line(24 + 100 * typing, AuthPalette.emerald, 9),
                    const SizedBox(height: 7),
                    _line(124, const Color(0xFFD5E7DF), 7),
                    const SizedBox(height: 6),
                    _line(84, const Color(0xFFD5E7DF), 7),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _MiniChip(Icons.payments_outlined,
                            '20k ${'common.etb'.tr}'),
                        const SizedBox(width: 6),
                        _MiniChip(Icons.place_outlined,
                            'onboarding.scene.chipCity'.tr),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Transform.scale(
                      scale: pulse,
                      child: Container(
                        height: 30,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              AuthPalette.emeraldMid,
                              AuthPalette.emerald,
                            ],
                          ),
                        ),
                        child: Text(
                          'onboarding.scene.postRequest'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ...front,
          ],
        );
      },
    );
  }

  static Widget _line(double w, Color c, double h) => Container(
    width: w,
    height: h,
    decoration:
    BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
  );
}

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF065F46)),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF065F46),
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Scene 2: Quotes ─────────────────────────

class _QuotesScene extends StatelessWidget {
  const _QuotesScene();

  static final _quotes = [
    ('S', 'onboarding.scene.company1'.tr, 'onboarding.scene.quote1Terms'.tr,
        '${'common.etb'.tr} 18,400'),
    ('H', 'onboarding.scene.company2'.tr, 'onboarding.scene.quote2Terms'.tr,
        '${'common.etb'.tr} 17,900'),
    ('N', 'onboarding.scene.company3'.tr, 'onboarding.scene.quote3Terms'.tr,
        '${'common.etb'.tr} 19,200'),
  ];

  @override
  Widget build(BuildContext context) {
    return _Looper(
      duration: const Duration(seconds: 9),
      builder: (context, t) {
        final active = (t * 3).floor() % 3;
        final shield = 1 + .08 * math.sin(t * math.pi * 2 * 6);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < _quotes.length; i++)
              Positioned(
                left: 28,
                top: 20 + i * 90 + math.sin(t * math.pi * 2 * 3 + i * 2) * 4,
                child: AnimatedScale(
                  scale: active == i ? 1.05 : .97,
                  duration: const Duration(milliseconds: 450),
                  curve: Curves.easeOutCubic,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    width: 244,
                    height: 76,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: active == i
                            ? AuthPalette.mint
                            : Colors.transparent,
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black
                              .withValues(alpha: active == i ? .3 : .15),
                          blurRadius: active == i ? 28 : 16,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AuthPalette.emeraldMid,
                                AuthPalette.emeraldDeep,
                              ],
                            ),
                          ),
                          child: Text(
                            _quotes[i].$1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      _quotes[i].$2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _ink,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.verified_rounded,
                                      size: 14, color: AuthPalette.emeraldMid),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _quotes[i].$3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF566F66),
                                  fontSize: 10.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              _quotes[i].$4,
                              style: const TextStyle(
                                color: AuthPalette.emerald,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (i == 1) ...[
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AuthPalette.mint.withValues(alpha: .3),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'onboarding.scene.bestPrice'.tr,
                                  style: const TextStyle(
                                    color: Color(0xFF065F46),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Positioned(
              right: 4,
              top: -6,
              child: Transform.scale(
                scale: shield,
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AuthPalette.mint, AuthPalette.emeraldMid],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AuthPalette.mint.withValues(alpha: .5),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      color: AuthPalette.emeraldDeep, size: 24),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ───────────────────────── Scene 3: Tracking ─────────────────────────

final Path _routePath = Path()
  ..moveTo(44, 176)
  ..cubicTo(40, 40, 180, 210, 258, 76);
final PathMetric _routeMetric = _routePath.computeMetrics().first;

class _TrackingScene extends StatelessWidget {
  const _TrackingScene();

  @override
  Widget build(BuildContext context) {
    return _Looper(
      duration: const Duration(seconds: 10),
      builder: (context, t) {
        final u = Curves.easeInOutCubic.transform((t / .8).clamp(0.0, 1.0));
        final pos =
            _routeMetric.getTangentForOffset(_routeMetric.length * u)!.position;
        final markerOpacity =
        t < .04 ? t / .04 : (t > .95 ? (1 - t) / .05 : 1.0);
        final arrived = t > .8;
        final ringT = arrived ? ((t - .8) / .2) : 0.0;

        final label = u < .12
            ? 'onboarding.scene.statusConfirmed'.tr
            : u < .55
            ? 'onboarding.scene.statusTransit'.tr
            : (arrived
                ? 'onboarding.scene.statusDelivered'.tr
                : 'onboarding.scene.statusOutForDelivery'.tr);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _RoutePainter(u)),
            ),
            // Start pin (port).
            Positioned(
              left: 44 - 22,
              top: 176 - 22,
              child: Container(
                width: 44,
                height: 44,
                decoration: _whiteCard(22, shadow: .2),
                child: const Icon(Icons.directions_boat_rounded,
                    color: AuthPalette.emerald, size: 22),
              ),
            ),
            // End pin (home) with arrival ripple.
            Positioned(
              left: 258 - 22,
              top: 76 - 22,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (arrived)
                    Opacity(
                      opacity: (1 - ringT).clamp(0.0, 1.0),
                      child: Container(
                        width: 44 + 60 * ringT,
                        height: 44 + 60 * ringT,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AuthPalette.mint, width: 2),
                        ),
                      ),
                    ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: arrived ? AuthPalette.mint : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      arrived ? Icons.check_rounded : Icons.home_rounded,
                      color: arrived ? AuthPalette.emeraldDeep : AuthPalette.emerald,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Moving truck.
            Positioned(
              left: pos.dx - 20,
              top: pos.dy - 20,
              child: Opacity(
                opacity: markerOpacity.clamp(0.0, 1.0),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AuthPalette.mint,
                    boxShadow: [
                      BoxShadow(
                        color: AuthPalette.mint.withValues(alpha: .6),
                        blurRadius: 18,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.local_shipping_rounded,
                      color: AuthPalette.emeraldDeep, size: 22),
                ),
              ),
            ),
            // Status card.
            Positioned(
              left: 30,
              right: 30,
              bottom: 4,
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: _whiteCard(20, shadow: .2),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                        color: _soft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        arrived
                            ? Icons.task_alt_rounded
                            : Icons.my_location_rounded,
                        size: 18,
                        color: AuthPalette.emerald,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: Text(
                              label,
                              key: ValueKey(label),
                              style: const TextStyle(
                                color: _ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 7),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: u,
                              minHeight: 5,
                              backgroundColor: _soft,
                              valueColor: const AlwaysStoppedAnimation(
                                  AuthPalette.emeraldMid),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RoutePainter extends CustomPainter {
  _RoutePainter(this.u);
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    // Dashed full route.
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .4);
    for (double d = 0; d < _routeMetric.length; d += 14) {
      canvas.drawPath(
        _routeMetric.extractPath(d, math.min(d + 6, _routeMetric.length)),
        dash,
      );
    }
    // Travelled glow + solid.
    final done = _routeMetric.extractPath(0, _routeMetric.length * u);
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = AuthPalette.mint.withValues(alpha: .35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = AuthPalette.mint,
    );
  }

  @override
  bool shouldRepaint(covariant _RoutePainter old) => old.u != u;
}