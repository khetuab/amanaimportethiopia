import 'package:flutter/material.dart';
import '../constants/auth_palette.dart';

/// The app logo on a mint tile. Falls back to the Amharic letter if the asset is missing.
class BrandMark extends StatelessWidget {
  const BrandMark({
    super.key,
    this.size = 44,
    this.radiusFactor = .3,
    this.tile = true,
    this.glow = false,
  });

  final double size;
  final double radiusFactor; // corner radius as a fraction of size
  final bool tile; // false = logo only, no background (for light backgrounds)
  final bool glow;

  static const asset = 'assets/images/importlogo.png';

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (_, __, ___) => Center(
        child: Text(
          'ኢ',
          style: TextStyle(
            color: AuthPalette.emeraldDeep,
            fontWeight: FontWeight.w800,
            fontSize: size * .5,
          ),
        ),
      ),
    );

    if (!tile) return SizedBox(width: size, height: size, child: image);

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * .18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * radiusFactor),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AuthPalette.mint, AuthPalette.emeraldMid],
        ),
        boxShadow: glow
            ? [
          BoxShadow(
            color: AuthPalette.mint.withValues(alpha: .5),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ]
            : null,
      ),
      child: image,
    );
  }
}