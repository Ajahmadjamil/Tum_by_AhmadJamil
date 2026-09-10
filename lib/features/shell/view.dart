import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/alerts/show_dialogs.dart';
import '../../core/auth/auth_controller.dart';
import '../../core/haptics/app_haptics.dart';
import '../../core/locale/locale_controller.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
  final Set<int> _visited = {0};
  AuthController? _auth;
  bool _editToastShown = false;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AuthController>();
    _auth!.addListener(_onAuthChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onAuthChanged());
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final auth = _auth;
    if (auth == null) return;
    if (!auth.isSignedIn) {
      _editToastShown = false;
      return;
    }
    if (_editToastShown || !auth.hasEditPermission) return;
    _editToastShown = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ShowDialogs.editorAccess(context);
    });
  }

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
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }

  Widget _tab(int index, Widget child) {
    if (!_visited.contains(index)) return const SizedBox.shrink();
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onBack();
      },
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: [
            const HomeScreen(),
            _tab(1, const FavoritesScreen()),
            _tab(2, const GalleryScreen()),
            _tab(3, const ProfileScreen()),
          ],
        ),
        bottomNavigationBar: AppBottomNav(
          index: _index,
          onChanged: (index) {
            AppHaptics.selection();
            setState(() {
              _visited.add(index);
              _index = index;
            });
          },
        ),
      ),
    );
  }
}
