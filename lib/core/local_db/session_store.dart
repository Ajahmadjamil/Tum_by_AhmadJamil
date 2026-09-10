import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _localeKey = 'app_locale';
  static const _themeKey = 'app_is_dark';
  static const _readerAlignKey = 'reader_body_align';
  static const _readerFontKey = 'reader_font_size';

  Future<void> saveIsDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> readIsDark() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> saveLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  Future<String> readLocaleCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_localeKey) ?? 'ur';
  }

  Future<void> saveReaderAlign(String align) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readerAlignKey, align);
  }

  Future<String> readReaderAlign() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_readerAlignKey) ?? 'center';
  }

  Future<void> saveReaderFontSize(String size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_readerFontKey, size);
  }

  Future<String> readReaderFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_readerFontKey) ?? 'medium';
  }
}
