import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/theme_controller.dart';
import '../favorites/view.dart';
import '../gallery/view.dart';
import '../home/view.dart';
import '../profile/view.dart';
import 'widgets/bottom_nav.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  Future<void> _onBack() async {
    if (_index != 0) {
      setState(() => _index = 0);
      return;
    }

    final locale = context.read<LocaleController>();
    final colors = context.colors;
    final strings = locale.strings;
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.surface,
          title: Text(
            strings.exitAppTitle,
            style: AppTextStyles.heading(
              locale.isUrdu,
              fontSize: 18,
              color: colors.text,
            ),
          ),
          content: Text(
            strings.exitAppBody,
            style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                strings.cancel,
                style: AppTextStyles.label(locale.isUrdu, color: colors.textMuted),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                strings.exit,
                style: AppTextStyles.label(locale.isUrdu, color: colors.accent),
              ),
            ),
          ],
        );
      },
    );

    if (shouldExit == true) {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeController>();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [
            HomeScreen(),
            FavoritesScreen(),
            GalleryScreen(),
            ProfileScreen(),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          index: _index,
          onChanged: (index) => setState(() => _index = index),
        ),
      ),
    );
  }
}
