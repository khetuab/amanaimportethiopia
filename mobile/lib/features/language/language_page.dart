import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../core/constants/auth_palette.dart';
import '../../core/widgets/brand_mark.dart';
import '../auth/widgets/premium_button.dart';
import 'language_controller.dart';

/// First-run language gate — shown once, before onboarding, when no
/// language preference has been saved yet. Purely presentational: it
/// only previews the locale live and persists the choice on Continue.
class LanguagePage extends GetView<LanguageController> {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final size = MediaQuery.sizeOf(context);
    final pad = MediaQuery.paddingOf(context);
    final heroH = (size.height * .36).clamp(250.0, 340.0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Stack(
          children: [
            // ── Emerald hero panel ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: heroH,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(44)),
                child: DecoratedBox(
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
                    painter: const _GatePainter(),
                    child: Column(
                      children: [
                        SizedBox(height: pad.top + 10),
                        // Brand row (mirrors onboarding).
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              const BrandMark(size: 38, radiusFactor: .32),
                              const SizedBox(width: 10),
                              Text(
                                'app.name'.tr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        // Frosted globe + headline.
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30),
                          child: Column(
                            children: [
                              Container(
                                width: 74,
                                height: 74,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: .12),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: .22),
                                  ),
                                ),
                                child: const Icon(
                                  Icons.public_rounded,
                                  color: Colors.white,
                                  size: 34,
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 450.ms)
                                  .scale(
                                    begin: const Offset(.8, .8),
                                    end: const Offset(1, 1),
                                    curve: Curves.easeOutCubic,
                                  ),
                              const SizedBox(height: 16),
                              Text(
                                'language.welcomeTitle'.tr,
                                style: TextStyle(
                                  color: AuthPalette.mint,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: .8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'language.chooseTitle'.tr,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          )
                              .animate()
                              .fadeIn(
                                duration: 500.ms,
                                delay: 120.ms,
                              )
                              .slideY(
                                begin: .12,
                                end: 0,
                                curve: Curves.easeOutCubic,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Bottom: subtitle, language cards, continue ──
            Positioned(
              top: heroH,
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 22, 24, 20 + pad.bottom),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          children: [
                            Text(
                              'language.chooseSubtitle'.tr,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurface.withValues(alpha: .65),
                                height: 1.45,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ...List.generate(
                              LanguageController.languages.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _LanguageCard(
                                  language: LanguageController.languages[i],
                                  delay: 200.ms + (120 * i).ms,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Continue — enabled once a language is chosen.
                    Obx(() {
                      final lang = controller.selected.value;
                      return PremiumButton(
                        label: 'language.continueLabel'.tr,
                        icon: Icons.arrow_forward_rounded,
                        loading: controller.busy.value,
                        onPressed:
                            lang.isEmpty ? null : () => controller.confirm(),
                      )
                          .animate()
                          .fadeIn(duration: 450.ms, delay: 620.ms)
                          .slideY(
                            begin: .2,
                            end: 0,
                            curve: Curves.easeOutCubic,
                          );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────── Language card ─────────────────────────

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({
    required this.language,
    required this.delay,
  });

  final AppLanguage language;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final controller = Get.find<LanguageController>();

    return Obx(() {
      final isSelected = controller.selected.value == language.code;

      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.select(language.code),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? scheme.primary.withValues(alpha: .07)
                  : scheme.onSurface.withValues(alpha: .04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isSelected
                    ? scheme.primary.withValues(alpha: .8)
                    : scheme.onSurface.withValues(alpha: .12),
                width: isSelected ? 1.6 : 1.2,
              ),
            ),
            child: Row(
              children: [
                // Leading tag tile.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? scheme.primary
                        : scheme.onSurface.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    language.tag,
                    style: TextStyle(
                      color: isSelected
                          ? scheme.onPrimary
                          : scheme.onSurface.withValues(alpha: .7),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Native + English names.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        language.native,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface,
                          fontSize: 16.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        language.english,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: scheme.onSurface.withValues(alpha: .55),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Trailing selection indicator.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? scheme.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: .28),
                      width: 1.6,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: scheme.onPrimary,
                  )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      )
          .animate(delay: delay)
          .fadeIn(duration: 450.ms)
          .slideY(begin: .16, end: 0, curve: Curves.easeOutCubic);
    });

  }
}

// ───────────────────────── Hero decoration ─────────────────────────

class _GatePainter extends CustomPainter {
  const _GatePainter();

  @override
  void paint(Canvas canvas, Size s) {
    // Soft mint glow behind the headline.
    final gc = Offset(s.width * .5, s.height * .68);
    canvas.drawCircle(
      gc,
      s.width * .62,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AuthPalette.mint.withValues(alpha: .20),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: gc, radius: s.width * .62)),
    );

    // Decorative rings (two clusters, echoing onboarding).
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: .08);
    final c1 = Offset(s.width * .95, s.height * .16);
    for (final r in [60.0, 105.0, 150.0]) {
      canvas.drawCircle(c1, r, ring);
    }
    final ring2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = AuthPalette.mint.withValues(alpha: .12);
    final c2 = Offset(s.width * .05, s.height * .88);
    for (final r in [34.0, 64.0]) {
      canvas.drawCircle(c2, r, ring2);
    }

    // Floating dots.
    canvas.drawCircle(
      Offset(s.width * .18, s.height * .30),
      3,
      Paint()..color = Colors.white.withValues(alpha: .25),
    );
    canvas.drawCircle(
      Offset(s.width * .82, s.height * .52),
      2.2,
      Paint()..color = AuthPalette.mint.withValues(alpha: .5),
    );
    canvas.drawCircle(
      Offset(s.width * .68, s.height * .14),
      1.8,
      Paint()..color = Colors.white.withValues(alpha: .2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
