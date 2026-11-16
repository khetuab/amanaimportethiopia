import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_sizes.dart';
import 'app_button.dart';

class AppOfflineState extends StatelessWidget {
  const AppOfflineState({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSizes.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 34,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: AppSizes.lg),
          Text('state.offline.title'.tr, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSizes.sm),
          Text(
            'state.offline.body'.tr,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.65),
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppSizes.lg),
            AppButton(label: 'common.retry'.tr, onPressed: onRetry, expand: false),
          ],
        ],
      ),
    );
  }
}
