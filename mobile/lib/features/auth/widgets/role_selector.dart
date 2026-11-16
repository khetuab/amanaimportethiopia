import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_sizes.dart';

/// Two-card role selector used in register.
class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key, required this.value, required this.onChanged});

  final String value; // 'buyer' | 'importer'
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _RoleCard(
            label: 'auth.role.buyer'.tr,
            hint: 'auth.role.buyerHint'.tr,
            icon: Icons.shopping_bag_outlined,
            selected: value == 'buyer',
            onTap: () => onChanged('buyer'),
          ),
        ),
        const SizedBox(width: AppSizes.md),
        Expanded(
          child: _RoleCard(
            label: 'auth.role.importer'.tr,
            hint: 'auth.role.importerHint'.tr,
            icon: Icons.local_shipping_outlined,
            selected: value == 'importer',
            onTap: () => onChanged('importer'),
          ),
        ),
      ],
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.hint,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String hint;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: selected ? scheme.primary.withValues(alpha: 0.08) : scheme.surface,
      borderRadius: BorderRadius.circular(AppSizes.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(AppSizes.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: selected ? scheme.primary : theme.dividerColor,
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: selected
                    ? scheme.primary
                    : scheme.onSurface.withValues(alpha: 0.65),
              ),
              const SizedBox(height: AppSizes.md),
              Text(label, style: theme.textTheme.titleMedium),
              const SizedBox(height: 2),
              Text(hint, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
