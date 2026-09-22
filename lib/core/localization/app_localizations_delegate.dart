import 'package:flutter/material.dart';

import 'app_locales.dart';
import 'app_strings.dart';

/// Localization delegate that serves [AppStrings] for the active locale.
class AppLocalizationsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocales.supported.contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) async =>
      AppStrings(locale.languageCode);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
