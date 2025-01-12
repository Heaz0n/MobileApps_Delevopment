import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.light,
      primary: Colors.blue,
      secondary: Colors.amber,
      background: Colors.grey[200]!,
    ),
    textTheme: GoogleFonts.robotoTextTheme(
      Theme.of(context).textTheme.copyWith(
            titleLarge: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: GoogleFonts.roboto(
              fontSize: 16,
              color: Colors.black87,
            ),
            bodyMedium: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    ),
  );
}

ThemeData darkTheme(BuildContext context) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.blue,
      brightness: Brightness.dark,
    ),
    textTheme: GoogleFonts.robotoTextTheme(
      Theme.of(context).textTheme,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    ),
  );
}
