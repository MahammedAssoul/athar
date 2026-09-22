import 'package:flutter/material.dart';

import '../../data/services/local_storage.dart';
import 'app_locales.dart';

/// App-level locale state so language can change at runtime.
class LocaleController extends ChangeNotifier {
  LocaleController([this._locale = const Locale(AppLocales.ar)]);

  Locale _locale;

  Locale get locale => _locale;

  bool get isAr => _locale.languageCode == AppLocales.ar;

  void setLocale(String code) {
    if (code == _locale.languageCode) return;
    _locale = Locale(code);
    LocalStorage.setLanguage(code);
    notifyListeners();
  }
}
