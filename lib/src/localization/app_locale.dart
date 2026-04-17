import "dart:ui";

enum AppLocale {
  ko("ko", "KO"),
  en("en", "EN");

  const AppLocale(this.languageCode, this.label);

  final String languageCode;
  final String label;

  Locale get locale => Locale(languageCode);

  static List<Locale> get supportedLocales => AppLocale.values
      .map((AppLocale locale) => locale.locale)
      .toList(growable: false);

  static AppLocale fallback() => AppLocale.en;

  static AppLocale fromLanguageCode(String? languageCode) {
    return AppLocale.values.firstWhere(
      (AppLocale locale) => locale.languageCode == languageCode,
      orElse: AppLocale.fallback,
    );
  }

  static AppLocale resolveFromDevice(Locale deviceLocale) {
    return fromLanguageCode(deviceLocale.languageCode);
  }
}
