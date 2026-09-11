import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:tum/core/notification/notification.dart';
import 'core/auth/auth_controller.dart';
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
  await FirebaseNotificationService.initialize();
  await AppSupabase.initialize();

  final localeController = LocaleController();
  final themeController = ThemeController();
  final catalogController = CatalogController();
  final authController = AuthController();
  final favoritesController = FavoritesController(auth: authController);
  await Future.wait([
    localeController.load(),
    themeController.load(),
  ]);

  runApp(
    TumApp(
      localeController: localeController,
      themeController: themeController,
      catalogController: catalogController,
      authController: authController,
      favoritesController: favoritesController,
    ),
  );

  unawaited(authController.load());
  unawaited(favoritesController.load());
  unawaited(() async {
    await catalogController.hydrateFromCache();
    await catalogController.refreshFromNetwork();
  }());
}

class TumApp extends StatelessWidget {
  const TumApp({
    super.key,
    required this.localeController,
    required this.themeController,
    required this.catalogController,
    required this.authController,
    required this.favoritesController,
  });

  final LocaleController localeController;
  final ThemeController themeController;
  final CatalogController catalogController;
  final AuthController authController;
  final FavoritesController favoritesController;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: localeController),
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: catalogController),
        ChangeNotifierProvider.value(value: authController),
        ChangeNotifierProvider.value(value: favoritesController),
      ],
      child: Consumer2<LocaleController, ThemeController>(
        builder: (context, locale, theme, _) {
          return MaterialApp(
            title: locale.strings.appName,
            debugShowCheckedModeBanner: false,
            themeAnimationDuration: Duration.zero,
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
