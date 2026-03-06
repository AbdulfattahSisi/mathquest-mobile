import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  // ── Brand Colors ─────────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF1E88E5);
  static const Color accent    = Color(0xFF8E24AA);
  static const Color success   = Color(0xFF43A047);
  static const Color warning   = Color(0xFFFFB300);
  static const Color error     = Color(0xFFE53935);
  static const Color bg        = Color(0xFFF5F7FA);
  static const Color cardBg    = Color(0xFFFFFFFF);
  static const Color textMain  = Color(0xFF1A1A2E);
  static const Color textMuted = Color(0xFF6B7280);

  // Extended palette
  static const Color neonBlue   = Color(0xFF00D4FF);
  static const Color neonPurple = Color(0xFF7C3AED);
  static const Color neonPink   = Color(0xFFEC4899);
  static const Color neonGreen  = Color(0xFF10B981);
  static const Color deepNavy   = Color(0xFF0F172A);
  static const Color royalBlue  = Color(0xFF1D4ED8);
  static const Color softIndigo = Color(0xFF6366F1);

  // Dark colors
  static const Color darkBg      = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF131927);
  static const Color darkCard    = Color(0xFF1A2235);
  static const Color darkText    = Color(0xFFE6EDF3);
  static const Color darkMuted   = Color(0xFF8B949E);

  // ── Gradients ──────────────────────────────────────────────────────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F172A), Color(0xFF1E40AF), Color(0xFF7C3AED)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00D4FF), Color(0xFF7C3AED), Color(0xFFEC4899)],
  );

  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFF7931E), Color(0xFFFFCD00)],
  );

  static const LinearGradient coolGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF10B981), Color(0xFF34D399)],
  );

  // ── Glass Morphism Helpers ──────────────────────────────────────────────
  static BoxDecoration glassCard({Color? tint, double opacity = 0.08, double radius = 24, bool border = true}) {
    return BoxDecoration(
      color: (tint ?? Colors.white).withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: border ? Border.all(color: Colors.white.withOpacity(0.12), width: 1) : null,
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 24, offset: const Offset(0, 8)),
      ],
    );
  }

  static BoxDecoration glowCard(Color color, {double radius = 22, bool isDark = false}) {
    return BoxDecoration(
      color: isDark ? darkCard : Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: color.withOpacity(isDark ? 0.3 : 0.15), width: 1.5),
      boxShadow: [
        BoxShadow(color: color.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 8)),
        BoxShadow(color: color.withOpacity(0.06), blurRadius: 40, spreadRadius: 2),
      ],
    );
  }

  static BoxDecoration gradientCard(List<Color> colors, {double radius = 22}) {
    return BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: colors),
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(color: colors.first.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
      ],
    );
  }

  // ── Section Header ─────────────────────────────────────────────────────
  static Widget sectionHeader(String title, {IconData? icon, Color? color, VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: (color ?? primary).withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color ?? primary, size: 16),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(title, style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: color ?? textMain, letterSpacing: -0.3,
            )),
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: (color ?? primary).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('Voir tout ›', style: TextStyle(
                  color: color ?? primary, fontSize: 12, fontWeight: FontWeight.w700,
                )),
              ),
            ),
        ],
      ),
    );
  }

  // ── Text Theme ────────────────────────────────────────────────────────────
  static TextTheme _textTheme(Color main, Color muted) => GoogleFonts.poppinsTextTheme(
    TextTheme(
      displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: main, letterSpacing: -1.2, height: 1.1),
      displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: main, letterSpacing: -0.8),
      titleLarge:   TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: main, letterSpacing: -0.5),
      titleMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: main),
      bodyLarge:    TextStyle(fontSize: 16, color: main, height: 1.5),
      bodyMedium:   TextStyle(fontSize: 14, color: muted, height: 1.4),
      labelLarge:   const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),
    ),
  );

  // ── Light Theme ───────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: accent,
      background: bg,
      surface: cardBg,
      error: error,
    ),
    textTheme: _textTheme(textMain, textMuted),
    scaffoldBackgroundColor: bg,
    appBarTheme: AppBarTheme(
      backgroundColor: cardBg,
      foregroundColor: textMain,
      elevation: 0,
      shadowColor: Colors.black12,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: textMain),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
        shadowColor: primary.withOpacity(0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF0F2F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      hintStyle: TextStyle(color: textMuted.withOpacity(0.6)),
    ),
    cardTheme: CardTheme(
      color: cardBg,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: cardBg,
      selectedItemColor: primary,
      unselectedItemColor: textMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );

  // ── Dark Theme ────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      secondary: accent,
      background: darkBg,
      surface: darkSurface,
      error: error,
    ),
    textTheme: _textTheme(darkText, darkMuted),
    scaffoldBackgroundColor: darkBg,
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: darkText,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: darkText),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        elevation: 0,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1.5),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: primary, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    ),
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: primary,
      unselectedItemColor: darkMuted,
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),
  );
}

/// Theme mode notifier — persists dark mode preference.
class ThemeProvider extends ChangeNotifier {
  static const _kDarkMode = 'dark_mode';
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  ThemeProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = (prefs.getBool(_kDarkMode) ?? false) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, _mode == ThemeMode.dark);
    notifyListeners();
  }
}
