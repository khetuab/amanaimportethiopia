import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/auth_palette.dart';

/// Layered, slowly drifting international-trade hero.
/// Drop a photo at [imageAsset] and it is used automatically; otherwise the
/// painted scene (globe, routes, container ship, waves) is shown.
class TradeHero extends StatefulWidget {
  const TradeHero({
    super.key,
    this.imageAsset = 'assets/images/trade_hero.jpg',
    this.child,
  });

  final String? imageAsset;
  final Widget? child;

  @override
  State<TradeHero> createState() => _TradeHeroState();
}

class _TradeHeroState extends State<TradeHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 20),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final image = widget.imageAsset == null
        ? null
        : Image.asset(
      widget.imageAsset!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        // Ken-Burns style drift (subtle parallax).
        AnimatedBuilder(
          animation: _c,
          child: image,
          builder: (context, img) {
            final d = math.sin(_c.value * 2 * math.pi);
            return Transform.translate(
              offset: Offset(d * 10, d * 5),
              child: Transform.scale(
                scale: 1.12,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CustomPaint(painter: _ScenePainter(_c.value)),
                    if (img != null) img,
                  ],
                ),
              ),
            );
          },
        ),
        // Dark emerald overlay.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0, .45, 1],
              colors: [
                AuthPalette.emerald.withValues(alpha: .25),
                AuthPalette.emeraldDeep.withValues(alpha: .55),
                AuthPalette.emeraldDeep.withValues(alpha: .94),
              ],
            ),
          ),
        ),
        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class _ScenePainter extends CustomPainter {
  _ScenePainter(this.t);
  final double t;

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Offset.zero & s;

    // Base gradient.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0, .45, 1],
          colors: [
            AuthPalette.emeraldMid,
            AuthPalette.emerald,
            AuthPalette.emeraldDeep,
          ],
        ).createShader(rect),
    );

    // Glow + globe wireframe.
    final gc = Offset(s.width * .8, s.height * .24);
    final gr = s.width * .62;
    canvas.drawCircle(
      gc,
      gr,
      Paint()
        ..shader = RadialGradient(
          colors: [AuthPalette.mint.withValues(alpha: .30), Colors.transparent],
        ).createShader(Rect.fromCircle(center: gc, radius: gr)),
    );
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: .09);
    canvas.drawCircle(gc, gr * .8, line);
    for (var i = 1; i <= 4; i++) {
      canvas.drawOval(
        Rect.fromCenter(
          center: gc,
          width: gr * 1.6 * (i / 5),
          height: gr * 1.6,
        ),
        line,
      );
    }
    for (var k = -3; k <= 3; k++) {
      final dy = gr * .8 * k / 4;
      final half = math.sqrt(math.max(0, math.pow(gr * .8, 2) - dy * dy));
      canvas.drawLine(
        Offset(gc.dx - half, gc.dy + dy),
        Offset(gc.dx + half, gc.dy + dy),
        line,
      );
    }

    // Animated trade routes.
    final routes = <List<Offset>>[
      [Offset(s.width * .08, s.height * .50), Offset(s.width * .40, s.height * .12), Offset(s.width * .88, s.height * .30)],
      [Offset(s.width * .15, s.height * .62), Offset(s.width * .55, s.height * .34), Offset(s.width * .92, s.height * .50)],
      [Offset(s.width * .04, s.height * .38), Offset(s.width * .30, s.height * .05), Offset(s.width * .70, s.height * .16)],
    ];
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: .35);
    for (var i = 0; i < routes.length; i++) {
      final r = routes[i];
      final path = Path()
        ..moveTo(r[0].dx, r[0].dy)
        ..quadraticBezierTo(r[1].dx, r[1].dy, r[2].dx, r[2].dy);
      for (final m in path.computeMetrics()) {
        for (double d = 0; d < m.length; d += 14) {
          canvas.drawPath(m.extractPath(d, math.min(d + 6, m.length)), dash);
        }
        final pos = m
            .getTangentForOffset(m.length * ((t + i * .31) % 1))!
            .position;
        canvas.drawCircle(pos, 9,
            Paint()..color = AuthPalette.mint.withValues(alpha: .25));
        canvas.drawCircle(pos, 3.2, Paint()..color = AuthPalette.mint);
        canvas.drawCircle(r[0], 2.5,
            Paint()..color = Colors.white.withValues(alpha: .7));
        canvas.drawCircle(r[2], 2.5,
            Paint()..color = Colors.white.withValues(alpha: .7));
      }
    }

    // Container ship.
    final base = s.height * .74 + math.sin(t * math.pi * 6) * 2;
    final w = s.width * .9;
    final x0 = s.width * .05;
    final hull = Path()
      ..moveTo(x0, base)
      ..lineTo(x0 + w, base)
      ..lineTo(x0 + w * .94, base + s.height * .035)
      ..lineTo(x0 + w * .04, base + s.height * .035)
      ..close();
    canvas.drawPath(
        hull, Paint()..color = AuthPalette.emeraldDeep.withValues(alpha: .9));
    final cw = w * .78 / 7;
    final ch = s.height * .028;
    const cols = [
      AuthPalette.mint,
      Colors.white,
      AuthPalette.emeraldMid,
      Color(0xFFB7F0DC),
    ];
    for (var row = 0; row < 3; row++) {
      for (var col = 0; col < 7 - row; col++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x0 + w * .17 + col * cw + row * cw * .5,
                base - (row + 1) * ch, cw - 3, ch - 2),
            const Radius.circular(2),
          ),
          Paint()
            ..color =
            cols[(row * 3 + col) % cols.length].withValues(alpha: .5),
        );
      }
    }
    canvas.drawRect(
      Rect.fromLTWH(x0 + w * .03, base - ch * 3.4, w * .09, ch * 3.4),
      Paint()..color = AuthPalette.emeraldDeep.withValues(alpha: .95),
    );

    // Waves.
    for (var layer = 0; layer < 2; layer++) {
      final path = Path();
      final wb = base + s.height * .03 + layer * 9;
      path.moveTo(0, s.height);
      for (double x = 0; x <= s.width; x += 6) {
        final y = wb +
            math.sin(x / s.width * 2 * math.pi * (1.5 + layer) +
                t * 2 * math.pi * (layer + 1)) *
                5;
        path.lineTo(x, y);
      }
      path.lineTo(s.width, s.height);
      path.close();
      canvas.drawPath(path,
          Paint()..color = AuthPalette.emeraldDeep.withValues(alpha: .45 + layer * .25));
    }
  }

  @override
  bool shouldRepaint(covariant _ScenePainter old) => old.t != t;
}