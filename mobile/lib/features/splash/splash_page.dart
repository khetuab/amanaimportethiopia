import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../core/constants/auth_palette.dart';
import '../auth/widgets/trade_hero.dart';
import 'splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  static const String _title = 'Ethio Import';

  @override
  Widget build(BuildContext context) {
    // Touch the controller so GetX instantiates it (it drives navigation).
    // ignore: unused_local_variable
    final splashController = controller;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AuthPalette.emeraldDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const TradeHero(),
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  const SplashBoat(size: 240),
                  const SizedBox(height: 22),
                  _buildTitle(),
                  const SizedBox(height: 10),
                  Text(
                    'splash.tagline'.tr,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: .82),
                      fontSize: 14.5,
                      letterSpacing: .6,
                    ),
                  ).animate(delay: 3450.ms).fadeIn(duration: 800.ms),
                  const Spacer(flex: 3),
                  const _Dots().animate(delay: 3900.ms).fadeIn(),
                  const SizedBox(height: 44),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// "Ethio" in bold white, "Import" in light mint, letters rising one by one.
  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(_title.length, (i) {
        final isImport = i >= 6;
        return Text(
          _title[i],
          style: TextStyle(
            color: isImport ? AuthPalette.mint : Colors.white,
            fontSize: 34,
            fontWeight: isImport ? FontWeight.w300 : FontWeight.w800,
            letterSpacing: 1.4,
          ),
        )
            .animate(delay: (1950 + i * 90).ms)
            .fadeIn(duration: 500.ms)
            .slideY(begin: .6, end: 0, curve: Curves.easeOutCubic);
      }),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(
            color: AuthPalette.mint,
            shape: BoxShape.circle,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(
          begin: .5,
          end: 1,
          delay: (i * 160).ms,
          duration: 480.ms,
          curve: Curves.easeInOut,
        )
            .fade(
          begin: .35,
          end: 1,
          delay: (i * 160).ms,
          duration: 480.ms,
        );
      }),
    );
  }
}


/// Animated sailboat (the Ethio Import logo) drawn with a CustomPainter.
///
/// Intro (~2.4s):
///  1. Hull glides in with a little overshoot, leaving a foam wake
///  2. It settles with a damped sway, rings ripple out from the waterline
///  3. Main sail unfurls with a soft feathered wipe, jib swings up after it
///  4. A light sheen sweeps across the sails once
/// Afterwards: boat rocks, sails breathe in the wind (out of phase with the
/// hull), waves roll and sparkles drift upward — forever.
class SplashBoat extends StatefulWidget {
  const SplashBoat({
    super.key,
    this.size = 240,
    this.color = Colors.white,
    this.glow = const Color(0xFF818181),
  });

  final double size;
  final Color color;
  final Color glow;

  @override
  State<SplashBoat> createState() => _SplashBoatState();
}

class _SplashBoatState extends State<SplashBoat> with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..forward();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_intro, _loop]),
          builder: (_, __) => CustomPaint(
            painter: _BoatPainter(
              t: _intro.value,
              loop: _loop.value,
              color: widget.color,
              glow: widget.glow,
            ),
          ),
        ),
      ),
    );
  }
}

class _BoatPainter extends CustomPainter {
  _BoatPainter({
    required this.t,
    required this.loop,
    required this.color,
    required this.glow,
  });

  final double t; // intro progress 0..1
  final double loop; // endless loop 0..1
  final Color color;
  final Color glow;

  // Logo is drawn in a 1130 x 1130 space and scaled to fit.
  static const double _s = 1130;
  static const double _tau = math.pi * 2;

  static final Path _mainSail = Path()
    ..moveTo(465, 75)
    ..cubicTo(500, 80, 600, 160, 650, 215)
    ..cubicTo(780, 350, 860, 500, 862, 700)
    ..lineTo(863, 765)
    ..cubicTo(750, 780, 520, 820, 340, 905)
    ..lineTo(305, 920)
    ..cubicTo(340, 860, 440, 760, 480, 520)
    ..cubicTo(505, 380, 505, 230, 465, 75)
    ..close();

  static final Path _jib = Path()
    ..moveTo(213, 188)
    ..cubicTo(260, 190, 380, 240, 443, 288)
    ..lineTo(443, 370)
    ..cubicTo(443, 520, 410, 650, 335, 790)
    ..cubicTo(345, 700, 345, 600, 340, 520)
    ..cubicTo(330, 400, 290, 300, 213, 188)
    ..close();

  static final Path _hull = Path()
    ..moveTo(1002, 790)
    ..cubicTo(700, 815, 400, 880, 175, 1030)
    ..cubicTo(250, 1040, 350, 1030, 450, 1010)
    ..cubicTo(600, 985, 700, 980, 790, 1005)
    ..cubicTo(830, 1015, 845, 1010, 880, 980)
    ..cubicTo(940, 940, 975, 860, 1002, 790)
    ..close();

  static final Rect _mainBounds = _mainSail.getBounds();
  static final Rect _jibBounds = _jib.getBounds();

  // x, y, radius, phase offset
  static const List<List<double>> _sparkles = [
    [180, 330, 7, 0.00],
    [985, 430, 6, 0.15],
    [120, 640, 5, 0.30],
    [1005, 660, 8, 0.45],
    [270, 150, 6, 0.60],
    [905, 190, 5, 0.75],
    [60, 430, 4, 0.90],
    [770, 110, 6, 0.50],
  ];

  double _iv(double a, double b, [Curve c = Curves.easeOutCubic]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _s);

    _paintGlow(canvas);
    _paintSparkles(canvas);
    _paintWater(canvas);
    _paintRipples(canvas);

    // ---- Boat group: arrival sway + endless rocking ----
    final settle = _iv(0.3, 0.6);
    final u = ((t - 0.3) / 0.7).clamp(0.0, 1.0);
    final arrivalSway = math.exp(-5 * u) * math.sin(u * 14) * 0.05;
    final tilt = arrivalSway + math.sin(loop * _tau + 0.6) * 0.022 * settle;
    final bob = math.sin(loop * _tau) * 9 * settle;

    canvas.save();
    canvas.translate(560, 900);
    canvas.rotate(tilt);
    canvas.translate(-560, -900 + bob);

    _paintHull(canvas);
    _paintMainSail(canvas, settle);
    _paintJib(canvas, settle);

    canvas.restore();
  }

  // ---------------------------------------------------------------- glow
  void _paintGlow(Canvas canvas) {
    final glowP = _iv(0.0, 0.5, Curves.easeOut);
    final pulse = 0.85 + 0.15 * math.sin(loop * _tau);
    const center = Offset(_s / 2, _s * 0.55);
    canvas.drawCircle(
      center,
      _s * 0.5,
      Paint()
        ..shader = RadialGradient(
          colors: [
            glow.withValues(alpha: 0.30 * glowP * pulse),
            glow.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: _s * 0.5)),
    );
  }

  // ------------------------------------------------------------ sparkles
  void _paintSparkles(Canvas canvas) {
    final fade = _iv(0.4, 0.8);
    if (fade <= 0) return;
    final paint = Paint();
    for (final sp in _sparkles) {
      final p = (loop + sp[3]) % 1.0;
      final life = math.sin(math.pi * p);
      paint.color = glow.withValues(alpha: (0.55 * life * fade).clamp(0.0, 1.0));
      canvas.drawCircle(
        Offset(sp[0], sp[1] - p * 220),
        sp[2] * (0.6 + 0.4 * life),
        paint,
      );
    }
  }

  // --------------------------------------------------------------- water
  void _paintWater(Canvas canvas) {
    final waveP = _iv(0.1, 0.45);
    if (waveP <= 0) return;

    // Soft filled swell behind the hull for depth.
    final phase0 = loop * _tau;
    final fill = Path()..moveTo(60, 1130);
    for (var x = 60.0; x <= 1070; x += 10) {
      fill.lineTo(x, 1068 + math.sin(x / 70 + phase0) * 10);
    }
    fill
      ..lineTo(1070, 1130)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            glow.withValues(alpha: 0.20 * waveP),
            glow.withValues(alpha: 0),
          ],
        ).createShader(const Rect.fromLTWH(0, 1050, _s, 80)),
    );

    // Crisp wave lines.
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9
      ..color = glow.withValues(alpha: 0.45 * waveP);
    for (var i = 0; i < 3; i++) {
      final y = 1058.0 + i * 26;
      final phase = loop * _tau * (i.isEven ? 1 : -1);
      final x0 = 200.0 + i * 40;
      final x1 = 940.0 - i * 40;
      final path = Path()..moveTo(x0, y + math.sin(x0 / 60 + phase) * 7);
      for (var x = x0; x <= x1; x += 10) {
        path.lineTo(x, y + math.sin(x / 60 + phase) * 7);
      }
      canvas.drawPath(path, wave);
    }
  }

  // ------------------------------------------------------------- ripples
  void _paintRipples(Canvas canvas) {
    final fade = _iv(0.3, 0.6);
    if (fade <= 0) return;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    for (var i = 0; i < 3; i++) {
      final p = (loop + i / 3) % 1.0;
      ring.color = glow.withValues(alpha: ((1 - p) * 0.30 * fade).clamp(0.0, 1.0));
      canvas.drawOval(
        Rect.fromCenter(
          center: const Offset(590, 1048),
          width: 360 + p * 560,
          height: 30 + p * 70,
        ),
        ring,
      );
    }
  }

  // ---------------------------------------------------------------- hull
  void _paintHull(Canvas canvas) {
    final move = _iv(0.0, 0.34, Curves.easeOutBack);
    final linear = _iv(0.0, 0.34, Curves.linear);
    final alpha = _iv(0.0, 0.14, Curves.easeOut);
    final dx = -(1 - move) * 520;

    // Foam wake trailing behind the sliding hull.
    final wakeAlpha = (math.sin(linear * math.pi) * 0.55).clamp(0.0, 1.0);
    if (wakeAlpha > 0) {
      final tipX = 175 + dx;
      final wake = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6;
      for (var j = 0; j < 3; j++) {
        final y = 1030.0 + j * 14;
        final len = 240.0 - j * 50;
        wake.shader = LinearGradient(
          colors: [
            glow.withValues(alpha: 0),
            glow.withValues(alpha: wakeAlpha),
          ],
        ).createShader(Rect.fromLTWH(tipX - len, y - 4, len, 8));
        canvas.drawLine(Offset(tipX - len, y), Offset(tipX, y), wake);
      }
    }

    canvas.save();
    canvas.translate(dx, 0);

    // Soft shadow/glow on the water under the hull.
    canvas.drawPath(
      _hull.shift(const Offset(0, 18)),
      Paint()
        ..color = glow.withValues(alpha: 0.22 * alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    canvas.drawPath(
      _hull,
      Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..color = color.withValues(alpha: alpha),
    );
    canvas.restore();
  }

  // --------------------------------------------------------------- sails
  void _paintMainSail(Canvas canvas, double settle) {
    final reveal = _iv(0.22, 0.64, Curves.easeInOutCubic);
    if (reveal <= 0) return;

    canvas.save();
    // Slides in slightly while unfurling.
    canvas.translate((1 - reveal) * 40, 0);
    // Wind breathing: sway around the base of the sail.
    canvas.translate(600, 910);
    canvas.rotate(math.sin(loop * _tau + 1.3) * 0.014 * settle);
    canvas.scale(1 + 0.006 * math.sin(loop * _tau + 0.4) * settle, 1);
    canvas.translate(-600, -910);

    _drawSail(canvas, _mainSail, _mainBounds, reveal, shine: true);
    canvas.restore();
  }

  void _paintJib(Canvas canvas, double settle) {
    final reveal = _iv(0.4, 0.78, Curves.easeInOutCubic);
    if (reveal <= 0) return;

    canvas.save();
    // Swings up from the deck.
    canvas.translate(443, 790);
    canvas.rotate((1 - reveal) * -0.18);
    // The jib flutters a bit more than the main sail, out of phase.
    canvas.rotate(math.sin(loop * _tau + 2.6) * 0.02 * settle);
    canvas.translate(-443, -790);

    _drawSail(canvas, _jib, _jibBounds, reveal, shine: true);
    canvas.restore();
  }

  /// Draws one sail with a tinted gradient fill, a feathered bottom-to-top
  /// reveal mask and (once the sails are out) a diagonal sheen.
  void _drawSail(
      Canvas canvas,
      Path path,
      Rect bounds,
      double reveal, {
        required bool shine,
      }) {
    final layerRect = bounds.inflate(60);

    canvas.saveLayer(layerRect, Paint());

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color, Color.lerp(color, glow, 0.5)!],
        ).createShader(bounds),
    );

    // Sheen sweeping once across, clipped to the sail.
    final p = _iv(0.8, 1.0, Curves.easeInOut);
    if (shine && p > 0 && p < 1) {
      canvas.save();
      canvas.clipPath(path);
      final x = -100 + p * 1200;
      final band = Path()
        ..moveTo(x, 0)
        ..lineTo(x + 110, 0)
        ..lineTo(x + 110 - 300, _s)
        ..lineTo(x - 300, _s)
        ..close();
      canvas.drawPath(
        band,
        Paint()..color = Colors.white.withValues(alpha: 0.55 * math.sin(math.pi * p)),
      );
      canvas.restore();
    }

    // Feathered reveal: opaque below the front, fading out above it.
    const feather = 0.3;
    final front = reveal * (1 + feather);
    final a = (front - feather).clamp(0.0, 1.0);
    final b = front.clamp(0.0, 1.0);
    canvas.drawRect(
      layerRect,
      Paint()
        ..blendMode = BlendMode.dstIn
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: const [Colors.white, Colors.white, Colors.transparent, Colors.transparent],
          stops: [0.0, a, b, 1.0],
        ).createShader(layerRect),
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoatPainter old) =>
      old.t != t ||
          old.loop != loop ||
          old.color != color ||
          old.glow != glow;
}