import 'package:flutter/material.dart';

enum AppBadgeTone { green, amber, red, blue, purple, slate }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.slate,
  });

  final String label;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    late final Color bg;
    late final Color fg;

    switch (tone) {
      case AppBadgeTone.green:
        bg = isDark ? const Color(0xFF204A38) : const Color(0xFFE5F5EE);
        fg = isDark ? const Color(0xFF9DE0C1) : const Color(0xFF1E7A53);
        break;
      case AppBadgeTone.amber:
        bg = isDark ? const Color(0xFF4A3A1C) : const Color(0xFFFDF2DE);
        fg = isDark ? const Color(0xFFF0C77C) : const Color(0xFF8A5F0D);
        break;
      case AppBadgeTone.red:
        bg = isDark ? const Color(0xFF4A2326) : const Color(0xFFFBE5E5);
        fg = isDark ? const Color(0xFFF0A2A2) : const Color(0xFFA03030);
        break;
      case AppBadgeTone.blue:
        bg = isDark ? const Color(0xFF22364A) : const Color(0xFFE8EFF7);
        fg = isDark ? const Color(0xFFA0C4E6) : const Color(0xFF3A5F82);
        break;
      case AppBadgeTone.purple:
        bg = isDark ? const Color(0xFF3A2640) : const Color(0xFFF0E7F3);
        fg = isDark ? const Color(0xFFC9A5D4) : const Color(0xFF6B4576);
        break;
      case AppBadgeTone.slate:
        bg = isDark ? const Color(0xFF333036) : const Color(0xFFEDEDF1);
        fg = isDark ? const Color(0xFFC5BFC4) : const Color(0xFF4D4A52);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
