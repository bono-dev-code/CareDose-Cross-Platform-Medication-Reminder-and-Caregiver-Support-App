import 'package:flutter/material.dart';

class AppTheme {
  // CareDose design system: calm, medical, human, consistent.
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color teal = Color(0xFF0D9488);
  static const Color mint = Color(0xFFEAFBF7);
  static const Color softBlue = Color(0xFFEFF6FF);
  static const Color lavender = Color(0xFFF5F3FF);
  static const Color cream = Color(0xFFFFFBF3);
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFDC2626);
  static const Color warning = Color(0xFFD97706);
  static const Color background = Color(0xFFF7FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textSoft = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  static const double radius = 24;
  static const double largeRadius = 32;

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF0F7FF), Color(0xFFFAFDFF), Color(0xFFF6FFFC)],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2563EB), Color(0xFF0D9488)],
  );

  static const LinearGradient softHeroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFEFF6FF), Color(0xFFEAFBF7)],
  );

  static List<BoxShadow> get softShadow => const [
        BoxShadow(color: Color(0x140F172A), blurRadius: 26, offset: Offset(0, 14)),
      ];

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -1.0, color: textDark),
        headlineMedium: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.6, color: textDark),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.4, color: textDark),
        titleMedium: TextStyle(fontWeight: FontWeight.w800, color: textDark),
        bodyLarge: TextStyle(fontSize: 16, height: 1.45, color: textDark),
        bodyMedium: TextStyle(fontSize: 14, height: 1.45, color: textSoft),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: teal,
        surface: card,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textDark, letterSpacing: -0.2),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textDark,
        contentTextStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        labelStyle: const TextStyle(color: textSoft, fontWeight: FontWeight.w600),
        prefixIconColor: textSoft,
        suffixIconColor: textSoft,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: border)),
        focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: primary, width: 1.6), borderRadius: BorderRadius.circular(20)),
        errorBorder: OutlineInputBorder(borderSide: const BorderSide(color: danger), borderRadius: BorderRadius.circular(20)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: border),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
    );
  }
}
