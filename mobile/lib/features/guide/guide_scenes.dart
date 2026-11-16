import 'dart:math' as math;
import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/auth_palette.dart';

/// Animated illustrated scenes for the Guide tab.
/// Every scene is painted on a 300 x 300 canvas and scaled with FittedBox,
/// following the same looping style as the onboarding scenes.
///
/// The hero panels behind scenes always use the dark AuthPalette gradient,
/// so scene cards stay white in both light and dark themes.

// ───────────────────────── Shared palette ─────────────────────────

const _ink = Color(0xFF111111);
const _muted = Color(0xFF6E6E6E);
const _soft = Color(0xFFF1F1F1);
const _softBorder = Color(0xFFE4E4E4);
const _ok = AppColors.success; // 0xFF047857

// ───────────────────────── Looper ─────────────────────────

/// Repeating 0 → 1 ticker, same pattern as onboarding's _Looper.
/// Muted automatically by TickerMode when the tab is not visible.
class SceneLooper extends StatefulWidget {
  const SceneLooper({super.key, required this.duration, required this.builder});

  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<SceneLooper> createState() => _SceneLooperState();
}

class _SceneLooperState extends State<SceneLooper>
    with SingleTickerProviderStateMixin {
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

// ───────────────────────── Small building blocks ─────────────────────────

BoxDecoration _whiteCard(double r, {Color? border, double shadow = .22}) =>
    BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(r),
      border: border != null ? Border.all(color: border, width: 2) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: shadow),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    );

Widget _line(double w, {double h = 8, Color c = _soft}) => Container(
      width: w,
      height: h,
      decoration:
          BoxDecoration(color: c, borderRadius: BorderRadius.circular(6)),
    );

Widget _priceText(String price, {Color c = _ink, double size = 13}) => Text(
      price,
      style: TextStyle(
        color: c,
        fontSize: size,
        fontWeight: FontWeight.w800,
        letterSpacing: -.2,
      ),
    );

class _MiniChip extends StatelessWidget {
  const _MiniChip(this.icon, this.label, {this.fg = _ink, this.bg = _soft});
  final IconData icon;
  final String label;
  final Color fg;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarBadge extends StatelessWidget {
  const _AvatarBadge(this.letter, {this.size = 40});
  final String letter;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AuthPalette.emeraldMid, AuthPalette.emeraldDeep],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * .42,
        ),
      ),
    );
  }
}

// ───────────────────────── Panel decoration ─────────────────────────

/// Soft glow + rings + dot grid painted on the dark hero panels.
class PanelDecoPainter extends CustomPainter {
  PanelDecoPainter([this.shift = 0]);
  final double shift;

  @override
  void paint(Canvas canvas, Size s) {
    final gc = Offset(s.width * (.5 + shift * .04), s.height * .52);
    canvas.drawCircle(
      gc,
      s.width * .62,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: .10),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: gc, radius: s.width * .62)),
    );

    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: .07);
    final c1 = Offset(s.width * .92 - shift * 26, s.height * .18);
    for (final r in [54.0, 96.0, 140.0]) {
      canvas.drawCircle(c1, r, ring);
    }
    final c2 = Offset(s.width * .05 - shift * 18, s.height * .9);
    for (final r in [44.0, 78.0]) {
      canvas.drawCircle(c2, r, ring);
    }

    final dot = Paint()..color = Colors.white.withValues(alpha: .13);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < 6; c++) {
        canvas.drawCircle(
          Offset(16 + c * 15 - shift * 12, s.height - 34 + r * 15),
          1.5,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant PanelDecoPainter old) => old.shift != shift;
}

// ───────────────────────── Route tracking ─────────────────────────

class _Track {
  _Track(Path path) : metric = path.computeMetrics().first;
  final PathMetric metric;
}

/// Dashed route + glowing travelled portion, tinted for the dark panel.
class TrackPainter extends CustomPainter {
  TrackPainter(this.track, this.u);
  final _Track track;
  final double u;

  @override
  void paint(Canvas canvas, Size size) {
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .38);
    for (double d = 0; d < track.metric.length; d += 14) {
      canvas.drawPath(
        track.metric
            .extractPath(d, math.min(d + 6, track.metric.length)),
        dash,
      );
    }
    final done = track.metric.extractPath(0, track.metric.length * u);
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withValues(alpha: .35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawPath(
      done,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant TrackPainter old) => old.u != u;
}

// ═════════════════════════ BUYER SCENES ═════════════════════════

/// B1 — the request card assembles itself while category badges float by.
class PostRequestScene extends StatelessWidget {
  const PostRequestScene({super.key});

  static const _badges = [
    Icons.smartphone_rounded,
    Icons.directions_car_rounded,
    Icons.precision_manufacturing_outlined,
    Icons.checkroom_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    const spots = [
      Offset(22, 30),
      Offset(228, 20),
      Offset(252, 126),
      Offset(6, 166),
    ];
    return SceneLooper(
      duration: const Duration(seconds: 7),
      builder: (context, t) {
        final pulse = 1 + .05 * math.sin(t * math.pi * 2 * 2);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < _badges.length; i++)
              Positioned(
                left: spots[i].dx,
                top: spots[i].dy + math.sin(t * math.pi * 2 + i * 1.7) * 5,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: _whiteCard(14, shadow: .2),
                  child: Icon(_badges[i], size: 22, color: _ink),
                ),
              ),
            Positioned(
              left: 34,
              top: 92,
              child: Container(
                width: 232,
                padding: const EdgeInsets.all(14),
                decoration: _whiteCard(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _soft,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.image_outlined,
                              size: 20, color: _muted),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(120, h: 9, c: const Color(0xFFD9D9D9)),
                              const SizedBox(height: 6),
                              _line(76),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      children: [
                        _MiniChip(Icons.payments_outlined, 'ETB 15,000'),
                        SizedBox(width: 6),
                        _MiniChip(Icons.place_outlined, 'Addis'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Transform.scale(
                      scale: pulse,
                      child: Container(
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              AuthPalette.emeraldMid,
                              AuthPalette.emerald,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .3),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Text(
                          'guide.scene.postRequest'.tr,
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
          ],
        );
      },
    );
  }
}

/// B2 — quote cards glide in one after another; the focused one glows.
class QuotesArriveScene extends StatelessWidget {
  const QuotesArriveScene({super.key});

  static const _quotes = [
    ('S', 'Selam Trading', '5 days · 12-mo warranty', 'ETB 18,400'),
    ('H', 'Habesha Imports', '7 days · 24-mo warranty', 'ETB 17,900'),
    ('N', 'Nile Cargo', '4 days · 6-mo warranty', 'ETB 19,200'),
  ];

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 9),
      builder: (context, t) {
        final active = (t * 3).floor() % 3;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 88,
              top: 8,
              child: _MiniChip(
                Icons.notifications_active_rounded,
                'guide.scene.newQuotes'.tr,
                fg: Colors.white,
                bg: AuthPalette.emeraldMid,
              ),
            ),
            for (var i = 0; i < _quotes.length; i++)
              Positioned(
                left: 28,
                top: 52 + i * 80,
                child: Transform.translate(
                  offset: Offset(
                      math.max(0, 1 - (t * 3.4 - i * .35)) * 190, 0),
                  child: AnimatedScale(
                    scale: active == i ? 1.05 : .97,
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutCubic,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 450),
                      curve: Curves.easeOutCubic,
                      width: 244,
                      height: 66,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: _whiteCard(
                        20,
                        border:
                            active == i ? Colors.white : Colors.transparent,
                        shadow: active == i ? .34 : .16,
                      ),
                      child: Row(
                        children: [
                          _AvatarBadge(_quotes[i].$1, size: 38),
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
                                        size: 14, color: _ok),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _quotes[i].$3.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: _muted, fontSize: 10.5),
                                ),
                              ],
                            ),
                          ),
                          _priceText(_quotes[i].$4),
                        ],
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

/// B3 — comparison bars race; the best-value row lifts with a check pop.
class CompareScene extends StatelessWidget {
  const CompareScene({super.key});

  static const _rows = [
    ('S', .78, 'ETB 18,400'),
    ('H', .62, 'ETB 17,900'),
    ('N', .9, 'ETB 19,200'),
  ];

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 6),
      builder: (context, t) {
        final grow =
            Curves.easeOutCubic.transform((t / .55).clamp(0.0, 1.0));
        final pick = Curves.easeOutBack
            .transform(((t - .62) / .38).clamp(0.0, 1.0));
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (pick > 0)
              Opacity(
                opacity: (pick * .5).clamp(0.0, 1.0),
                child: Container(
                  width: 210 + 40 * pick,
                  height: 210 + 40 * pick,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color:
                          Colors.white.withValues(alpha: (1 - pick) * .5),
                      width: 2,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: 26,
              top: 56,
              child: Container(
                width: 248,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                decoration: _whiteCard(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.compare_arrows_rounded,
                            size: 15, color: _muted),
                        const SizedBox(width: 6),
                        Text(
                          'guide.scene.compareTitle'.tr,
                          style: TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    for (var i = 0; i < _rows.length; i++) ...[
                      AnimatedScale(
                        scale: i == 1 ? 1 + .03 * pick : 1,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 5),
                          decoration: BoxDecoration(
                            color: i == 1 && pick > 0
                                ? _soft
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              _AvatarBadge(_rows[i].$1, size: 26),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: grow,
                                    child: Container(
                                      height: 9,
                                      width: 96 * _rows[i].$2,
                                      decoration: BoxDecoration(
                                        color: i == 1
                                            ? _ok
                                            : AuthPalette.emeraldMid,
                                        borderRadius:
                                            BorderRadius.circular(5),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _priceText(_rows[i].$3, size: 11.5),
                              if (i == 1)
                                Transform.scale(
                                  scale: pick,
                                  child: Container(
                                    margin: const EdgeInsets.only(left: 6),
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: _ok,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.check_rounded,
                                        size: 12, color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (i != _rows.length - 1) const SizedBox(height: 4),
                    ],
                    const SizedBox(height: 8),
                    Center(
                      child: Transform.scale(
                        scale: pick,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _ok,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'guide.scene.bestValue'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
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

/// B4 — coins fly from the wallet into the escrow shield; review completes.
class SecurePayScene extends StatelessWidget {
  const SecurePayScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 7),
      builder: (context, t) {
        final shield = 1 + .07 * math.sin(t * math.pi * 2 * 3);
        final label = t < .25
            ? 'guide.scene.paySubmitted'.tr
            : t < .7
                ? 'guide.scene.payReviewing'.tr
                : 'guide.scene.fundsSecured'.tr;
        final done = t > .7;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Wallet.
            Positioned(
              left: 26,
              top: 96,
              child: Container(
                width: 62,
                height: 62,
                decoration: _whiteCard(18),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    size: 28, color: _ink),
              ),
            ),
            // Escrow shield.
            Positioned(
              left: 168,
              top: 76,
              child: Transform.scale(
                scale: shield,
                child: Container(
                  width: 86,
                  height: 86,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AuthPalette.emeraldMid,
                        AuthPalette.emeraldDeep
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.verified_user_rounded,
                      size: 40, color: Colors.white),
                ),
              ),
            ),
            // Flying coins.
            for (var i = 0; i < 3; i++)
              _FlyCoin(
                t: (t * 1.6 - i * .18).clamp(0.0, 1.0),
                from: const Offset(66, 122),
                to: const Offset(196, 104),
                arc: 46 + i * 10,
              ),
            // Status card.
            Positioned(
              left: 34,
              right: 34,
              bottom: 14,
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: _whiteCard(20),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                          color: _soft, shape: BoxShape.circle),
                      child: Icon(
                        done
                            ? Icons.task_alt_rounded
                            : Icons.hourglass_top_rounded,
                        size: 18,
                        color: done ? _ok : _ink,
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
                              value: Curves.easeInOut
                                  .transform((t / .75).clamp(0.0, 1.0)),
                              minHeight: 5,
                              backgroundColor: _soft,
                              valueColor:
                                  const AlwaysStoppedAnimation(_ok),
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

class _FlyCoin extends StatelessWidget {
  const _FlyCoin({
    required this.t,
    required this.from,
    required this.to,
    required this.arc,
  });

  final double t;
  final Offset from;
  final Offset to;
  final double arc;

  @override
  Widget build(BuildContext context) {
    if (t <= 0 || t >= 1) return const SizedBox.shrink();
    final u = Curves.easeInOutCubic.transform(t);
    final base = Offset.lerp(from, to, u)!;
    final pos = base - Offset(0, math.sin(u * math.pi) * arc);
    return Positioned(
      left: pos.dx - 11,
      top: pos.dy - 11,
      child: Opacity(
        opacity: (1 - math.max(0.0, (t - .9) * 10)).clamp(0.0, 1.0).toDouble(),
        child: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: _softBorder, width: 1.4),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .18),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(Icons.paid_rounded, size: 13, color: _ok),
        ),
      ),
    );
  }
}

final _buyerRoute = _Track(Path()
  ..moveTo(42, 196)
  ..cubicTo(30, 70, 150, 236, 252, 86));

/// B5 — shipment travels the route; the buyer's door ripples on arrival.
class TrackDeliveryScene extends StatelessWidget {
  const TrackDeliveryScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 9),
      builder: (context, t) {
        final u =
            Curves.easeInOutCubic.transform((t / .8).clamp(0.0, 1.0));
        final pos = _buyerRoute.metric
            .getTangentForOffset(_buyerRoute.metric.length * u)!
            .position;
        final arrived = t > .8;
        final ringT = arrived ? (t - .8) / .2 : 0.0;
        final label = u < .15
            ? 'guide.scene.orderConfirmed'.tr
            : u < .6
                ? 'guide.scene.inTransit'.tr
                : (arrived
                    ? 'guide.scene.delivered'.tr
                    : 'guide.scene.outForDelivery'.tr);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: TrackPainter(_buyerRoute, u)),
            ),
            // Port pin.
            Positioned(
              left: 42 - 21,
              top: 196 - 21,
              child: Container(
                width: 42,
                height: 42,
                decoration: _whiteCard(21, shadow: .2),
                child: const Icon(Icons.directions_boat_rounded,
                    size: 21, color: _ink),
              ),
            ),
            // Home pin + arrival ripple.
            Positioned(
              left: 252 - 21,
              top: 86 - 21,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (arrived)
                    Opacity(
                      opacity: (1 - ringT).clamp(0.0, 1.0),
                      child: Container(
                        width: 42 + 56 * ringT,
                        height: 42 + 56 * ringT,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color:
                                  Colors.white.withValues(alpha: .8),
                              width: 2),
                        ),
                      ),
                    ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
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
                      color: arrived ? _ok : _ink,
                      size: 23,
                    ),
                  ),
                ],
              ),
            ),
            // Moving truck.
            Positioned(
              left: pos.dx - 19,
              top: pos.dy - 19,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: .55),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    size: 20, color: _ink),
              ),
            ),
            // Status card.
            Positioned(
              left: 30,
              right: 30,
              bottom: 8,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: _whiteCard(20),
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: const BoxDecoration(
                          color: _soft, shape: BoxShape.circle),
                      child: Icon(
                        arrived
                            ? Icons.task_alt_rounded
                            : Icons.my_location_rounded,
                        size: 18,
                        color: arrived ? _ok : _ink,
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
                              valueColor:
                                  const AlwaysStoppedAnimation(_ink),
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

// ═════════════════════════ IMPORTER SCENES ═════════════════════════

/// I1 — licence document gets scanned, then the verified badge stamps in.
class VerificationScene extends StatelessWidget {
  const VerificationScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 6),
      builder: (context, t) {
        final scan =
            Curves.easeInOut.transform((t / .55).clamp(0.0, 1.0));
        final stamp = Curves.elasticOut
            .transform(((t - .55) / .45).clamp(0.0, 1.0));
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 62,
              top: 34,
              child: Container(
                width: 176,
                height: 200,
                padding: const EdgeInsets.all(14),
                decoration: _whiteCard(20),
                child: Stack(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _soft,
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(Icons.badge_rounded,
                                  size: 16, color: _ink),
                            ),
                            const SizedBox(width: 8),
                            _line(84, h: 9, c: const Color(0xFFD9D9D9)),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _line(140, h: 7),
                        const SizedBox(height: 8),
                        _line(120),
                        const SizedBox(height: 8),
                        _line(136),
                        const SizedBox(height: 8),
                        _line(96),
                        const Spacer(),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            _line(56, h: 7),
                            _line(40, h: 7),
                          ],
                        ),
                      ],
                    ),
                    // Scanning shimmer sweeping down the document.
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 10 + scan * 140,
                      child: Container(
                        height: 26,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withValues(alpha: 0),
                              Colors.white.withValues(alpha: .55),
                              Colors.white.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Verified stamp.
            if (stamp > 0)
              Positioned(
                left: 176,
                top: 168,
                child: Transform.rotate(
                  angle: -.14,
                  child: Transform.scale(
                    scale: stamp,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _ok,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .3),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified_rounded,
                              size: 14, color: Colors.white),
                          const SizedBox(width: 5),
                          Text(
                            'guide.scene.verified'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            // Floating shield.
            Positioned(
              right: 14,
              top: 6,
              child: Transform.scale(
                scale: 1 + .06 * math.sin(t * math.pi * 2 * 3),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: .4),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.workspace_premium_rounded,
                      size: 24, color: _ink),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// I2a — the business profile fills up as categories and details are added.
class BusinessProfileScene extends StatelessWidget {
  const BusinessProfileScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 6),
      builder: (context, t) {
        final fill = Curves.easeOutCubic.transform((t / .6).clamp(0.0, 1.0));
        final chipIn = Curves.easeOutBack.transform(((t - .2) / .3).clamp(0.0, 1.0));
        final ring = 1 + .05 * math.sin(t * math.pi * 2 * 2);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 34,
              top: 40,
              child: Container(
                width: 232,
                padding: const EdgeInsets.all(14),
                decoration: _whiteCard(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                AuthPalette.emeraldMid,
                                AuthPalette.emeraldDeep,
                              ],
                            ),
                          ),
                          child: const Text(
                            'HB',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _line(110, h: 9, c: const Color(0xFFD9D9D9)),
                              const SizedBox(height: 6),
                              _line(70),
                            ],
                          ),
                        ),
                        const Icon(Icons.verified_rounded,
                            size: 18, color: _ok),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Transform.scale(
                      scale: chipIn,
                      alignment: Alignment.centerLeft,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            _MiniChip(Icons.electrical_services_rounded,
                                'guide.scene.catElectronics'.tr),
                            const SizedBox(width: 6),
                            _MiniChip(Icons.construction_rounded,
                                'guide.scene.catMachinery'.tr),
                            const SizedBox(width: 6),
                            _MiniChip(Icons.directions_car_rounded,
                                'guide.scene.catAuto'.tr),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Text(
                          'guide.scene.profileStrength'.tr,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(88 * fill).round()}%',
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: fill,
                        minHeight: 7,
                        backgroundColor: _soft,
                        valueColor: const AlwaysStoppedAnimation(_ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Floating completeness badge.
            Positioned(
              right: 20,
              top: 16,
              child: Transform.scale(
                scale: ring,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: .4),
                        blurRadius: 18,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.badge_rounded,
                      size: 25, color: _ink),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// I2 — live requests stream past under the category filters.
class BrowseRequestsScene extends StatelessWidget {
  const BrowseRequestsScene({super.key});

  static const _cards = [
    (Icons.smartphone_rounded, 'iPhone 15 Pro · 20 pcs', 'Addis'),
    (Icons.directions_car_rounded, 'Brake pads · Toyota', 'Dire Dawa'),
    (Icons.memory_rounded, 'CNC spare set', 'Adama'),
  ];

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 7),
      builder: (context, t) {
        final scroll = (t * 84) % 84;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Filters.
            Positioned(
              left: 24,
              right: 24,
              top: 6,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  children: [
                    _MiniChip(
                      Icons.memory_rounded,
                      'guide.scene.catElectronics'.tr,
                      fg: Colors.white,
                      bg: AuthPalette.emeraldMid,
                    ),
                    const SizedBox(width: 6),
                    _MiniChip(Icons.directions_car_rounded,
                        'guide.scene.catAutoParts'.tr),
                    const SizedBox(width: 6),
                    _MiniChip(Icons.build_rounded, 'guide.scene.catMachinery'.tr),
                  ],
                ),
              ),
            ),
            // Streaming cards.
            for (var i = 0; i < 4; i++)
              Positioned(
                left: 26,
                right: 26,
                top: 52 + i * 70 - scroll,
                child: Opacity(
                  opacity: (1 - ((i * 70 - scroll).abs() / 130))
                      .clamp(0.25, 1.0),
                  child: Container(
                    height: 58,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: _whiteCard(18, shadow: .18),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _soft,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(
                            _cards[i % 3].$1,
                            size: 18,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cards[i % 3].$2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: _ink,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              _line(64, h: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (i == 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 4),
                            decoration: BoxDecoration(
                              color: AuthPalette.emeraldMid,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'guide.scene.newBadge'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: .6,
                              ),
                            ),
                          )
                        else
                          _MiniChip(Icons.place_outlined,
                              _cards[i % 3].$3),
                      ],
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

/// I3 — the quotation form types itself and the button flips to sent.
class SubmitQuoteScene extends StatelessWidget {
  const SubmitQuoteScene({super.key});

  @override
  Widget build(BuildContext context) {
    const price = 'ETB 17,900';
    return SceneLooper(
      duration: const Duration(seconds: 6),
      builder: (context, t) {
        final typeU = (t / .5).clamp(0.0, 1.0);
        final typed = price
            .substring(0, (typeU * price.length).round().clamp(0, price.length));
        final sent = t > .78;
        final cursor = (t * 8).floor() % 2 == 0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 30,
              top: 30,
              child: Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: _whiteCard(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.request_quote_rounded,
                            size: 16, color: _muted),
                        const SizedBox(width: 6),
                        Text(
                          'guide.scene.yourQuote'.tr,
                          style: const TextStyle(
                            color: _muted,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .2,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Price field with typing cursor.
                    Container(
                      height: 40,
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.centerLeft,
                      decoration: BoxDecoration(
                        color: _soft,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _softBorder),
                      ),
                      child: Row(
                        children: [
                          Text(
                            typed,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.2,
                            ),
                          ),
                          if (!sent && cursor)
                            Container(
                              width: 2,
                              height: 18,
                              margin: const EdgeInsets.only(left: 2),
                              color: _ink,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          _MiniChip(Icons.local_shipping_outlined,
                              'guide.scene.deliveryWindow'.tr),
                          const SizedBox(width: 6),
                          _MiniChip(Icons.verified_user_outlined,
                              'guide.scene.warranty'.tr),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Send button.
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      transitionBuilder: (c, a) => ScaleTransition(
                        scale: CurvedAnimation(
                            parent: a, curve: Curves.easeOutBack),
                        child: FadeTransition(opacity: a, child: c),
                      ),
                      child: Container(
                        key: ValueKey(sent),
                        height: 34,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: sent ? _ok : AuthPalette.emerald,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black
                                  .withValues(alpha: .28),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              sent
                                  ? Icons.check_rounded
                                  : Icons.send_rounded,
                              size: 15,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              sent
                                  ? 'guide.scene.quoteSent'.tr
                                  : 'guide.scene.sendQuote'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Buyer review toast.
            if (sent)
              Positioned(
                right: 6,
                top: -2,
                child: Transform.scale(
                  scale: Curves.easeOutBack
                      .transform(((t - .78) / .22).clamp(0.0, 1.0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .25),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.thumb_up_rounded, size: 13, color: _ok),
                        const SizedBox(width: 5),
                        Text(
                          'guide.scene.inReview'.tr,
                          style: const TextStyle(
                            color: _ink,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

/// I4 — acceptance notification drops in and the order pipeline fills.
class WinOrderScene extends StatelessWidget {
  const WinOrderScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 7),
      builder: (context, t) {
        final drop =
            Curves.elasticOut.transform((t / .4).clamp(0.0, 1.0));
        final rise = Curves.easeOutCubic
            .transform(((t - .25) / .4).clamp(0.0, 1.0));
        final stage = ((t - .35) / .6).clamp(0.0, 1.0) * 3;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Acceptance notification.
            Positioned(
              left: 28,
              right: 28,
              top: -70 + 84 * drop,
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 13),
                decoration: BoxDecoration(
                  color: _ink,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .35),
                      blurRadius: 22,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                        color: _ok,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.celebration_rounded,
                          size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'guide.scene.quoteAccepted'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Order #EM-2417 · ETB 17,900',
                            style: TextStyle(
                              color: Color(0xFFBFBFBF),
                              fontSize: 10.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Order pipeline card.
            Positioned(
              left: 30,
              right: 30,
              bottom: 22 - (1 - rise) * 44,
              child: Opacity(
                opacity: rise,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                  decoration: _whiteCard(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'guide.scene.orderProgress'.tr,
                            style: const TextStyle(
                              color: _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'ETB 17,900',
                            style: TextStyle(
                              color: _ink,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          for (var i = 0; i < 3; i++) ...[
                            _StageDot(
                              label: [
                                'guide.scene.stConfirmed'.tr,
                                'guide.scene.stPreparing'.tr,
                                'guide.scene.stShipped'.tr,
                              ][i],
                              progress: (stage - i).clamp(0.0, 1.0),
                            ),
                            if (i != 2)
                              Expanded(
                                child: Stack(
                                  children: [
                                    Container(
                                      height: 3,
                                      margin:
                                          const EdgeInsets.only(bottom: 22),
                                      decoration: BoxDecoration(
                                        color: _soft,
                                        borderRadius:
                                            BorderRadius.circular(3),
                                      ),
                                    ),
                                    FractionallySizedBox(
                                      alignment: Alignment.centerLeft,
                                      widthFactor:
                                          (stage - i - 1).clamp(0.0, 1.0),
                                      child: Container(
                                        height: 3,
                                        margin: const EdgeInsets.only(
                                            bottom: 22),
                                        decoration: BoxDecoration(
                                          color: _ok,
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                      ),
                                    ),
                                  ],
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
          ],
        );
      },
    );
  }
}

class _StageDot extends StatelessWidget {
  const _StageDot({required this.label, required this.progress});
  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final reached = progress > 0;
    final full = progress >= 1;
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: reached ? _ok : _soft,
            border: Border.all(
              color: reached ? _ok : _softBorder,
              width: 1.6,
            ),
            boxShadow: [
              if (reached)
                BoxShadow(
                  color: _ok.withValues(alpha: .35),
                  blurRadius: 10,
                ),
            ],
          ),
          child: full
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: reached ? _ink : _muted,
            fontSize: 9.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

final _importerRoute = _Track(Path()
  ..moveTo(38, 90)
  ..cubicTo(120, 30, 130, 220, 258, 150));

/// I5 — fulfilment: truck runs the route, rating stars and payout land.
class FulfilScene extends StatelessWidget {
  const FulfilScene({super.key});

  @override
  Widget build(BuildContext context) {
    return SceneLooper(
      duration: const Duration(seconds: 9),
      builder: (context, t) {
        final u =
            Curves.easeInOutCubic.transform((t / .7).clamp(0.0, 1.0));
        final pos = _importerRoute.metric
            .getTangentForOffset(_importerRoute.metric.length * u)!
            .position;
        final arrived = t > .7;
        final stars = arrived
            ? Curves.easeOutBack
                .transform(((t - .72) / .28).clamp(0.0, 1.0))
            : 0.0;
        final payout = arrived
            ? Curves.easeOutBack
                .transform(((t - .82) / .18).clamp(0.0, 1.0))
            : 0.0;
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(painter: TrackPainter(_importerRoute, u)),
            ),
            // Warehouse pin.
            Positioned(
              left: 38 - 21,
              top: 90 - 21,
              child: Container(
                width: 42,
                height: 42,
                decoration: _whiteCard(21, shadow: .2),
                child: const Icon(Icons.warehouse_rounded,
                    size: 21, color: _ink),
              ),
            ),
            // Buyer pin.
            Positioned(
              left: 258 - 21,
              top: 150 - 21,
              child: Container(
                width: 42,
                height: 42,
                decoration: _whiteCard(21, shadow: .2),
                child: const Icon(Icons.storefront_rounded,
                    size: 21, color: _ink),
              ),
            ),
            // Truck.
            Positioned(
              left: pos.dx - 19,
              top: pos.dy - 19,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: .55),
                      blurRadius: 18,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.local_shipping_rounded,
                    size: 20, color: _ink),
              ),
            ),
            // Rating stars.
            if (stars > 0)
              Positioned(
                left: 186,
                top: 40,
                child: Transform.scale(
                  scale: stars,
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.star_rounded,
                          size: 22, color: AppColors.warning),
                      SizedBox(width: 2),
                      Icon(Icons.star_rounded,
                          size: 22, color: AppColors.warning),
                      SizedBox(width: 2),
                      Icon(Icons.star_rounded,
                          size: 22, color: AppColors.warning),
                      SizedBox(width: 2),
                      Icon(Icons.star_border_rounded,
                          size: 22, color: AppColors.warning),
                    ],
                  ),
                ),
              ),
            // Payout chip.
            if (payout > 0)
              Positioned(
                left: 56,
                bottom: 44,
                child: Transform.scale(
                  scale: payout,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _ok,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.payments_rounded,
                            size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'guide.scene.fundsReleased'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Delivered chip.
            if (arrived)
              Positioned(
                right: 22,
                bottom: 20,
                child: _MiniChip(
                  Icons.check_circle_rounded,
                  'guide.scene.deliveredConfirmed'.tr,
                  fg: Colors.white,
                  bg: AuthPalette.emeraldMid,
                ),
              ),
          ],
        );
      },
    );
  }
}
