import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import '../main.dart';
import 'package:devtool/utils/constant.dart';

import '/locale/AppLocalizations.dart';

Future<void> initLocale() async {
  await initialize(aLocaleLanguageList: const AppLocalizations().languageList());
  Locale defaultLocale = WidgetsBinding.instance.platformDispatcher.locale;
  String defaultLanguageCode = defaultLocale.languageCode;

  await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE,
      defaultValue: defaultLanguageCode));
}

List<Locale> getSupportedLocales() {
  return const [
    Locale('en', 'US'),
    Locale('uk', 'UA'),
  ];
}

Locale getCurrentLocale() {
  return Locale(getStringAsync(SELECTED_LANGUAGE_CODE,
      defaultValue: defaultLanguage));
}

class UkrainianMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const UkrainianMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'uk';

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    throw UnimplementedError();
  }

  @override
  bool shouldReload(UkrainianMaterialLocalizationsDelegate old) => false;
}
