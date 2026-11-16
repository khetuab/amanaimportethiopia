import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';

import '../../routes/app_routes.dart';

/// Animated splash for "Ethio Import".
/// Sequence (≈3.2s):
///  1. Hull glides in from the left over rippling water
///  2. Main sail unfurls upward, then the jib sail follows
///  3. Boat keeps gently rocking on the waves
///  4. "Ethio Import" letters rise in one by one, tagline fades in
///  5. [onFinished] is called -> navigate to your home/login screen
class EthioSplashScreen extends StatefulWidget {
  const EthioSplashScreen({super.key, required this.onFinished});

  final VoidCallback onFinished;

  @override
  State<EthioSplashScreen> createState() => _EthioSplashScreenState();
}

class _EthioSplashScreenState extends State<EthioSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _loop;

  static const _bg = Color(0xFFF7F5EF);
  static const _ink = Color(0xFF111111);
  static const _accent = Color(0xFF078930); // Ethiopian green

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();

    _intro.forward().whenComplete(() async {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      if (mounted) widget.onFinished();
    });
  }

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  static double _iv(double t, double a, double b,
      [Curve curve = Curves.easeOutCubic]) {
    return curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));
  }

  @override
  Widget build(BuildContext context) {
    const title = 'Ethio Import';

    return Scaffold(
      backgroundColor: _bg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _loop]),
                builder: (_, __) => CustomPaint(
                  painter: _BoatPainter(
                    t: _intro.value,
                    loop: _loop.value,
                    color: _ink,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            AnimatedBuilder(
              animation: _intro,
              builder: (_, __) {
                final letters = <Widget>[];
                for (var i = 0; i < title.length; i++) {
                  final start = 0.55 + i * 0.025;
                  final p = _iv(_intro.value, start, start + 0.18);
                  final isImport = i >= 6;
                  letters.add(
                    Opacity(
                      opacity: p,
                      child: Transform.translate(
                        offset: Offset(0, (1 - p) * 22),
                        child: Text(
                          title[i],
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight:
                            isImport ? FontWeight.w300 : FontWeight.w800,
                            letterSpacing: 1.5,
                            color: isImport ? _accent : _ink,
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: letters,
                );
              },
            ),
            const SizedBox(height: 10),
            AnimatedBuilder(
              animation: _intro,
              builder: (_, __) {
                final p = _iv(_intro.value, 0.82, 1.0, Curves.easeIn);
                return Opacity(
                  opacity: p,
                  child: Text(
                    'Sail your trade across borders',
                    style: TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: _ink.withOpacity(0.55),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BoatPainter extends CustomPainter {
  _BoatPainter({required this.t, required this.loop, required this.color})
      : super();

  final double t; // intro progress 0..1
  final double loop; // repeating 0..1
  final Color color;

  // Logo drawn in a 1130 x 1130 coordinate space.
  static const double _s = 1130;

  static Path _mainSail() => Path()
    ..moveTo(465, 75)
    ..cubicTo(500, 80, 600, 160, 650, 215)
    ..cubicTo(780, 350, 860, 500, 862, 700)
    ..lineTo(863, 765)
    ..cubicTo(750, 780, 520, 820, 340, 905)
    ..lineTo(305, 920)
    ..cubicTo(340, 860, 440, 760, 480, 520)
    ..cubicTo(505, 380, 505, 230, 465, 75)
    ..close();

  static Path _jib() => Path()
    ..moveTo(213, 188)
    ..cubicTo(260, 190, 380, 240, 443, 288)
    ..lineTo(443, 370)
    ..cubicTo(443, 520, 410, 650, 335, 790)
    ..cubicTo(345, 700, 345, 600, 340, 520)
    ..cubicTo(330, 400, 290, 300, 213, 188)
    ..close();

  static Path _hull() => Path()
    ..moveTo(1002, 790)
    ..cubicTo(700, 815, 400, 880, 175, 1030)
    ..cubicTo(250, 1040, 350, 1030, 450, 1010)
    ..cubicTo(600, 985, 700, 980, 790, 1005)
    ..cubicTo(830, 1015, 845, 1010, 880, 980)
    ..cubicTo(940, 940, 975, 860, 1002, 790)
    ..close();

  double _iv(double a, double b, [Curve c = Curves.easeOutCubic]) =>
      c.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

  @override
  void paint(Canvas canvas, Size size) {
    final k = size.width / _s;
    canvas.scale(k);

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    // --- Water ripples ---
    final waveP = _iv(0.1, 0.45);
    final wave = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 9
      ..color = color.withOpacity(0.18 * waveP);
    for (var i = 0; i < 3; i++) {
      final y = 1060.0 + i * 26;
      final path = Path();
      final phase = loop * 2 * math.pi * (i.isEven ? 1 : -1);
      final x0 = 200.0 + i * 40;
      final x1 = 940.0 - i * 40;
      path.moveTo(x0, y + math.sin(phase) * 6);
      for (var x = x0; x <= x1; x += 10) {
        path.lineTo(x, y + math.sin(x / 60 + phase) * 7);
      }
      canvas.drawPath(path, wave);
    }

    // --- Rocking motion for whole boat ---
    final bob = math.sin(loop * 2 * math.pi) * 9 * _iv(0.3, 0.6);
    final tilt = math.sin(loop * 2 * math.pi + 0.6) * 0.022 * _iv(0.3, 0.6);
    canvas.save();
    canvas.translate(560, 900);
    canvas.rotate(tilt);
    canvas.translate(-560, -900 + bob);

    // --- Hull glides in ---
    final h = _iv(0.0, 0.32);
    canvas.save();
    canvas.translate(-(1 - h) * 520, 0);
    paint.color = color.withOpacity(h);
    canvas.drawPath(_hull(), paint);
    canvas.restore();

    // --- Main sail unfurls upward from the deck ---
    final s = _iv(0.22, 0.62);
    if (s > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, _s * (1 - s), _s, _s));
      canvas.translate((1 - s) * 40, 0);
      paint.color = color;
      canvas.drawPath(_mainSail(), paint);
      canvas.restore();
    }

    // --- Jib follows with a soft swing ---
    final j = _iv(0.4, 0.75);
    if (j > 0) {
      canvas.save();
      canvas.clipRect(Rect.fromLTRB(0, _s * (1 - j), _s, _s));
      // swing around the mast side of the jib
      canvas.translate(443, 790);
      canvas.rotate((1 - j) * -0.18);
      canvas.translate(-443, -790);
      paint.color = color;
      canvas.drawPath(_jib(), paint);
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _BoatPainter old) =>
      old.t != t || old.loop != loop || old.color != color;
}




class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return EthioSplashScreen(
      onFinished: () {
        // Use whatever your existing splash controller decided:
        // e.g. logged in -> home, otherwise -> login/onboarding.
        Get.offAllNamed(AppRoutes.onboarding); // replace with your route
      },
    );
  }
}