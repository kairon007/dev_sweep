import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color navBackground = Color(0xFF0A0A0A);
  static const Color border = Color(0xFF262626);
  static const Color borderLight = Color(0xFF404040);
  
  static const Color primary = Color(0xFFDDB7FF);
  static const Color primaryDim = Color(0xFFC084FC);
  static const Color secondary = Color(0xFF4CD7F6);
  static const Color tertiary = Color(0xFFFABC4E);
  
  static const Color textMain = Color(0xFFE5E5E5);
  static const Color textMuted = Color(0xFF737373); // neutral-500

  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        surface: surface,
        error: Color(0xFFFFB4AB),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: textMain,
        displayColor: textMain,
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        space: 1,
        thickness: 1,
      ),
      cardTheme: const CardThemeData(
        color: surfaceContainer,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: border),
          borderRadius: BorderRadius.zero,
        ),
      ),
    );
  }

  static TextStyle get monoSm => GoogleFonts.jetBrainsMono(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMain,
  );
  
  static TextStyle get monoXs => GoogleFonts.jetBrainsMono(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static TextStyle get monoMd => GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textMain,
  );

  static TextStyle get uiLabelMd => GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: textMain,
  );
}
