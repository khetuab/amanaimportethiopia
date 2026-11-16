import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Text field with animated focus glow, icon tint, floating label and a
/// gentle shake when validation fails. Works inside your existing [Form].
class PremiumField extends StatefulWidget {
  const PremiumField({
    super.key,
    this.controller,
    required this.label,
    this.icon,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onSubmitted,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final IconData? icon;
  final ValueChanged<String>? onChanged;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onSubmitted;
  final bool obscureText;
  final Widget? suffix;

  /// Maximum number of visible lines.
  /// Defaults to 1 (single-line input).
  final int? maxLines;

  @override
  State<PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<PremiumField>
    with SingleTickerProviderStateMixin {
  final _focus = FocusNode();

  late final AnimationController _shake = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    _shake.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final error = widget.validator?.call(v);

    if (error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _shake.forward(from: 0);
      });
    }

    return error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final focused = _focus.hasFocus;

    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: c, width: w),
    );

    return AnimatedBuilder(
      animation: _shake,
      builder: (context, child) {
        final t = _shake.value;
        final dx = math.sin(t * math.pi * 5) * 7 * (1 - t);

        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            if (focused)
              BoxShadow(
                color: scheme.primary.withValues(alpha: isDark ? .22 : .16),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
          ],
        ),
        child: TextFormField(
          controller: widget.controller,
          focusNode: _focus,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: _validate,
          onFieldSubmitted: widget.onSubmitted,
          onChanged: widget.onChanged,
          maxLines: widget.maxLines,
          style: theme.textTheme.bodyLarge,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
            filled: true,
            fillColor: focused
                ? scheme.surface
                : (isDark
                      ? Colors.white.withValues(alpha: .06)
                      : scheme.primary.withValues(alpha: .045)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            labelStyle: TextStyle(
              color: scheme.onSurface.withValues(alpha: .6),
            ),
            floatingLabelStyle: TextStyle(
              color: focused
                  ? scheme.primary
                  : scheme.onSurface.withValues(alpha: .7),
              fontWeight: FontWeight.w600,
            ),
            hintStyle: TextStyle(
              color: scheme.onSurface.withValues(alpha: .35),
            ),
            prefixIcon: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 200),
              tween: ColorTween(
                end: focused
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: .5),
              ),
              builder: (_, c, __) => Icon(widget.icon, color: c),
            ),
            suffixIcon: widget.suffix,
            border: border(Colors.transparent, 1),
            enabledBorder: border(theme.dividerColor.withValues(alpha: .7), 1),
            focusedBorder: border(scheme.primary, 1.6),
            errorBorder: border(scheme.error, 1.2),
            focusedErrorBorder: border(scheme.error, 1.6),
          ),
        ),
      ),
    );
  }
}

/// Animated eye toggle: rotates + scales between states.
class PasswordToggle extends StatelessWidget {
  const PasswordToggle({
    super.key,
    required this.obscured,
    required this.onTap,
  });

  final bool obscured;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        transitionBuilder: (child, anim) => RotationTransition(
          turns: Tween<double>(begin: .75, end: 1).animate(anim),
          child: FadeTransition(
            opacity: anim,
            child: ScaleTransition(scale: anim, child: child),
          ),
        ),
        child: Icon(
          obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          key: ValueKey(obscured),
        ),
      ),
    );
  }
}
