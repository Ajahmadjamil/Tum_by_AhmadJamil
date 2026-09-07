import 'package:flutter/material.dart';

@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.canvas,
    required this.surface,
    required this.searchFill,
    required this.text,
    required this.textMuted,
    required this.onDark,
    required this.onDarkMuted,
    required this.accent,
    required this.accentSoft,
    required this.primary,
    required this.border,
    required this.error,
    required this.bannerGradient,
    required this.quoteGradient,
    required this.bookGradient,
  });

  final Color canvas;
  final Color surface;
  final Color searchFill;
  final Color text;
  final Color textMuted;
  final Color onDark;
  final Color onDarkMuted;
  final Color accent;
  final Color accentSoft;
  final Color primary;
  final Color border;
  final Color error;
  final LinearGradient bannerGradient;
  final LinearGradient quoteGradient;
  final LinearGradient bookGradient;

  static const orange = Color(0xFFFF8A3D);

  static const whatsappLight = AppPalette(
    canvas: Color(0xFFECE5DD),
    surface: Color(0xFFFFFFFF),
    searchFill: Color(0xFFD9D0C7),
    text: Color(0xFF111B21),
    textMuted: Color(0xFF667781),
    onDark: Color(0xFFFFFFFF),
    onDarkMuted: Color(0xFFD1D7DB),
    accent: orange,
    accentSoft: Color(0xFFFFE4D1),
    primary: Color(0xFF075E54),
    border: Color(0xFFD1C7BC),
    error: Color(0xFFC62828),
    bannerGradient: LinearGradient(
      colors: [Color(0xFF1A0A0A), Color(0xFF3B0D12), Color(0xFF0D0D0D)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    quoteGradient: LinearGradient(
      colors: [Color(0xFF1B3A8A), Color(0xFF4B2C8A), Color(0xFF6B3FA0)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    bookGradient: LinearGradient(
      colors: [Color(0xFF2A1810), Color(0xFF0E0E0E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  static const whatsappDark = AppPalette(
    canvas: Color(0xFF0B141A),
    surface: Color(0xFF1F2C34),
    searchFill: Color(0xFF2A3942),
    text: Color(0xFFE9EDEF),
    textMuted: Color(0xFF8696A0),
    onDark: Color(0xFFFFFFFF),
    onDarkMuted: Color(0xFFD1D7DB),
    accent: orange,
    accentSoft: Color(0xFF3D2A1C),
    primary: Color(0xFF00A884),
    border: Color(0xFF2A3942),
    error: Color(0xFFEF5350),
    bannerGradient: LinearGradient(
      colors: [Color(0xFF1A0A0A), Color(0xFF3B0D12), Color(0xFF0D0D0D)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    quoteGradient: LinearGradient(
      colors: [Color(0xFF1B3A8A), Color(0xFF4B2C8A), Color(0xFF6B3FA0)],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ),
    bookGradient: LinearGradient(
      colors: [Color(0xFF2A1810), Color(0xFF0E0E0E)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  @override
  AppPalette copyWith({
    Color? canvas,
    Color? surface,
    Color? searchFill,
    Color? text,
    Color? textMuted,
    Color? onDark,
    Color? onDarkMuted,
    Color? accent,
    Color? accentSoft,
    Color? primary,
    Color? border,
    Color? error,
    LinearGradient? bannerGradient,
    LinearGradient? quoteGradient,
    LinearGradient? bookGradient,
  }) {
    return AppPalette(
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      searchFill: searchFill ?? this.searchFill,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      onDark: onDark ?? this.onDark,
      onDarkMuted: onDarkMuted ?? this.onDarkMuted,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      primary: primary ?? this.primary,
      border: border ?? this.border,
      error: error ?? this.error,
      bannerGradient: bannerGradient ?? this.bannerGradient,
      quoteGradient: quoteGradient ?? this.quoteGradient,
      bookGradient: bookGradient ?? this.bookGradient,
    );
  }

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return AppPalette(
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      searchFill: Color.lerp(searchFill, other.searchFill, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      onDark: Color.lerp(onDark, other.onDark, t)!,
      onDarkMuted: Color.lerp(onDarkMuted, other.onDarkMuted, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      border: Color.lerp(border, other.border, t)!,
      error: Color.lerp(error, other.error, t)!,
      bannerGradient: t < 0.5 ? bannerGradient : other.bannerGradient,
      quoteGradient: t < 0.5 ? quoteGradient : other.quoteGradient,
      bookGradient: t < 0.5 ? bookGradient : other.bookGradient,
    );
  }
}

extension AppPaletteX on BuildContext {
  AppPalette get colors =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.whatsappLight;
}

/// Static light leftovers for unused recipe screens.
abstract final class AppColors {
  static const Color canvas = Color(0xFFECE5DD);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color searchFill = Color(0xFFD9D0C7);
  static const Color text = Color(0xFF111B21);
  static const Color textMuted = Color(0xFF667781);
  static const Color onDark = Color(0xFFFFFFFF);
  static const Color onDarkMuted = Color(0xFFD1D7DB);
  static const Color teal = AppPalette.orange;
  static const Color selected = AppPalette.orange;
  static const Color selectedSoft = Color(0xFFFFE4D1);
  static const Color primary = Color(0xFF075E54);
  static const Color border = Color(0xFFD1C7BC);
  static const Color error = Color(0xFFC62828);
  static const Color primaryDark = Color(0xFF054C44);
  static const Color coral = AppPalette.orange;
  static const Color softGrey = Color(0xFFE9E1D8);
  static const Color tipBg = Color(0xFFE9E1D8);
  static const Color tipBorder = Color(0xFFD1C7BC);

  static const LinearGradient ctaGradient = LinearGradient(
    colors: [AppPalette.orange, Color(0xFF128C7E), Color(0xFF075E54)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [Color(0xFF1A0A0A), Color(0xFF3B0D12), Color(0xFF0D0D0D)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient quoteGradient = LinearGradient(
    colors: [Color(0xFF1B3A8A), Color(0xFF4B2C8A), Color(0xFF6B3FA0)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient bookGradient = LinearGradient(
    colors: [Color(0xFF2A1810), Color(0xFF0E0E0E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
