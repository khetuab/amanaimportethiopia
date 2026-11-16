// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// /// Two families:
// ///   - Inter for UI (readable at small sizes)
// ///   - Playfair Display for editorial headings
// class AppTextStyles {
//   AppTextStyles._();
//
//   static TextTheme textTheme(Color base, Color muted) {
//     final inter = GoogleFonts.interTextTheme();
//     return TextTheme(
//       displayLarge: GoogleFonts.playfairDisplay(
//         fontSize: 34,
//         fontWeight: FontWeight.w700,
//         color: base,
//         height: 1.1,
//       ),
//       displayMedium: GoogleFonts.playfairDisplay(
//         fontSize: 28,
//         fontWeight: FontWeight.w700,
//         color: base,
//         height: 1.15,
//       ),
//       headlineLarge: GoogleFonts.playfairDisplay(
//         fontSize: 24,
//         fontWeight: FontWeight.w700,
//         color: base,
//       ),
//       headlineMedium: inter.headlineMedium?.copyWith(
//         fontSize: 22,
//         fontWeight: FontWeight.w600,
//         color: base,
//       ),
//       titleLarge: inter.titleLarge?.copyWith(
//         fontSize: 18,
//         fontWeight: FontWeight.w600,
//         color: base,
//       ),
//       titleMedium: inter.titleMedium?.copyWith(
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//         color: base,
//       ),
//       bodyLarge: inter.bodyLarge?.copyWith(
//         fontSize: 15,
//         color: base,
//         height: 1.45,
//       ),
//       bodyMedium: inter.bodyMedium?.copyWith(
//         fontSize: 14,
//         color: base,
//         height: 1.4,
//       ),
//       bodySmall: inter.bodySmall?.copyWith(
//         fontSize: 12,
//         color: muted,
//         height: 1.35,
//       ),
//       labelLarge: inter.labelLarge?.copyWith(
//         fontSize: 14,
//         fontWeight: FontWeight.w600,
//         letterSpacing: 0.1,
//         color: base,
//       ),
//       labelSmall: inter.labelSmall?.copyWith(
//         fontSize: 11,
//         letterSpacing: 0.4,
//         color: muted,
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Poppins typography for the entire application.
class AppTextStyles {
  AppTextStyles._();

  static TextTheme textTheme(Color base, Color muted) {
    final poppins = GoogleFonts.poppinsTextTheme();

    return TextTheme(
      displayLarge: GoogleFonts.poppins(
        fontSize: 34,
        fontWeight: FontWeight.w700,
        color: base,
        height: 1.1,
      ),
      displayMedium: GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: base,
        height: 1.15,
      ),
      headlineLarge: GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: base,
      ),
      headlineMedium: poppins.headlineMedium?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleLarge: poppins.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      titleMedium: poppins.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: base,
      ),
      bodyLarge: poppins.bodyLarge?.copyWith(
        fontSize: 15,
        color: base,
        height: 1.45,
      ),
      bodyMedium: poppins.bodyMedium?.copyWith(
        fontSize: 14,
        color: base,
        height: 1.4,
      ),
      bodySmall: poppins.bodySmall?.copyWith(
        fontSize: 12,
        color: muted,
        height: 1.35,
      ),
      labelLarge: poppins.labelLarge?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: base,
      ),
      labelSmall: poppins.labelSmall?.copyWith(
        fontSize: 11,
        letterSpacing: 0.4,
        color: muted,
      ),
    );
  }
}
