import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_palette.dart';
import '../../core/widgets/brand_mark.dart';
import 'guide_data.dart';
import 'guide_scenes.dart';

/// Fifth shell tab: an animated, illustrated walkthrough of the whole app,
/// tailored per role (buyer / importer) with a Contact Us card and the
/// Tixolve credit at the bottom.
class GuideTab extends StatefulWidget {
  const GuideTab({super.key, required this.isBuyer});

  /// Which role the shell belongs to — buyers see the buyer walkthrough,
  /// importers the importer one. Passed from the shell, never switchable.
  final bool isBuyer;

  @override
  State<GuideTab> createState() => _GuideTabState();
}

class _GuideTabState extends State<GuideTab>
    with SingleTickerProviderStateMixin {
  /// Fixed for the lifetime of this tab — buyers are locked to the buyer
  /// walkthrough, importers to the importer one (no in-guide switch).
  bool get _buyerMode => widget.isBuyer;

  final PageController _page = PageController();
  int _index = 0;

  final Set<int> _seen = <int>{};

  /// Replays the staggered entrance of the active slide on every landing.
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
    value: 0,
  );

  List<GuideStep> get _steps =>
      _buyerMode ? buyerGuideSteps : importerGuideSteps;

  @override
  void initState() {
    super.initState();
    _entrance.forward();
  }

  @override
  void dispose() {
    _page.dispose();
    _entrance.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    HapticFeedback.selectionClick();
    setState(() {
      _index = i;
      if (i < _steps.length) _seen.add(i);
    });
    _entrance.forward(from: 0);
  }

  void _next(int total) {
    if (_index < total - 1) {
      _page.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeOutCubic,
      );
    } else {
      _page.animateToPage(
        0,
        duration: const Duration(milliseconds: 460),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _copy(BuildContext context, String label, String value) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('guide.copied'.trParams({'label': label})),
        ),
      );
  }

  double _pos() {
    if (_page.hasClients && _page.position.haveDimensions) {
      return _page.page ?? _index.toDouble();
    }
    return _index.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final steps = _steps;
    final total = steps.length + 1; // + finale (contact) slide
    final done = _seen.length >= steps.length;

    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: _page,
        builder: (context, _) {
          final pos = _pos();
          return Column(
            children: [
              _HeroCard(
                pos: pos,
                buyerMode: _buyerMode,
                seenCount: _seen.length,
                stepCount: steps.length,
                done: done,
              ),
              Expanded(
                child: PageView.builder(
                  controller: _page,
                  itemCount: total,
                  onPageChanged: _onPageChanged,
                  itemBuilder: (context, i) {
                    if (i < steps.length) {
                      return _StepSlide(
                        step: steps[i],
                        index: i,
                        total: total,
                        pos: pos,
                        entrance: _entrance,
                        isActive: i == _index,
                      );
                    }
                    return _FinaleSlide(
                      steps: steps,
                      finale: _buyerMode ? buyerFinale : importerFinale,
                      seen: _seen,
                      entrance: _entrance,
                      isActive: i == _index,
                      onCopy: (label, value) => _copy(context, label, value),
                    );
                  },
                ),
              ),
              _Controls(
                index: _index,
                total: total,
                onPrev: () => _page.previousPage(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                ),
                onDot: (i) => _page.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutCubic,
                ),
                onNext: () => _next(total),
              ),
              _FooterCredit(scheme: scheme),
            ],
          );
        },
      ),
    );
  }
}

// ───────────────────────── Hero header ─────────────────────────

const _ink = Color(0xFF111111);

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.pos,
    required this.buyerMode,
    required this.seenCount,
    required this.stepCount,
    required this.done,
  });

  final double pos;
  final bool buyerMode;
  final int seenCount;
  final int stepCount;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0, .5, 1],
            colors: [
              AuthPalette.emeraldDeep,
              AuthPalette.emerald,
              AuthPalette.emeraldMid,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: PanelDecoPainter(pos * .8)),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const BrandMark(size: 40, radiusFactor: .32),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              buyerMode
                                  ? 'guide.badgeBuyer'.tr
                                  : 'guide.badgeImporter'.tr,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: .65),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'guide.heroTitle'.tr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _HeroProgress(
                    seen: seenCount,
                    total: stepCount,
                    done: done,
                  ),
                ],
              )
                  .animate()
                  .fadeIn(duration: 420.ms)
                  .slideY(begin: .08, curve: Curves.easeOutCubic),
            ],
          ),
        ),
      ),
    )
        .animate(delay: 60.ms)
        .fadeIn(duration: 380.ms)
        .slideY(begin: -.06, curve: Curves.easeOutCubic);
  }
}

class _HeroProgress extends StatelessWidget {
  const _HeroProgress({
    required this.seen,
    required this.total,
    required this.done,
  });

  final int seen;
  final int total;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final frac = total == 0 ? 0.0 : (seen / total).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'guide.progress'.trParams(
                {'seen': '$seen', 'total': '$total'},
              ),
              style: TextStyle(
                color: Colors.white.withValues(alpha: .72),
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            AnimatedScale(
              scale: done ? 1 : 0,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, size: 12, color: _ink),
                    SizedBox(width: 4),
                    Text(
                      'guide.allSet'.tr,
                      style: TextStyle(
                        color: _ink,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        SizedBox(
          height: 5,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .18),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(end: frac),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutCubic,
                builder: (_, t, __) => FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: t,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: .5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ───────────────────────── Step slide ─────────────────────────

class _StepSlide extends StatelessWidget {
  const _StepSlide({
    required this.step,
    required this.index,
    required this.total,
    required this.pos,
    required this.entrance,
    required this.isActive,
  });

  final GuideStep step;
  final int index;
  final int total;
  final double pos;
  final Animation<double> entrance;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final delta = (pos - index).clamp(-1.0, 1.0);
    final a = delta.abs();

    return Column(
      children: [
        // Illustrated animated panel.
        LayoutBuilder(
          builder: (context, c) {
            final h = (c.maxHeight * .52).clamp(210.0, 340.0);
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Container(
                height: h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, .5, 1],
                    colors: [
                      AuthPalette.emeraldDeep,
                      AuthPalette.emerald,
                      AuthPalette.emeraldMid,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .14),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomPaint(painter: PanelDecoPainter(delta)),
                      Center(
                        child: Transform.translate(
                          offset: Offset(delta * -46, 0),
                          child: Transform.scale(
                            scale: 1 - a * .12,
                            child: Opacity(
                              opacity: 1 - a * .75,
                              child: FittedBox(
                                child: SizedBox(
                                  width: 300,
                                  height: 300,
                                  child: step.scene,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .14),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'guide.stepBadge'
                                .trParams({'n': '${index + 1}'}),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: .92),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: .12),
                          ),
                          child: Icon(step.icon,
                              size: 17,
                              color: Colors.white.withValues(alpha: .92)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Text section.
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Entrance(
                  anim: entrance,
                  enabled: isActive,
                  begin: 0,
                  end: .3,
                  child: Text(
                    'guide.stepOf'.trParams(
                      {'n': '${index + 1}', 'total': '$total'},
                    ),
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: .4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                _Entrance(
                  anim: entrance,
                  enabled: isActive,
                  begin: .08,
                  end: .42,
                  child: Text(
                    step.title.tr,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -.5,
                      height: 1.12,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                _Entrance(
                  anim: entrance,
                  enabled: isActive,
                  begin: .16,
                  end: .52,
                  child: Text(
                    step.body.tr,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurface.withValues(alpha: .72),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                for (var j = 0; j < step.points.length; j++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 9),
                    child: _Entrance(
                      anim: entrance,
                      enabled: isActive,
                      begin: .28 + j * .08,
                      end: .6 + j * .08,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 1),
                            width: 19,
                            height: 19,
                            decoration: BoxDecoration(
                              color: scheme.primary.withValues(alpha: .1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 13,
                              color: scheme.primary,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              step.points[j].tr,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                height: 1.35,
                              ),
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
      ],
    );
  }
}

/// Staggered fade + rise driven by the shared entrance controller.
class _Entrance extends StatelessWidget {
  const _Entrance({
    required this.anim,
    required this.begin,
    required this.end,
    required this.child,
    this.enabled = true,
  });

  final Animation<double> anim;
  final double begin;
  final double end;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    return AnimatedBuilder(
      animation: anim,
      builder: (context, child) {
        final t = Interval(begin, end, curve: Curves.easeOutCubic)
            .transform(anim.value);
        return Opacity(
          opacity: t,
          child:
              Transform.translate(offset: Offset(0, (1 - t) * 14), child: child),
        );
      },
      child: child,
    );
  }
}

// ───────────────────────── Finale slide ─────────────────────────

class _FinaleSlide extends StatelessWidget {
  const _FinaleSlide({
    required this.steps,
    required this.finale,
    required this.seen,
    required this.entrance,
    required this.isActive,
    required this.onCopy,
  });

  final List<GuideStep> steps;
  final GuideFinale finale;
  final Set<int> seen;
  final Animation<double> entrance;
  final bool isActive;
  final void Function(String label, String value) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 8),
      child: Column(
        children: [
          _Entrance(
            anim: entrance,
            enabled: isActive,
            begin: 0,
            end: .3,
            child: Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AuthPalette.emeraldMid,
                    AuthPalette.emeraldDeep,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: .3),
                    blurRadius: 22,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Entrance(
            anim: entrance,
            enabled: isActive,
            begin: .08,
            end: .38,
            child: Text(
              finale.title.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Entrance(
            anim: entrance,
            enabled: isActive,
            begin: .14,
            end: .46,
            child: Text(
              finale.subtitle.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurface.withValues(alpha: .7),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 18),
          _Entrance(
            anim: entrance,
            enabled: isActive,
            begin: .2,
            end: .55,
            child: _RecapCard(steps: steps, seen: seen),
          ),
          const SizedBox(height: 14),
          _Entrance(
            anim: entrance,
            enabled: isActive,
            begin: .28,
            end: .62,
            child: _ContactCard(onCopy: onCopy),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.steps, required this.seen});
  final List<GuideStep> steps;
  final Set<int> seen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: .55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'guide.checklist'.tr,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    width: 21,
                    height: 21,
                    decoration: BoxDecoration(
                      color: seen.contains(i)
                          ? scheme.primary
                          : scheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: seen.contains(i)
                        ? Icon(Icons.check_rounded,
                            size: 14, color: scheme.onPrimary)
                        : Center(
                            child: Text(
                              '${i + 1}',
                              style: TextStyle(
                                color:
                                    scheme.onSurface.withValues(alpha: .55),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 300),
                      style: theme.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: seen.contains(i)
                            ? scheme.onSurface
                            : scheme.onSurface.withValues(alpha: .5),
                      ),
                      child: Text(steps[i].title.tr),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── Contact us ─────────────────────────

class _ContactCard extends StatelessWidget {
  const _ContactCard({required this.onCopy});
  final void Function(String label, String value) onCopy;

  static const _channels = <(IconData, String, String)>[
    (Icons.alternate_email_rounded, 'Email', 'support@tixolve.com'),
    (Icons.call_rounded, 'Phone', '+251 911 234 567'),
    (Icons.send_rounded, 'Telegram', '@tixolve'),
    (Icons.language_rounded, 'Website', 'tixolve.com'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scheme.outline.withValues(alpha: .55)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
                alpha: theme.brightness == Brightness.dark ? .3 : .05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: scheme.primary.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.support_agent_rounded,
                    size: 19, color: scheme.primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('guide.contactTitle'.tr,
                        style: theme.textTheme.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    Text(
                      'guide.contactSubtitle'.tr,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurface.withValues(alpha: .6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _channels.length; i++)
            _ContactRow(
              icon: _channels[i].$1,
              label: _channels[i].$2.tr,
              value: _channels[i].$3,
              last: i == _channels.length - 1,
              onCopy: onCopy,
            ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.last,
    required this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool last;
  final void Function(String label, String value) onCopy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onCopy(label, value),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 16, color: scheme.onSurface),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: scheme.onSurface.withValues(alpha: .5),
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: TextStyle(
                        color: scheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.copy_rounded,
                  size: 15, color: scheme.onSurface.withValues(alpha: .4)),
            ],
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── Controls & footer ─────────────────────────

class _Controls extends StatelessWidget {
  const _Controls({
    required this.index,
    required this.total,
    required this.onPrev,
    required this.onNext,
    required this.onDot,
  });

  final int index;
  final int total;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<int> onDot;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isLast = index == total - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 220),
            opacity: index > 0 ? 1 : 0,
            child: IgnorePointer(
              ignoring: index == 0,
              child: _CircleButton(
                icon: Icons.arrow_back_rounded,
                filled: false,
                onTap: onPrev,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < total; i++)
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onDot(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        width: i == index ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == index
                              ? scheme.primary
                              : scheme.onSurface.withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          _CircleButton(
            icon: isLast
                ? Icons.refresh_rounded
                : Icons.arrow_forward_rounded,
            filled: true,
            onTap: onNext,
          ),
        ],
      ),
    )
        .animate(delay: 150.ms)
        .fadeIn(duration: 380.ms)
        .slideY(begin: .12, curve: Curves.easeOutCubic);
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: filled ? scheme.primary : Colors.transparent,
      shape: CircleBorder(
        side: BorderSide(
          color: filled ? Colors.transparent : scheme.outline,
        ),
      ),
      elevation: filled ? 4 : 0,
      shadowColor: scheme.primary.withValues(alpha: .4),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            size: 21,
            color: filled ? scheme.onPrimary : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _FooterCredit extends StatelessWidget {
  const _FooterCredit({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Divider(height: 1, color: scheme.outline.withValues(alpha: .45)),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AuthPalette.emeraldMid,
                      AuthPalette.emeraldDeep,
                    ],
                  ),
                ),
                child: const Text(
                  'T',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 7),
              Text(
                'guide.developedBy'.tr,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: .72),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .1,
                ),
              ),
              Text(
                '  ·  EthioMarket © 2026',
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: .4),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    )
        .animate(delay: 240.ms)
        .fadeIn(duration: 420.ms)
        .slideY(begin: .1, curve: Curves.easeOutCubic);
  }
}
