import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pro/pro.dart';
import '../../../../core/widgets/pro/pro_kit.dart';
import '../../../../core/widgets/pro/pro_states.dart';
import '../../../auth/widgets/premium_button.dart';
import '../widgets/request_image.dart';
import 'request_detail_controller.dart';

class RequestDetailPage extends GetView<RequestDetailController> {
  const RequestDetailPage({super.key});

  static String? _daysLeft(dynamic exp) {
    if (exp is! DateTime) return null;
    final d = exp.difference(DateTime.now()).inDays;
    if (d < 0) return 'status.expired'.tr;
    if (d == 0) return 'buyer.requests.detail.expiresToday'.tr;
    return 'buyer.requests.detail.daysLeft'.trParams({'days': '$d'});
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final r = controller.request.value;
      final loading = controller.loading.value;
      final error = controller.error.value;

      final isDraft = r?.status == 'draft';
      final canCancel = r != null &&
          ['draft', 'published', 'receiving_offers'].contains(r.status);
      final canViewQuotes = r != null &&
          ['receiving_offers', 'offer_selected'].contains(r.status);

      final actions = <Widget>[
        if (isDraft)
          PremiumButton(
            label: 'buyer.requests.detail.publishRequest'.tr,
            icon: Icons.rocket_launch_rounded,
            onPressed: controller.publish,
          ),
        if (canViewQuotes)
          PremiumButton(
            label: 'buyer.requests.detail.viewQuotations'
                .trParams({'count': '${r!.quotationsCount}'}),
            icon: Icons.price_check_rounded,
            onPressed: controller.viewQuotations,
          ),
        if (canCancel)
          PremiumButton(
            label: 'buyer.requests.detail.cancelRequest'.tr,
            style: PremiumButtonStyle.outlined,
            onPressed: controller.cancel,
          ),
      ];

      final left = r == null ? null : _daysLeft(r.expiresAt);

      return ProPage(
        showBack: true,
        eyebrow: r?.referenceNumber ?? 'buyer.requests.detail.eyebrow'.tr,
        title: r?.title ?? 'buyer.requests.detail.title'.tr,
        heroExtra: r == null
            ? null
            : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            HeroPill(
              label: 'status.${r.status}'.tr,
              icon: Icons.radio_button_checked_rounded,
            ),
            if (left != null)
              HeroPill(label: left, icon: Icons.timer_outlined),
          ],
        ),
        art: const HeroArt(
          icon: Icons.request_quote_rounded,
          satellites: [
            Icons.inventory_2_outlined,
            Icons.local_offer_outlined,
            Icons.public_rounded,
          ],
        ),
        onRefresh: controller.load,
        bottomBar: actions.isEmpty ? null : ProBottomBar(children: actions),
        body: ProStateSwitcher(
          child: loading
              ? const ProSkeletonList(
              key: ValueKey('loading'), count: 3, itemHeight: 120)
              : error != null
              ? ProErrorState(
            key: const ValueKey('error'),
            message: error,
            onRetry: controller.load,
          )
              : r == null
              ? const SizedBox.shrink(key: ValueKey('none'))
              : _content(context, r),
        ),
      );
    });
  }

  Widget _content(BuildContext context, dynamic r) {
    final theme = Theme.of(context);
    final hasBudget = r.budgetMinETB != null || r.budgetMaxETB != null;
    final urls = requestImageUrls(r);

    return ProStagger(
      key: const ValueKey('data'),
      gap: 18,
      children: [
        ProGrid2(children: [
          if (urls.isNotEmpty) RequestGallery(urls: urls),
          ProFactTile(
            icon: Icons.request_quote_outlined,
            label: 'buyer.requests.detail.quotesReceived'.tr,
            child: ProCountUp(
              value: asDouble(r.quotationsCount),
              format: (v) => v.toStringAsFixed(0),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          ProFactTile(
            icon: Icons.event_outlined,
            label: 'buyer.requests.field.offersUntil'.tr,
            value: Formatters.date(r.expiresAt),
          ),
        ]),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('buyer.requests.detail.title'.tr,
                  icon: Icons.assignment_outlined),
              const SizedBox(height: 6),
              ProInfoList(rows: [
                ProInfoRow(
                    label: 'buyer.requests.field.category'.tr,
                    icon: Icons.category_outlined,
                    value: r.categoryName ?? '—'),
                ProInfoRow(
                    label: 'buyer.requests.field.deliveryCity'.tr,
                    icon: Icons.place_outlined,
                    value: r.deliveryCity),
                ProInfoRow(
                  label: 'buyer.requests.field.quantity'.tr,
                  icon: Icons.numbers_rounded,
                  value: '${r.quantity} ${r.unitOfMeasurement}',
                ),
                ProInfoRow(
                  label: 'buyer.requests.detail.budget'.tr,
                  icon: Icons.payments_outlined,
                  bold: true,
                  value: hasBudget
                      ? '${Formatters.etb(r.budgetMinETB)} – ${Formatters.etb(r.budgetMaxETB)}'
                      : 'buyer.requests.detail.budgetOpen'.tr,
                ),
              ]),
            ],
          ),
        ),
        ProCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProSectionTitle('buyer.requests.field.description'.tr,
                  icon: Icons.notes_rounded),
              const SizedBox(height: 10),
              Text(
                r.description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
              ),
            ],
          ),
        ),
      ],
    );
  }
}