import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: const Color(0xffF9FAFB),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    colorScheme: ColorScheme.fromSwatch().copyWith(secondary: AppColors.accent),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.poppins().fontFamily,
    scaffoldBackgroundColor: AppColors.darkBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 1,
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    colorScheme: ColorScheme.fromSwatch(
      brightness: Brightness.dark,
    ).copyWith(secondary: AppColors.accent),
  );
}
