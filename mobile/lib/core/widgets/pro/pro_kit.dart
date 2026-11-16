import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/app_colors.dart';
import '../app_badge.dart';

/// Safe numeric read for any model field type.
double asDouble(Object? v) => v is num ? v.toDouble() : 0.0;

/// Looping 0..1 driver. Use integer multiples of t inside sin/cos for
/// seamless loops.
class ProLooper extends StatefulWidget {
  const ProLooper({super.key, required this.duration, required this.builder});
  final Duration duration;
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<ProLooper> createState() => _ProLooperState();
}

class _ProLooperState extends State<ProLooper>
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

/// Staggered fade + slide entrance for a column of blocks.
class ProStagger extends StatelessWidget {
  const ProStagger({
    super.key,
    required this.children,
    this.gap = 16,
    this.delay = const Duration(milliseconds: 80),
  });
  final List<Widget> children;
  final double gap;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[
      for (var i = 0; i < children.length; i++)
        Padding(
          padding: EdgeInsets.only(bottom: i == children.length - 1 ? 0 : gap),
          child: children[i],
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: spaced
          .animate(interval: 70.ms, delay: delay)
          .fadeIn(duration: 400.ms)
          .slideY(begin: .1, end: 0, curve: Curves.easeOutCubic),
    );
  }
}

/// Cross-fades between loading / error / content. Give each state a Key.
class ProStateSwitcher extends StatelessWidget {
  const ProStateSwitcher({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.topCenter,
        fit: StackFit.passthrough,
        children: [
          for (final p in previous)
            Positioned(top: 0, left: 0, right: 0, child: p),
          if (current != null) current,
        ],
      ),
      child: child,
    );
  }
}

/// Surface card with press-scale and optional highlight glow.
class ProCard extends StatefulWidget {
  const ProCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(18),
    this.highlight = false,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final bool highlight;

  @override
  State<ProCard> createState() => _ProCardState();
}

class _ProCardState extends State<ProCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: widget.padding,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.highlight
              ? scheme.primary.withValues(alpha: .7)
              : theme.dividerColor.withValues(alpha: .7),
          width: widget.highlight ? 1.6 : 1,
        ),
        boxShadow: [
          if (widget.highlight)
            BoxShadow(
              color: scheme.primary.withValues(alpha: .25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            )
          else if (!dark)
            BoxShadow(
              color: Colors.black.withValues(alpha: .05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: widget.child,
    );

    if (widget.onTap == null) return card;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: AnimatedScale(
        scale: _down ? .97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: card,
      ),
    );
  }
}

class ProInfoRow extends StatelessWidget {
  const ProInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
    this.bold = false,
  });
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: .6);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18, color: muted),
            const SizedBox(width: 10),
          ],
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProInfoList extends StatelessWidget {
  const ProInfoList({super.key, required this.rows});
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    final line = Theme.of(context).dividerColor.withValues(alpha: .5);
    final items = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) items.add(Divider(height: 1, thickness: 1, color: line));
      items.add(rows[i]);
    }
    return Column(children: items);
  }
}

class ProSectionTitle extends StatelessWidget {
  const ProSectionTitle(this.title, {super.key, this.icon, this.trailing});
  final String title;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Row(
      children: [
        if (icon != null) ...[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: scheme.primary),
          ),
          const SizedBox(width: 10),
        ],
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class ProPill extends StatelessWidget {
  const ProPill({super.key, required this.label, required this.tone});
  final String label;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    late Color bg;
    late Color fg;
    switch (tone) {
      case AppBadgeTone.green:
        bg = AppColors.statusGreenBg;
        fg = dark ? const Color(0xFF6EE7B7) : AppColors.statusGreenFg;
      case AppBadgeTone.amber:
        bg = AppColors.statusAmberBg;
        fg = dark ? const Color(0xFFFCD34D) : AppColors.statusAmberFg;
      case AppBadgeTone.red:
        bg = AppColors.statusRedBg;
        fg = dark ? const Color(0xFFFCA5A5) : AppColors.statusRedFg;
      case AppBadgeTone.blue:
        bg = AppColors.statusBlueBg;
        fg = dark ? const Color(0xFF7DD3FC) : AppColors.statusBlueFg;
      case AppBadgeTone.purple:
        bg = AppColors.statusPurpleBg;
        fg = dark ? const Color(0xFFC4B5FD) : AppColors.statusPurpleFg;
      default:
        bg = AppColors.statusSlateBg;
        fg = dark ? const Color(0xFFCBD5E1) : AppColors.statusSlateFg;
    }
    if (dark) bg = fg.withValues(alpha: .16);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated number that counts up (and between values on change).
class ProCountUp extends StatelessWidget {
  const ProCountUp({
    super.key,
    required this.value,
    required this.format,
    this.style,
    this.duration = const Duration(milliseconds: 1100),
  });
  final double value;
  final String Function(double) format;
  final TextStyle? style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => Text(format(v), style: style),
    );
  }
}

/// Animated selectable pill (filters, channels).
class ProSelectChip extends StatelessWidget {
  const ProSelectChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return TweenAnimationBuilder<Color?>(
      duration: const Duration(milliseconds: 250),
      tween: ColorTween(
        end: selected
            ? scheme.onPrimary
            : scheme.onSurface.withValues(alpha: .75),
      ),
      builder: (_, c, __) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surface,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: selected
                  ? scheme.primary
                  : theme.dividerColor.withValues(alpha: .8),
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: scheme.primary.withValues(alpha: .35),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 17, color: c),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Tinted note box with leading icon.
class ProCallout extends StatelessWidget {
  const ProCallout({
    super.key,
    required this.child,
    this.icon = Icons.info_outline_rounded,
    this.color,
  });
  final Widget child;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.withValues(alpha: .3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: c),
          const SizedBox(width: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

/// Two equal columns that wrap.
class ProGrid2 extends StatelessWidget {
  const ProGrid2({super.key, required this.children, this.gap = 12});
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, box) {
        final w = (box.maxWidth - gap) / 2;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [for (final c in children) SizedBox(width: w, child: c)],
        );
      },
    );
  }
}

// Used by states file too.
double sinT(double t, int cycles, [double phase = 0]) =>
    math.sin(t * math.pi * 2 * cycles + phase);