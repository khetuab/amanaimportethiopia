import 'dart:math' as math;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../constants/auth_palette.dart';
import '../../../features/auth/widgets/premium_button.dart';
import 'pro_kit.dart';

/// Small animated badge cluster for the hero (right side).
class HeroArt extends StatelessWidget {
  const HeroArt({super.key, required this.icon, this.satellites = const []});
  final IconData icon;
  final List<IconData> satellites;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 124,
      height: 124,
      child: ProLooper(
        duration: const Duration(seconds: 12),
        builder: (context, t) {
          final pulse = 1 + .05 * sinT(t, 12);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Center(
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: Colors.white.withValues(alpha: .16)),
                  ),
                ),
              ),
              for (var i = 0; i < satellites.length; i++)
                Positioned(
                  left: 62 +
                      math.cos(i * 2 * math.pi / satellites.length +
                          t * 2 * math.pi) *
                          52 -
                      15,
                  top: 62 +
                      math.sin(i * 2 * math.pi / satellites.length +
                          t * 2 * math.pi) *
                          52 -
                      15 +
                      sinT(t, 6, i.toDouble()) * 3,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: .16),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: .3)),
                    ),
                    child: Icon(satellites[i], size: 15, color: Colors.white),
                  ),
                ),
              Center(
                child: Transform.scale(
                  scale: pulse,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AuthPalette.mint, AuthPalette.emeraldMid],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AuthPalette.mint.withValues(alpha: .5),
                          blurRadius: 22,
                        ),
                      ],
                    ),
                    child: Icon(icon,
                        size: 30, color: AuthPalette.emeraldDeep),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StateArt extends StatelessWidget {
  const _StateArt({
    required this.icon,
    required this.satellites,
    required this.tint,
    this.wobble = false,
  });
  final IconData icon;
  final List<IconData> satellites;
  final Color tint;
  final bool wobble;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 230,
      height: 210,
      child: ProLooper(
        duration: const Duration(seconds: 14),
        builder: (context, t) {
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              for (var i = 0; i < 3; i++)
                Transform.scale(
                  scale: 1 + .04 * sinT(t, 7, i * 1.3),
                  child: Container(
                    width: 100.0 + i * 48,
                    height: 100.0 + i * 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: tint.withValues(alpha: .08 - i * .02),
                    ),
                  ),
                ),
              for (var i = 0; i < satellites.length; i++)
                Positioned(
                  left: 115 +
                      math.cos(i * 2 * math.pi / satellites.length +
                          t * 2 * math.pi) *
                          88 -
                      18,
                  top: 105 +
                      math.sin(i * 2 * math.pi / satellites.length +
                          t * 2 * math.pi) *
                          74 -
                      18 +
                      sinT(t, 7, i.toDouble()) * 4,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: scheme.surface,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: .12),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(satellites[i], size: 18, color: tint),
                  ),
                ),
              // Twinkles.
              for (var i = 0; i < 5; i++)
                Positioned(
                  left: 20.0 + (i * 47) % 190,
                  top: 14.0 + (i * 61) % 170,
                  child: Opacity(
                    opacity: (.2 + .5 * (sinT(t, 5, i * 1.7) + 1) / 2),
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration:
                      BoxDecoration(color: tint, shape: BoxShape.circle),
                    ),
                  ),
                ),
              Transform.translate(
                offset: Offset(0, sinT(t, 7) * 4),
                child: Transform.rotate(
                  angle: wobble ? sinT(t, 14) * .08 : 0,
                  child: Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: tint.withValues(alpha: .3),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: Icon(icon, size: 42, color: tint),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProEmptyState extends StatelessWidget {
  const ProEmptyState({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.satellites = const [],
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String description;
  final IconData icon;
  final List<IconData> satellites;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 8),
        _StateArt(
          icon: icon,
          satellites: satellites,
          tint: theme.colorScheme.primary,
        ),
        const SizedBox(height: 12),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: .65),
            height: 1.5,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 20),
          SizedBox(
            width: 210,
            child: PremiumButton(label: actionLabel!, onPressed: onAction),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 450.ms).slideY(begin: .06, end: 0);
  }
}

class ProErrorState extends StatelessWidget {
  const ProErrorState({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        const SizedBox(height: 8),
        _StateArt(
          icon: Icons.cloud_off_rounded,
          satellites: const [
            Icons.wifi_off_rounded,
            Icons.sync_problem_rounded,
          ],
          tint: theme.colorScheme.error,
          wobble: true,
        ),
        const SizedBox(height: 12),
        Text(
          'state.error.title'.tr,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: .65),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 190,
          child: PremiumButton(
            label: 'common.tryAgain'.tr,
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 450.ms).slideY(begin: .06, end: 0);
  }
}

class ProSkeleton extends StatelessWidget {
  const ProSkeleton({super.key, required this.height, this.radius = 22});
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.onSurface;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(radius),
      ),
    )
        .animate(onPlay: (ctrl) => ctrl.repeat())
        .shimmer(duration: 1500.ms, color: c.withValues(alpha: .1));
  }
}

class ProSkeletonList extends StatelessWidget {
  const ProSkeletonList({super.key, this.count = 4, this.itemHeight = 96});
  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.only(bottom: i == count - 1 ? 0 : 14),
            child: ProSkeleton(height: itemHeight),
          ),
      ],
    );
  }
}