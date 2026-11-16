
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile/core/widgets/pro/pro_inputs.dart';
import '../../constants/auth_palette.dart';
export 'pro_inputs.dart';
export '../../../features/auth/widgets/password_strength_meter.dart';


class ProPage extends StatefulWidget {
  const ProPage({
    super.key,
    required this.title,
    required this.body,
    this.eyebrow,
    this.subtitle,
    this.art,
    this.heroExtra,
    this.actions = const [],
    this.showBack = false,
    this.onBack,
    this.onRefresh,
    this.bottomBar,
    this.heroHeight = 250,
    this.fab,
  });

  final String title;
  final String? eyebrow;
  final String? subtitle;
  final Widget? art;
  final Widget? heroExtra;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;
  final Future<void> Function()? onRefresh;
  final Widget body;
  final Widget? bottomBar;
  final double heroHeight;
  final ProFab? fab;

  @override
  State<ProPage> createState() => _ProPageState();
}

class _ProPageState extends State<ProPage> {
  final _sc = ScrollController();

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final top = MediaQuery.paddingOf(context).top;
    final heroH = widget.heroHeight + top;
    const overlap = 30.0;
    const barH = 56.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        bottomNavigationBar: widget.bottomBar,
        body: LayoutBuilder(
          builder: (context, box) {
            final sheetMin = math.max(0.0, box.maxHeight - (heroH - overlap));
            final bottomPad = widget.bottomBar == null
                ? MediaQuery.paddingOf(context).bottom
                : 0.0;

            Widget scroll = SingleChildScrollView(
              controller: _sc,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  SizedBox(height: heroH - overlap),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: sheetMin),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: .16),
                            blurRadius: 28,
                            offset: const Offset(0, -8),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.fromLTRB(20, 24, 20, 28 + bottomPad),
                      child: widget.body,
                    ),
                  ),
                ],
              ),
            );

            if (widget.onRefresh != null) {
              scroll = RefreshIndicator(
                onRefresh: widget.onRefresh!,
                edgeOffset: top + barH,
                color: scheme.primary,
                backgroundColor: scheme.surface,
                child: scroll,
              );
            }

            return Stack(
              children: [
                // Parallax hero.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: heroH + 60,
                  child: AnimatedBuilder(
                    animation: _sc,
                    builder: (context, _) {
                      final off = _sc.hasClients ? _sc.offset : 0.0;
                      final o = off.clamp(0.0, heroH);
                      final over = off < 0 ? -off : 0.0;
                      final fade = (1 - o / (heroH * .5)).clamp(0.0, 1.0);
                      return Transform.translate(
                        offset: Offset(0, -o * .4),
                        child: Transform.scale(
                          scale: 1 + over / 600,
                          alignment: Alignment.topCenter,
                          child: _Backdrop(
                            child: Opacity(
                              opacity: fade,
                              child: Stack(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.fromLTRB(
                                      24,
                                      top + barH,
                                      widget.art != null ? 150 : 24,
                                      overlap + 22,
                                    ),
                                    child: Align(
                                      alignment: Alignment.bottomLeft,
                                      child: _HeroText(widget: widget),
                                    ),
                                  ),
                                  if (widget.art != null)
                                    Positioned(
                                      right: 14,
                                      bottom: overlap + 14,
                                      child: widget.art!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                scroll,
                // Collapsing top bar (sits above the scroll view so taps work).
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedBuilder(
                    animation: _sc,
                    builder: (context, _) {
                      final off = _sc.hasClients ? _sc.offset : 0.0;
                      final t =
                      ((off - heroH * .35) / (heroH * .25)).clamp(0.0, 1.0);
                      return SizedBox(
                        height: top + barH,
                        child: Stack(
                          children: [
                            IgnorePointer(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AuthPalette.emeraldDeep
                                      .withValues(alpha: .97 * t),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withValues(alpha: .25 * t),
                                      blurRadius: 14,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  top: top + 7, left: 14, right: 14),
                              child: Row(
                                children: [
                                  if (widget.showBack)
                                    ProIconButton(
                                      icon: Icons.arrow_back_ios_new_rounded,
                                      tooltip: 'common.back'.tr,
                                      onTap: widget.onBack ?? Get.back,
                                    ),
                                  Expanded(
                                    child: IgnorePointer(
                                      child: Opacity(
                                        opacity: t,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12),
                                          child: Text(
                                            widget.title,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  ...widget.actions,
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.widget});
  final ProPage widget;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.eyebrow != null) ...[
          Text(
            widget.eyebrow!.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AuthPalette.mint,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          widget.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            letterSpacing: -.5,
            height: 1.08,
          ),
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: .78),
              height: 1.35,
            ),
          ),
        ],
        if (widget.heroExtra != null) ...[
          const SizedBox(height: 12),
          widget.heroExtra!,
        ],
      ],
    );
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
        painter: _BackdropPainter(),
        child: child,
      ),
    );
  }
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final gc = Offset(s.width * .85, s.height * .3);
    canvas.drawCircle(
      gc,
      s.width * .6,
      Paint()
        ..shader = RadialGradient(
          colors: [AuthPalette.mint.withValues(alpha: .24), Colors.transparent],
        ).createShader(Rect.fromCircle(center: gc, radius: s.width * .6)),
    );
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: .07);
    final rc = Offset(s.width * .95, s.height * .22);
    for (final r in [60.0, 100.0, 140.0]) {
      canvas.drawCircle(rc, r, ring);
    }
    final dot = Paint()..color = Colors.white.withValues(alpha: .14);
    for (var r = 0; r < 4; r++) {
      for (var c = 0; c < 6; c++) {
        canvas.drawCircle(Offset(18 + c * 16, s.height * .34 + r * 16), 1.5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Glass circular button for the hero / top bar.
class ProIconButton extends StatelessWidget {
  const ProIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });
  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? '',
      child: Material(
        color: Colors.white.withValues(alpha: .14),
        shape: CircleBorder(
          side: BorderSide(color: Colors.white.withValues(alpha: .3)),
        ),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: Colors.white, size: 19),
          ),
        ),
      ),
    );
  }
}

/// Glass pill for use inside the hero (status, tags).
class HeroPill extends StatelessWidget {
  const HeroPill({
    super.key,
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .14),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withValues(alpha: .3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14,
              color: AuthPalette.mint,
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sticky action bar. Pass as `ProPage.bottomBar`.
class ProBottomBar extends StatelessWidget {
  const ProBottomBar({super.key, required this.children, this.gap = 10});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(SizedBox(height: gap));
      spaced.add(children[i]);
    }
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .12),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: spaced,
          ),
        ),
      ),
    );
  }
}
