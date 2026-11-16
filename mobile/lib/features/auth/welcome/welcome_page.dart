import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import '../../../core/constants/auth_palette.dart';
import '../../../core/widgets/brand_mark.dart';
import '../widgets/premium_button.dart';
import '../widgets/trade_hero.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  // TODO: replace with your route constants (e.g. AppRoutes.login).
  static const _loginRoute = '/login';
  static const _registerRoute = '/register';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final top = <Widget>[
      Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                colors: [AuthPalette.mint, AuthPalette.emeraldMid],
              ),
            ),
            child: const BrandMark(size: 44, radiusFactor: .32),
          ),
          const SizedBox(width: 12),
          const Text('Ethio Import ',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .4)),
        ],
      ),
    ];

    final bottom = <Widget>[
      RichText(
        text: TextSpan(
          style: theme.textTheme.displayMedium?.copyWith(
            color: Colors.white,
            fontSize: 40,
            height: 1.05,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
          children: [
            TextSpan(text: 'auth.welcome.headline1'.tr),
            TextSpan(
              text: 'auth.welcome.headline2'.tr,
              style: const TextStyle(color: AuthPalette.mint),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'auth.welcome.description'.tr,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: .78),
          height: 1.5,
        ),
      ),
      const SizedBox(height: 20),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Chip(Icons.verified_outlined, 'auth.welcome.chipVerified'.tr),
          _Chip(Icons.local_shipping_outlined, 'auth.welcome.chipTracking'.tr),
          _Chip(Icons.lock_outline_rounded, 'auth.welcome.chipPayments'.tr),
        ],
      ),
      const SizedBox(height: 32),
      PremiumButton(
        label: 'auth.signIn'.tr,
        icon: Icons.arrow_forward_rounded,
        style: PremiumButtonStyle.light,
        onPressed: () => Get.toNamed(_loginRoute),
      ),
      const SizedBox(height: 12),
      PremiumButton(
        label: 'auth.createAccount'.tr,
        style: PremiumButtonStyle.glass,
        onPressed: () => Get.toNamed(_registerRoute),
      ),
      const SizedBox(height: 8),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AuthPalette.emeraldDeep,
        body: Stack(
          fit: StackFit.expand,
          children: [
            const TradeHero(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ...top
                        .animate()
                        .fadeIn(duration: 600.ms)
                        .slideY(begin: -.3, end: 0),
                    const Spacer(),
                    ...bottom
                        .animate(interval: 90.ms, delay: 300.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(
                        begin: .15, end: 0, curve: Curves.easeOutCubic),
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

class _Chip extends StatelessWidget {
  const _Chip(this.icon, this.label);
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: .22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AuthPalette.mint),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}