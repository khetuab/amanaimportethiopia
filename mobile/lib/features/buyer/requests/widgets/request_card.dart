import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile/features/buyer/requests/widgets/request_image.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../data/models/product_request_model.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({super.key, required this.request, this.onTap});
  final ProductRequestModel request;
  final VoidCallback? onTap;

  static IconData _icon(String s) => switch (s) {
    'draft' => Icons.edit_note_rounded,
    'published' => Icons.campaign_outlined,
    'receiving_offers' => Icons.local_offer_outlined,
    'offer_selected' => Icons.handshake_outlined,
    'fulfilled' => Icons.verified_rounded,
    'cancelled' => Icons.cancel_outlined,
    'expired' => Icons.timer_off_outlined,
    'rejected_by_admin' => Icons.gpp_bad_outlined,
    _ => Icons.request_quote_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final tone = switch (request.status) {
      'draft' => AppBadgeTone.slate,
      'published' => AppBadgeTone.blue,
      'receiving_offers' => AppBadgeTone.purple,
      'offer_selected' => AppBadgeTone.green,
      'fulfilled' => AppBadgeTone.green,
      'cancelled' => AppBadgeTone.slate,
      'expired' => AppBadgeTone.slate,
      'rejected_by_admin' => AppBadgeTone.red,
      _ => AppBadgeTone.slate,
    };
    final hasQuotes = request.quotationsCount > 0;
    final urls = requestImageUrls(request);
    final iconBox = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_icon(request.status), color: scheme.primary),
    );

    return ProCard(
      onTap: onTap,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Container(
              //   width: 48,
              //   height: 48,
              //   decoration: BoxDecoration(
              //     color: scheme.primary.withValues(alpha: .12),
              //     borderRadius: BorderRadius.circular(16),
              //   ),
              //   child: Icon(_icon(request.status), color: scheme.primary),
              // ),
              ProductThumb(
                url: imageUrlFor(request),
                icon: Icons.inventory_2_outlined,
                size: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${request.categoryName ?? ''} · ${request.deliveryCity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Divider(height: 1, color: theme.dividerColor.withValues(alpha: .5)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ProPill(
                label: 'status.${request.status}'.tr,
                tone: tone,
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: hasQuotes
                      ? scheme.primary.withValues(alpha: .14)
                      : scheme.onSurface.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.request_quote_outlined,
                      size: 14,
                      color: hasQuotes
                          ? scheme.primary
                          : scheme.onSurface.withValues(alpha: .5),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'buyer.requests.card.quotesCount'
                          .trParams({'count': '${request.quotationsCount}'}),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: hasQuotes ? scheme.primary : null,
                      ),
                    ),
                  ],
                ),
              ),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: scheme.onSurface.withValues(alpha: .5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    Formatters.date(request.expiresAt),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}