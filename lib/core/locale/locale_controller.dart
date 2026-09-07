import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../local_db/session_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController({SessionStore? store}) : _store = store ?? SessionStore();

  final SessionStore _store;

  bool isUrdu = true;

  AppStrings get strings => AppStrings(urdu: isUrdu);

  Locale get locale => isUrdu ? const Locale('ur') : const Locale('en');

  TextDirection get textDirection =>
      isUrdu ? TextDirection.rtl : TextDirection.ltr;

  Future<void> load() async {
    final code = await _store.readLocaleCode();
    isUrdu = code != 'en';
    notifyListeners();
  }

  Future<void> setEnglish(bool enabled) async {
    isUrdu = !enabled;
    await _store.saveLocaleCode(isUrdu ? 'ur' : 'en');
    notifyListeners();
  }

  String pick({required String urdu, required String english}) {
    if (isUrdu) return urdu;
    return english.isEmpty ? urdu : english;
  }
}
