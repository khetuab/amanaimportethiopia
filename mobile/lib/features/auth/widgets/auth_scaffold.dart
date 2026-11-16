import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/auth_palette.dart';
import '../../../core/widgets/brand_mark.dart';
import 'trade_hero.dart';

class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.heroHeight = 270,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final double heroHeight;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> {
  final _sc = ScrollController();

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final top = MediaQuery.paddingOf(context).top;
    final heroH = widget.heroHeight + top;
    const overlap = 36.0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // Parallax hero: moves slower than the sheet, fades title on scroll,
            // stretches on iOS overscroll.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroH + 80,
              child: AnimatedBuilder(
                animation: _sc,
                builder: (context, _) {
                  final off = _sc.hasClients ? _sc.offset : 0.0;
                  final o = off.clamp(0.0, heroH);
                  final over = off < 0 ? -off : 0.0;
                  final fade = (1 - o / (heroH * .55)).clamp(0.0, 1.0);
                  return Transform.translate(
                    offset: Offset(0, -o * .4),
                    child: Transform.scale(
                      scale: 1 + over / 500,
                      alignment: Alignment.topCenter,
                      child: TradeHero(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                              24, top + 12, 24, overlap + 80 + 18),
                          child: Opacity(
                            opacity: fade,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (Navigator.of(context).canPop())
                                      _GlassBack(onTap: Get.back),
                                    const Spacer(),
                                    const BrandMark(size: 42, radiusFactor: .31)
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  widget.title,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -.5,
                                  ),
                                )
                                    .animate()
                                    .fadeIn(duration: 500.ms)
                                    .slideX(begin: -.08, end: 0),
                                const SizedBox(height: 6),
                                Text(
                                  widget.subtitle,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white.withValues(alpha: .8),
                                  ),
                                )
                                    .animate(delay: 120.ms)
                                    .fadeIn(duration: 500.ms),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Form sheet sliding over the hero.
            SingleChildScrollView(
              controller: _sc,
              physics: const BouncingScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  SizedBox(height: heroH - overlap),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(32)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .18),
                          blurRadius: 30,
                          offset: const Offset(0, -8),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.fromLTRB(
                      24,
                      28,
                      24,
                      28 + MediaQuery.paddingOf(context).bottom,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: widget.children
                          .animate(interval: 70.ms, delay: 250.ms)
                          .fadeIn(duration: 450.ms, curve: Curves.easeOut)
                          .slideY(
                          begin: .12, end: 0, curve: Curves.easeOutCubic),
                    ),
                  ).animate().slideY(
                    begin: .08,
                    end: 0,
                    duration: 550.ms,
                    curve: Curves.easeOutCubic,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 42, height: 42),

// 2) Add as the LAST child of the Stack (after the SingleChildScrollView):
            if (Navigator.of(context).canPop())
              Positioned(
                top: top + 12,
                left: 24,
                child: AnimatedBuilder(
                  animation: _sc,
                  builder: (_, child) {
                    final o = _sc.hasClients ? _sc.offset : 0.0;
                    return Opacity(
                      opacity: (1 - o / 60).clamp(0.0, 1.0),
                      child: IgnorePointer(ignoring: o > 40, child: child),
                    );
                  },
                  child: _GlassBack(onTap: Get.back),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _GlassBack extends StatelessWidget {
  const _GlassBack({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .14),
      shape: CircleBorder(
        side: BorderSide(color: Colors.white.withValues(alpha: .3)),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 42,
          height: 42,
          child: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 18),
        ),
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: const LinearGradient(
          colors: [AuthPalette.mint, AuthPalette.emeraldMid],
        ),
      ),
      child: const Text(
        'ኢ',
        style: TextStyle(
          color: AuthPalette.emeraldDeep,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
    );
  }
}