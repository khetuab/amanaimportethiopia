// import 'package:flutter/material.dart';
//
// /// Brand palette: Emerald green on clean neutrals.
// /// Light and dark variants live here so no screen decides colors manually.
// class AppColors {
//   AppColors._();
//
//   // --- Raw brand colors ---
//   static const Color brandBase = Color(0xFFF5FAF8); // mint-white
//   static const Color brandPrimary = Color(0xFF047857); // emerald 700: CTA (5.5:1 vs white)
//   static const Color brandAccent = Color(0xFF059669); // emerald 600
//   static const Color brandMuted = Color(0xFF566F66); // grey-green
//   static const Color brandInk = Color(0xFF04201A); // deep emerald-black
//
//   // --- Derived status colors ---
//   static const Color success = Color(0xFF047857);
//   static const Color warning = Color(0xFFB45309);
//   static const Color danger = Color(0xFFB91C1C);
//   static const Color info = Color(0xFF0E7490);
//
//   // --- LIGHT THEME ---
//   static const Color lightBackground = brandBase;
//   static const Color lightSurface = Colors.white;
//   static const Color lightSurfaceAlt = Color(0xFFE6F4EE);
//   static const Color lightBorder = Color(0xFFCFE5DB);
//   static const Color lightTextPrimary = brandInk; // ~17:1 on white
//   static const Color lightTextSecondary = Color(0xFF2F4A41); // ~9:1
//   static const Color lightTextMuted = Color(0xFF566F66); // ~5.4:1 (AA)
//   static const Color lightPrimary = brandPrimary;
//   static const Color lightAccent = brandAccent;
//   static const Color lightError = danger;
//
//   // --- DARK THEME ---
//   static const Color darkBackground = Color(0xFF051A15);
//   static const Color darkSurface = Color(0xFF0B2A22);
//   static const Color darkSurfaceAlt = Color(0xFF10382D);
//   static const Color darkBorder = Color(0xFF1E4D3F);
//   static const Color darkTextPrimary = Color(0xFFEAF7F1); // ~15:1
//   static const Color darkTextSecondary = Color(0xFFBFDCD0);
//   static const Color darkTextMuted = Color(0xFF8FB0A3); // ~7:1
//   static const Color darkPrimary = Color(0xFF34D399); // emerald 400, use brandInk on top
//   static const Color darkAccent = Color(0xFF6EE7B7);
//   static const Color darkError = Color(0xFFF87171);
//
//   // --- Semantic status chip colors (light) ---
//   static const Color statusAmberBg = Color(0xFFFEF3C7);
//   static const Color statusAmberFg = Color(0xFF92400E);
//   static const Color statusGreenBg = Color(0xFFD1FAE5);
//   static const Color statusGreenFg = Color(0xFF065F46);
//   static const Color statusRedBg = Color(0xFFFEE2E2);
//   static const Color statusRedFg = Color(0xFF991B1B);
//   static const Color statusBlueBg = Color(0xFFE0F2FE);
//   static const Color statusBlueFg = Color(0xFF075985);
//   static const Color statusPurpleBg = Color(0xFFEDE9FE);
//   static const Color statusPurpleFg = Color(0xFF5B21B6);
//   static const Color statusSlateBg = Color(0xFFEAF0ED);
//   static const Color statusSlateFg = Color(0xFF334155);
// }

//
// import 'package:flutter/material.dart';
//
// /// Brand palette: Premium blue on clean neutrals.
// /// Light and dark variants live here so no screen decides colors manually.
// class AppColors {
//   AppColors._();
//
//   // --- Raw brand colors ---
//   static const Color brandBase = Color(0xFFF4F8FD); // blue-white
//   static const Color brandPrimary = Color(0xFF1D4ED8); // blue 700
//   static const Color brandAccent = Color(0xFF2563EB); // blue 600
//   static const Color brandMuted = Color(0xFF52677F); // grey-blue
//   static const Color brandInk = Color(0xFF0B1F3A); // deep navy
//
//   // --- Derived status colors ---
//   static const Color success = Color(0xFF047857);
//   static const Color warning = Color(0xFFB45309);
//   static const Color danger = Color(0xFFB91C1C);
//   static const Color info = Color(0xFF0369A1);
//
//   // --- LIGHT THEME ---
//   static const Color lightBackground = brandBase;
//   static const Color lightSurface = Colors.white;
//   static const Color lightSurfaceAlt = Color(0xFFEAF2FF);
//   static const Color lightBorder = Color(0xFFD2DFF2);
//   static const Color lightTextPrimary = brandInk;
//   static const Color lightTextSecondary = Color(0xFF304761);
//   static const Color lightTextMuted = Color(0xFF52677F);
//   static const Color lightPrimary = brandPrimary;
//   static const Color lightAccent = brandAccent;
//   static const Color lightError = danger;
//
//   // --- DARK THEME ---
//   static const Color darkBackground = Color(0xFF081629);
//   static const Color darkSurface = Color(0xFF10243D);
//   static const Color darkSurfaceAlt = Color(0xFF183453);
//   static const Color darkBorder = Color(0xFF294665);
//   static const Color darkTextPrimary = Color(0xFFEDF4FF);
//   static const Color darkTextSecondary = Color(0xFFC3D5EA);
//   static const Color darkTextMuted = Color(0xFF91AAC7);
//   static const Color darkPrimary = Color(0xFF60A5FA); // blue 400
//   static const Color darkAccent = Color(0xFF93C5FD);
//   static const Color darkError = Color(0xFFF87171);
//
//   // --- Semantic status chip colors (light) ---
//   static const Color statusAmberBg = Color(0xFFFEF3C7);
//   static const Color statusAmberFg = Color(0xFF92400E);
//   static const Color statusGreenBg = Color(0xFFD1FAE5);
//   static const Color statusGreenFg = Color(0xFF065F46);
//   static const Color statusRedBg = Color(0xFFFEE2E2);
//   static const Color statusRedFg = Color(0xFF991B1B);
//   static const Color statusBlueBg = Color(0xFFDBEAFE);
//   static const Color statusBlueFg = Color(0xFF1E40AF);
//   static const Color statusPurpleBg = Color(0xFFEDE9FE);
//   static const Color statusPurpleFg = Color(0xFF5B21B6);
//   static const Color statusSlateBg = Color(0xFFEAF0F7);
//   static const Color statusSlateFg = Color(0xFF334155);
// }



import 'package:flutter/material.dart';

/// Brand palette: Premium black on clean neutrals.
/// Light and dark variants live here so no screen decides colors manually.
class AppColors {
  AppColors._();

  // --- Raw brand colors ---
  static const Color brandBase = Color(0xFFF7F7F7); // soft white
  static const Color brandPrimary = Color(0xFF171717); // charcoal black
  static const Color brandAccent = Color(0xFF404040); // graphite
  static const Color brandMuted = Color(0xFF737373); // neutral grey
  static const Color brandInk = Color(0xFF111111); // deep black

  // --- Derived status colors ---
  static const Color success = Color(0xFF047857);
  static const Color warning = Color(0xFFB45309);
  static const Color danger = Color(0xFFB91C1C);
  static const Color info = Color(0xFF0369A1);

  // --- LIGHT THEME ---
  static const Color lightBackground = brandBase;
  static const Color lightSurface = Colors.white;
  static const Color lightSurfaceAlt = Color(0xFFF0F0F0);
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = brandInk;
  static const Color lightTextSecondary = Color(0xFF404040);
  static const Color lightTextMuted = Color(0xFF737373);
  static const Color lightPrimary = brandPrimary;
  static const Color lightAccent = brandAccent;
  static const Color lightError = danger;

  // --- DARK THEME ---
  static const Color darkBackground = Color(0xFF0A0A0A);
  static const Color darkSurface = Color(0xFF141414);
  static const Color darkSurfaceAlt = Color(0xFF202020);
  static const Color darkBorder = Color(0xFF333333);
  static const Color darkTextPrimary = Color(0xFFF5F5F5);
  static const Color darkTextSecondary = Color(0xFFD4D4D4);
  static const Color darkTextMuted = Color(0xFFA3A3A3);
  static const Color darkPrimary = Color(0xFFE5E5E5);
  static const Color darkAccent = Color(0xFFFFFFFF);
  static const Color darkError = Color(0xFFF87171);

  // --- Semantic status chip colors (light) ---
  static const Color statusAmberBg = Color(0xFFFEF3C7);
  static const Color statusAmberFg = Color(0xFF92400E);
  static const Color statusGreenBg = Color(0xFFD1FAE5);
  static const Color statusGreenFg = Color(0xFF065F46);
  static const Color statusRedBg = Color(0xFFFEE2E2);
  static const Color statusRedFg = Color(0xFF991B1B);
  static const Color statusBlueBg = Color(0xFFDBEAFE);
  static const Color statusBlueFg = Color(0xFF1E40AF);
  static const Color statusPurpleBg = Color(0xFFEDE9FE);
  static const Color statusPurpleFg = Color(0xFF5B21B6);
  static const Color statusSlateBg = Color(0xFFEAEAEA);
  static const Color statusSlateFg = Color(0xFF333333);
}
