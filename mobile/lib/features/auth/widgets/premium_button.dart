import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/auth_palette.dart';

enum PremiumButtonStyle { filled, light, glass , outlined}

/// Press-scale + haptic feedback, animated shadow, and a morphing
/// label -> bouncing-dots loader.
class PremiumButton extends StatefulWidget {
  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.style = PremiumButtonStyle.filled,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final PremiumButtonStyle style;
  final IconData? icon;

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null && !widget.loading;

    late final Color fg;
    late final BoxDecoration deco;
    final shadowOpacity = _down ? .15 : .35;

    switch (widget.style) {
      case PremiumButtonStyle.filled:
        fg = scheme.onPrimary;
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              scheme.primary,
              Color.lerp(scheme.primary, Colors.black, .18)!,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.primary.withValues(alpha: shadowOpacity),
              blurRadius: _down ? 8 : 22,
              offset: Offset(0, _down ? 3 : 10),
            ),
          ],
        );
      case PremiumButtonStyle.light:
        fg = AuthPalette.emeraldDeep;
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AuthPalette.mint.withValues(alpha: shadowOpacity),
              blurRadius: _down ? 8 : 24,
              offset: Offset(0, _down ? 3 : 10),
            ),
          ],
        );
      case PremiumButtonStyle.glass:
        fg = Colors.white;
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: _down ? .22 : .12),
          border: Border.all(color: Colors.white.withValues(alpha: .35)),
        );

      case PremiumButtonStyle.outlined:
        fg = scheme.primary;
        deco = BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: scheme.primary.withValues(alpha: _down ? .12 : .06),
          border: Border.all(color: scheme.primary.withValues(alpha: .5), width: 1.4),
        );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: enabled ? (_) => _set(true) : null,
      onTapUp: enabled ? (_) => _set(false) : null,
      onTapCancel: enabled ? () => _set(false) : null,
      onTap: enabled
          ? () {
        HapticFeedback.selectionClick();
        widget.onPressed!();
      }
          : null,
      child: AnimatedScale(
        scale: _down ? .96 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 56,
          width: double.infinity,
          decoration: deco,
          child: Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: ScaleTransition(scale: anim, child: child),
              ),
              child: widget.loading
                  ? _Dots(key: const ValueKey('dots'), color: fg)
                  : Row(
                key: const ValueKey('label'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: fg,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: .3,
                    ),
                  ),
                  if (widget.icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(widget.icon, color: fg, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({super.key, required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return Container(
          width: 9,
          height: 9,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(
          begin: .5,
          end: 1,
          delay: (i * 140).ms,
          duration: 420.ms,
          curve: Curves.easeInOut,
        )
            .fade(begin: .4, end: 1, delay: (i * 140).ms, duration: 420.ms);
      }),
    );
  }
}