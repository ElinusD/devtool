import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:devtool/utils/constant.dart';

import './LanguageEn.dart';
import './LanguageUa.dart';
import 'Languages.dart';
import '../main.dart';

class AppLocalizations extends LocalizationsDelegate<BaseLanguage> {
  const AppLocalizations();

  List<LanguageDataModel> languageList() {
    return [
      LanguageDataModel(
          id: 1,
          name: 'English',
          languageCode: 'en',
          fullLanguageCode: 'en-US',
          flag: 'assets/flag/ic_us.png'),
      LanguageDataModel(
          id: 2,
          name: 'Українська',
          languageCode: 'uk',
          fullLanguageCode: 'uk-UA',
          flag: 'assets/flag/ic_ua.png'),
    ];
  }

  @override
  Future<BaseLanguage> load(Locale locale) async {
    switch (locale.languageCode) {
      case 'en':
        return LanguageEn();
      case 'uk':
        return LanguageUa();
      default:
        return LanguageEn();
    }
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

  Future<void> initLocale() async {
    await initialize(aLocaleLanguageList: const AppLocalizations().languageList());
    Locale defaultLocale = WidgetsBinding.instance.platformDispatcher.locale;
    String defaultLanguageCode = defaultLocale.languageCode;

    await appStore.setLanguage(getStringAsync(SELECTED_LANGUAGE_CODE,
        defaultValue: defaultLanguageCode));
  }

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
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
