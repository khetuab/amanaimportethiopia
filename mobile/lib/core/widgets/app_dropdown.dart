import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_sizes.dart';

class AppDropdownOption<T> {
  const AppDropdownOption({required this.value, required this.label});
  final T value;
  final String label;
}

class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    super.key,
    this.label,
    this.hint,
    required this.value,
    required this.options,
    required this.onChanged,
    this.errorText,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final T? value;
  final List<AppDropdownOption<T>> options;
  final ValueChanged<T?>? onChanged;
  final String? errorText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: theme.textTheme.labelLarge),
          const SizedBox(height: AppSizes.sm),
        ],
        DropdownButtonFormField<T>(
          initialValue: value,
          items: options
              .map(
                (o) =>
                    DropdownMenuItem<T>(value: o.value, child: Text(o.label)),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          isExpanded: true,
          decoration: InputDecoration(
              hintText: hint ?? 'common.select'.tr, errorText: errorText),
        ),
      ],
    );
  }
}
