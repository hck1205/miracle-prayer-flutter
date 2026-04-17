import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";

import "src/design/editorial_theme.dart";
import "src/localization/app_locale.dart";
import "src/localization/app_locale_controller.dart";
import "src/localization/app_locale_scope.dart";
import "src/localization/app_strings.dart";
import "src/ui/auth/auth_page.dart";

void main() {
  runApp(const MiraclePrayerApp());
}

class MiraclePrayerApp extends StatefulWidget {
  const MiraclePrayerApp({super.key});

  @override
  State<MiraclePrayerApp> createState() => _MiraclePrayerAppState();
}

class _MiraclePrayerAppState extends State<MiraclePrayerApp> {
  late final AppLocaleController _localeController;

  @override
  void initState() {
    super.initState();
    _localeController = AppLocaleController();
    _localeController.bootstrap();
  }

  @override
  void dispose() {
    _localeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppLocaleScope(
      controller: _localeController,
      child: AnimatedBuilder(
        animation: _localeController,
        builder: (BuildContext context, _) {
          final AppStrings strings = context.strings;

          return MaterialApp(
            title: strings.appTitle,
            locale: _localeController.locale,
            supportedLocales: AppLocale.supportedLocales,
            localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            debugShowCheckedModeBanner: false,
            theme: EditorialTheme.buildTheme(),
            home: const AuthPage(),
          );
        },
      ),
    );
  }
}
