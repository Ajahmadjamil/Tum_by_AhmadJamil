import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(AppPalette.whatsappLight, Brightness.light);

  static ThemeData get dark => _build(AppPalette.whatsappDark, Brightness.dark);

  static ThemeData _build(AppPalette palette, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: palette.canvas,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: palette.accent,
        onPrimary: palette.onDark,
        secondary: palette.primary,
        onSecondary: palette.onDark,
        surface: palette.surface,
        onSurface: palette.text,
        error: palette.error,
        onError: palette.onDark,
      ),
    );

    return base.copyWith(
      extensions: [palette],
      textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
        bodyColor: palette.text,
        displayColor: palette.text,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: palette.canvas,
        foregroundColor: palette.text,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTextStyles.nastaliq(
          fontSize: 18,
          height: 1.8,
          color: palette.text,
        ),
        iconTheme: IconThemeData(color: palette.text),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: EdgeInsets.zero,
      ),
      dividerColor: palette.border,
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.white;
          return palette.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return palette.accent;
          return palette.border;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: palette.accent,
        inactiveTrackColor: palette.border,
        thumbColor: palette.accent,
        trackHeight: 2,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: palette.accent,
      ),
      iconTheme: IconThemeData(color: palette.text),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: palette.surface,
        indicatorColor: palette.accentSoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: palette.accent);
          }
          return IconThemeData(color: palette.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            color: selected ? palette.accent : palette.textMuted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          );
        }),
      ),
    );
  }
}
