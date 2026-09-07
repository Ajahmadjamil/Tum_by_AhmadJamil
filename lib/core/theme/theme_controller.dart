import 'package:flutter/material.dart';

import '../local_db/session_store.dart';

class ThemeController extends ChangeNotifier {
  ThemeController({SessionStore? store}) : _store = store ?? SessionStore();

  final SessionStore _store;

  bool isDark = false;

  ThemeMode get mode => isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    isDark = await _store.readIsDark();
    notifyListeners();
  }

  Future<void> setDark(bool enabled) async {
    if (isDark == enabled) return;
    isDark = enabled;
    notifyListeners();
    await _store.saveIsDark(enabled);
  }

  Future<void> toggle() => setDark(!isDark);
}
