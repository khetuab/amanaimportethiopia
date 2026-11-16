import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'pro_kit.dart';

const Color kProGold = Color(0xFFF59E0B);

/// Animated switch row.
class ProSwitchTile extends StatelessWidget {
  const ProSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon = Icons.tune_rounded,
  });
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProCard(
      highlight: value,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: theme.textTheme.bodySmall),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 50,
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: value
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: .2),
              borderRadius: BorderRadius.circular(15),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeOutBack,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: value ? scheme.onPrimary : Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable date tile (label + value).
class ProDateTile extends StatelessWidget {
  const ProDateTile({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.icon = Icons.calendar_month_outlined,
  });
  final String label;
  final String value;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Tappable 5-star rating with bounce.
class ProStarRating extends StatelessWidget {
  const ProStarRating({
    super.key,
    required this.rating,
    required this.onChanged,
    this.size = 30,
  });
  final int rating;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    final off = Theme.of(context).colorScheme.onSurface.withValues(alpha: .25);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onChanged(i + 1);
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size * .08),
            child: AnimatedScale(
              scale: filled ? 1.0 : .88,
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutBack,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (c, a) => ScaleTransition(
                  scale: CurvedAnimation(parent: a, curve: Curves.easeOutBack),
                  child: c,
                ),
                child: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  key: ValueKey(filled),
                  size: size,
                  color: filled ? kProGold : off,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Search box with focus glow and animated clear button.
class ProSearchField extends StatefulWidget {
  const ProSearchField({
    super.key,
    required this.hint,
    this.onChanged,
    this.onSubmitted,
  });
  final String hint;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<ProSearchField> createState() => _ProSearchFieldState();
}

class _ProSearchFieldState extends State<ProSearchField> {
  final _c = TextEditingController();
  final _f = FocusNode();

  @override
  void initState() {
    super.initState();
    _f.addListener(() => setState(() {}));
    _c.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _c.dispose();
    _f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final focused = _f.hasFocus;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: focused
              ? scheme.primary
              : theme.dividerColor.withValues(alpha: .8),
          width: focused ? 1.6 : 1,
        ),
        boxShadow: [
          if (focused)
            BoxShadow(
              color: scheme.primary.withValues(alpha: .18),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: TextField(
        controller: _c,
        focusNode: _f,
        textInputAction: TextInputAction.search,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          hintText: widget.hint,
          filled: false,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          prefixIcon: Icon(Icons.search_rounded,
              color: focused
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: .5)),
          suffixIcon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _c.text.isEmpty
                ? const SizedBox.shrink(key: ValueKey('none'))
                : IconButton(
              key: const ValueKey('clear'),
              icon: const Icon(Icons.close_rounded, size: 20),
              onPressed: () {
                _c.clear();
                widget.onChanged?.call('');
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ProOption<T> {
  const ProOption(this.value, this.label);
  final T value;
  final String label;
}

/// Dropdown replacement: tile that opens a bottom-sheet picker.
class ProPickerField<T> extends StatelessWidget {
  const ProPickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.options,
    required this.onChanged,
    this.value,
    this.hint,
  });
  final String label;
  final String? hint;
  final IconData icon;
  final T? value;
  final List<ProOption<T>> options;
  final ValueChanged<T> onChanged;

  Future<void> _open(BuildContext context) async {
    HapticFeedback.selectionClick();
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PickerSheet<T>(
        title: label,
        options: options,
        value: value,
        onPick: (v) {
          Navigator.of(ctx).pop();
          onChanged(v);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    ProOption<T>? sel;
    for (final o in options) {
      if (o.value == value) sel = o;
    }
    return ProCard(
      onTap: () => _open(context),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, size: 20, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  sel?.label ?? hint ?? 'common.select'.tr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: sel == null
                        ? scheme.onSurface.withValues(alpha: .45)
                        : null,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              color: scheme.onSurface.withValues(alpha: .5)),
        ],
      ),
    );
  }
}

class _PickerSheet<T> extends StatelessWidget {
  const _PickerSheet({
    required this.title,
    required this.options,
    required this.value,
    required this.onPick,
  });
  final String title;
  final List<ProOption<T>> options;
  final T? value;
  final ValueChanged<T> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      constraints:
      BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * .65),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 42,
              height: 4,
              decoration: BoxDecoration(
                color: scheme.onSurface.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Text(title,
                style: theme.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 16),
                children: [
                  for (final o in options)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Material(
                        color: o.value == value
                            ? scheme.primary.withValues(alpha: .1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () => onPick(o.value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    o.label,
                                    style: TextStyle(
                                      fontWeight: o.value == value
                                          ? FontWeight.w800
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (o.value == value)
                                  Icon(Icons.check_circle_rounded,
                                      color: scheme.primary),
                              ],
                            ),
                          ),
                        ),
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

/// Floating action pill with press feedback and entrance.
class ProFab extends StatefulWidget {
  const ProFab({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<ProFab> createState() => _ProFabState();
}

class _ProFabState extends State<ProFab> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _down ? .94 : 1,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              colors: [
                scheme.primary,
                Color.lerp(scheme.primary, Colors.black, .2)!,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: .4),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: scheme.onPrimary),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: TextStyle(
                  color: scheme.onPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 350.ms)
        .slideY(begin: 1, end: 0, curve: Curves.easeOutBack);
  }
}

/// Small stat/fact tile (icon, label, value).
class ProFactTile extends StatelessWidget {
  const ProFactTile({
    super.key,
    required this.icon,
    required this.label,
    this.value,
    this.child,
  });
  final IconData icon;
  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return ProCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 19, color: scheme.primary),
          ),
          const SizedBox(height: 12),
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: 2),
          child ??
              Text(
                value ?? '',
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
        ],
      ),
    );
  }
}

/// Vertical timeline entry (dot + connector).
class ProTimelineTile extends StatelessWidget {
  const ProTimelineTile({
    super.key,
    required this.label,
    required this.time,
    required this.last,
  });
  final String label;
  final String time;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                const SizedBox(height: 3),
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                    boxShadow: [
                      if (last)
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: .35),
                          spreadRadius: 5,
                        ),
                    ],
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.primary.withValues(alpha: .25),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: last ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                  Text(time, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Submitted -> In review -> Decision stepper for verification status.
class ProVerifyStepper extends StatelessWidget {
  const ProVerifyStepper({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final approved = status == 'approved';
    final bad =
        status == 'rejected' || status == 'suspended' || status == 'expired';
    // 0 todo, 1 active, 2 done, 3 error
    final states = [2, status == 'pending' ? 1 : 2, approved ? 2 : (bad ? 3 : 0)];
    final lastLabel = approved
        ? 'core.widgets.verify.approved'.tr
        : status == 'rejected'
        ? 'core.widgets.verify.rejected'.tr
        : status == 'suspended'
        ? 'core.widgets.verify.suspended'.tr
        : status == 'expired'
        ? 'core.widgets.verify.expired'.tr
        : 'core.widgets.verify.decision'.tr;
    final labels = [
      'core.widgets.verify.submitted'.tr,
      'core.widgets.verify.inReview'.tr,
      lastLabel,
    ];

    return LayoutBuilder(
      builder: (context, box) {
        final col = box.maxWidth / 3;
        Widget seg(double left, bool on) => Positioned(
          left: left,
          top: 15,
          width: math(col - 44),
          height: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: Stack(
              children: [
                Container(color: scheme.primary.withValues(alpha: .15)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: on ? 1.0 : 0.0),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, __) => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: v,
                    child: Container(color: scheme.primary),
                  ),
                ),
              ],
            ),
          ),
        );

        return SizedBox(
          height: 64,
          child: Stack(
            children: [
              seg(col / 2 + 22, states[1] >= 1),
              seg(col * 1.5 + 22, states[2] >= 2),
              for (var i = 0; i < 3; i++)
                Positioned(
                  left: col * i,
                  width: col,
                  top: 0,
                  child: Column(
                    children: [
                      _node(context, states[i]),
                      const SizedBox(height: 6),
                      Text(
                        labels[i],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                          states[i] == 0 ? FontWeight.w500 : FontWeight.w700,
                          color: states[i] == 3
                              ? scheme.error
                              : scheme.onSurface.withValues(
                              alpha: states[i] == 0 ? .5 : .9),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static double math(double v) => v < 0 ? 0 : v;

  Widget _node(BuildContext context, int st) {
    final scheme = Theme.of(context).colorScheme;
    final err = st == 3;
    final done = st == 2;
    final active = st == 1;
    final color = err ? scheme.error : scheme.primary;
    final circle = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: (done || err) ? color : scheme.surface,
        border: Border.all(
          color: st == 0 ? scheme.onSurface.withValues(alpha: .2) : color,
          width: 2,
        ),
      ),
      child: Icon(
        err
            ? Icons.close_rounded
            : done
            ? Icons.check_rounded
            : active
            ? Icons.hourglass_top_rounded
            : Icons.circle,
        size: st == 0 ? 8 : 17,
        color: err
            ? Colors.white
            : done
            ? scheme.onPrimary
            : (st == 0 ? scheme.onSurface.withValues(alpha: .2) : color),
      ),
    );
    if (!active) return circle;
    return ProLooper(
      duration: const Duration(seconds: 2),
      builder: (_, t) => Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .35 * (1 - t)),
              spreadRadius: 9 * t,
            ),
          ],
        ),
        child: circle,
      ),
    );
  }
}