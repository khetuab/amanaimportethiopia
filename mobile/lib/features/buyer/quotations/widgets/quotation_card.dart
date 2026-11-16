import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../core/constants/auth_palette.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../data/models/quotation_model.dart';

class QuotationCard extends StatelessWidget {
  const QuotationCard({
    super.key,
    required this.quotation,
    required this.onTap,
    this.recommended = false,
    this.deltaFromBest,
  });

  final QuotationModel quotation;
  final VoidCallback onTap;
  final bool recommended;
  final double? deltaFromBest;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final name = quotation.importerBusinessName ?? 'auth.role.importer'.tr;
    final initial = name.trim().isEmpty ? 'I' : name.trim()[0].toUpperCase();

    return ProCard(
      onTap: onTap,
      highlight: recommended,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AuthPalette.emeraldMid, AuthPalette.emeraldDeep],
                  ),
                ),
                child: Text(
                  initial,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded,
                            size: 16, color: scheme.primary),
                      ],
                    ),
                    if (quotation.importerRating != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _Stars(rating: quotation.importerRating!),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'buyer.quotations.card.reviews'.trParams({
                                'rating': quotation
                                    .importerRating!.toStringAsFixed(1),
                                'count': '${quotation.importerRatingCount}',
                              }),
                              style: theme.textTheme.bodySmall,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if (recommended)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [AuthPalette.mint, AuthPalette.emeraldMid],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AuthPalette.mint.withValues(alpha: .45),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 14, color: AuthPalette.emeraldDeep),
                      const SizedBox(width: 3),
                      Text(
                        'buyer.quotations.card.bestPrice'.tr,
                        style: const TextStyle(
                          color: AuthPalette.emeraldDeep,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(duration: 2200.ms, delay: 900.ms),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ProCountUp(
                value: asDouble(quotation.totalPriceETB),
                format: (v) => Formatters.etb(v),
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -.3,
                ),
              ),
              const Spacer(),
              if (deltaFromBest != null)
                Text(
                  deltaFromBest! > 0
                      ? 'buyer.quotations.card.vsBest'
                          .trParams({'amount': Formatters.etb(deltaFromBest)})
                      : 'buyer.quotations.card.lowestOffer'.tr,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: deltaFromBest! > 0
                        ? scheme.onSurface.withValues(alpha: .6)
                        : scheme.primary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(
              height: 1, color: theme.dividerColor.withValues(alpha: .5)),
          const SizedBox(height: 14),
          Row(
            children: [
              _InfoChip(
                icon: Icons.schedule_rounded,
                label: 'buyer.quotations.card.deliveryDays'
                    .trParams({'days': '${quotation.estimatedDeliveryDays}'}),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: _InfoChip(
                  icon: Icons.verified_outlined,
                  label: _conditionLabel(quotation.productCondition),
                ),
              ),
              const Spacer(),
              Icon(Icons.chevron_right_rounded,
                  color: scheme.onSurface.withValues(alpha: .4)),
            ],
          ),
        ],
      ),
    );
  }

  static String _conditionLabel(String c) {
    switch (c) {
      case 'new':
        return 'condition.new'.tr;
      case 'used_like_new':
        return 'condition.used_like_new'.tr;
      case 'used_good':
        return 'condition.used_good'.tr;
      case 'used_fair':
        return 'condition.used_fair'.tr;
      case 'refurbished':
        return 'condition.refurbished'.tr;
      default:
        return c;
    }
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: scheme.onSurface.withValues(alpha: .85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stars extends StatelessWidget {
  const _Stars({required this.rating});
  final double rating;

  @override
  Widget build(BuildContext context) {
    const gold = Color(0xFFF59E0B);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 5; i++)
          Icon(
            rating >= i + 1
                ? Icons.star_rounded
                : rating >= i + .5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: 15,
            color: gold,
          ),
      ],
    );
  }
}