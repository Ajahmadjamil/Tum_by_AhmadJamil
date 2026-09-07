import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import '../../../core/locale/locale_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/theme_controller.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    final locale = context.watch<LocaleController>();
    final strings = locale.strings;
    final colors = context.colors;
    final selectedBg =
        theme.isDark ? const Color(0xFF0B141A) : const Color(0xFF111B21);
    final labelStyle = locale.isUrdu
        ? AppTextStyles.nastaliq(
            fontSize: 16,
            color: Colors.white,
            height: 1.35,
            fontWeight: FontWeight.w600,
          )
        : AppTextStyles.ui(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          );

    return Material(
      color: colors.surface,
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(
            top: BorderSide(color: colors.border, width: 0.8),
          ),
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: GNav(
                selectedIndex: index,
                onTabChange: onChanged,
                haptic: true,
                gap: 8,
                iconSize: 24,
                textSize: 16,
                tabBorderRadius: 24,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                duration: const Duration(milliseconds: 240),
                color: colors.textMuted,
                activeColor: Colors.white,
                tabBackgroundColor: selectedBg,
                rippleColor: Colors.white24,
                hoverColor: Colors.transparent,
                textStyle: labelStyle,
                padding: EdgeInsets.symmetric(
                  horizontal: locale.isUrdu ? 16 : 14,
                  vertical: locale.isUrdu ? 12 : 11,
                ),
                tabs: [
                  GButton(icon: Icons.home_rounded, text: strings.home),
                  GButton(icon: Icons.favorite_rounded, text: strings.favorites),
                  GButton(icon: Icons.photo_rounded, text: strings.gallery),
                  GButton(icon: Icons.person_rounded, text: strings.profile),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
