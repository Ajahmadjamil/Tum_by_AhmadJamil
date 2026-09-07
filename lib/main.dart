import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/locale/locale_controller.dart';
import 'core/supabase/app_supabase.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'features/favorites/controller.dart';
import 'features/poetry/controller.dart';
import 'features/shell/view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: const [SystemUiOverlay.top],
  );
  await AppSupabase.initialize();

  final localeController = LocaleController();
  final themeController = ThemeController();
  final catalogController = CatalogController();
  final favoritesController = FavoritesController();
  await Future.wait([
    localeController.load(),
    themeController.load(),
    catalogController.load(),
    favoritesController.load(),
  ]);

  runApp(
    TumApp(
      localeController: localeController,
      themeController: themeController,
      catalogController: catalogController,
      favoritesController: favoritesController,
    ),
  );
}

class TumApp extends StatelessWidget {
  const TumApp({
    super.key,
    required this.localeController,
    required this.themeController,
    required this.catalogController,
    required this.favoritesController,
  });

  final LocaleController localeController;
  final ThemeController themeController;
  final CatalogController catalogController;
  final FavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: catalogController),
        ChangeNotifierProvider.value(value: favoritesController),
      ],
      child: Consumer2<LocaleController, ThemeController>(
        builder: (context, locale, theme, _) {
          SystemChrome.setEnabledSystemUIMode(
            SystemUiMode.manual,
            overlays: const [SystemUiOverlay.top],
          );
          SystemChrome.setSystemUIOverlayStyle(
            SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness:
                  theme.isDark ? Brightness.light : Brightness.dark,
              systemNavigationBarColor: Colors.transparent,
              systemNavigationBarDividerColor: Colors.transparent,
              systemNavigationBarContrastEnforced: false,
              systemNavigationBarIconBrightness:
                  theme.isDark ? Brightness.light : Brightness.dark,
            ),
          );
          return MaterialApp(
            title: locale.strings.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: theme.mode,
            locale: locale.locale,
            builder: (context, child) {
              return Directionality(
                textDirection: locale.textDirection,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: const ShellScreen(),
          );
        },
      ),
    );
  }
}
