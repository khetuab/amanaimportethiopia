import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/app_sizes.dart';

class AppImagePicker extends StatelessWidget {
  const AppImagePicker({
    super.key,
    required this.files,
    required this.onAdd,
    required this.onRemove,
    this.maxCount = 6,
  });

  final List<XFile> files;
  final ValueChanged<XFile> onAdd;
  final ValueChanged<XFile> onRemove;
  final int maxCount;

  Future<void> _pick(BuildContext context) async {
    final picker = ImagePicker();
    final result = await picker.pickMultiImage(
      imageQuality: 85,
      maxWidth: 2000,
    );
    for (final f in result) {
      if (files.length >= maxCount) break;
      onAdd(f);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: AppSizes.sm,
      runSpacing: AppSizes.sm,
      children: [
        ...files.map(
          (f) => Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                child: Image.file(
                  File(f.path),
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: InkWell(
                  onTap: () => onRemove(f),
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (files.length < maxCount)
          InkWell(
            onTap: () => _pick(context),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                border: Border.all(
                  color: scheme.outline,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add_a_photo_outlined,
                color: scheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
      ],
    );
  }
}
