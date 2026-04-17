import "package:flutter/widgets.dart";
import "package:shared_preferences/shared_preferences.dart";

import "app_locale.dart";

class AppLocaleController extends ChangeNotifier {
  static const String _storageKey = "app_locale";

  AppLocale _appLocale = AppLocale.fallback();
  bool _didBootstrap = false;

  AppLocale get appLocale => _appLocale;
  Locale get locale => _appLocale.locale;

  Future<void> bootstrap() async {
    if (_didBootstrap) {
      return;
    }

    _didBootstrap = true;
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final String? savedLanguageCode = preferences.getString(_storageKey);
    final Locale deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    _appLocale = savedLanguageCode == null
        ? AppLocale.resolveFromDevice(deviceLocale)
        : AppLocale.fromLanguageCode(savedLanguageCode);
    notifyListeners();
  }

  Future<void> setLocale(AppLocale nextLocale) async {
    if (nextLocale == _appLocale) {
      return;
    }

    _appLocale = nextLocale;
    notifyListeners();

    final SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.setString(_storageKey, nextLocale.languageCode);
  }
}
