import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleController>();
    final theme = context.watch<ThemeController>();
    final colors = context.colors;
    final strings = locale.strings;

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: colors.surface,
            child: Icon(Icons.person, size: 36, color: colors.text),
          ),
          const SizedBox(height: 14),
          Text(
            strings.appName,
            textAlign: TextAlign.center,
            style: AppTextStyles.nastaliq(
              fontSize: 28,
              height: 1.7,
              color: colors.text,
            ),
          ),
          const SizedBox(height: 28),
          _SettingCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.language,
                    style: AppTextStyles.heading(
                      locale.isUrdu,
                      fontSize: 16,
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  strings.urduLabel,
                  style: AppTextStyles.nastaliq(
                    fontSize: 14,
                    color: locale.isUrdu ? colors.accent : colors.textMuted,
                    height: 1.6,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: !locale.isUrdu,
                  onChanged: locale.setEnglish,
                ),
                const SizedBox(width: 8),
                Text(
                  strings.englishLabel,
                  style: AppTextStyles.ui(
                    fontSize: 14,
                    color: locale.isUrdu ? colors.textMuted : colors.accent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _SettingCard(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    strings.theme,
                    style: AppTextStyles.heading(
                      locale.isUrdu,
                      fontSize: 16,
                      color: colors.text,
                    ),
                  ),
                ),
                Text(
                  strings.lightTheme,
                  style: AppTextStyles.label(
                    locale.isUrdu,
                    color: theme.isDark ? colors.textMuted : colors.accent,
                  ),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: theme.isDark,
                  onChanged: (enabled) => theme.setDark(enabled),
                ),
                const SizedBox(width: 8),
                Text(
                  strings.darkTheme,
                  style: AppTextStyles.label(
                    locale.isUrdu,
                    color: theme.isDark ? colors.accent : colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: child,
    );
  }
}
