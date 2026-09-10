import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';

import 'package:tum/core/auth/auth_controller.dart';
import 'package:tum/core/locale/locale_controller.dart';
import 'package:tum/core/theme/app_theme.dart';
import 'package:tum/core/theme/theme_controller.dart';
import 'package:tum/features/favorites/controller.dart';
import 'package:tum/features/poetry/controller.dart';
import 'package:tum/features/shell/view.dart';

void main() {
  testWidgets('shows home shell with bottom navigation', (tester) async {
    final auth = AuthController();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LocaleController()),
          ChangeNotifierProvider(create: (_) => ThemeController()),
          ChangeNotifierProvider(create: (_) => CatalogController()),
          ChangeNotifierProvider.value(value: auth),
          ChangeNotifierProvider(create: (_) => FavoritesController(auth: auth)),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const ShellScreen(),
        ),
      ),
    );

    expect(find.byType(GNav), findsOneWidget);
    expect(find.byIcon(Icons.home_rounded), findsWidgets);
    expect(find.byIcon(Icons.favorite_rounded), findsWidgets);
    expect(find.byIcon(Icons.photo_rounded), findsWidgets);
    expect(find.byIcon(Icons.person_rounded), findsWidgets);
    expect(find.text('ہوم'), findsWidgets);
  });
}
