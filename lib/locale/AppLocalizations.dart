import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

import './LanguageEn.dart';
import './LanguageUa.dart';
import 'Languages.dart';

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
          flag: 'assets/flag/ic_ru.png'),
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

  @override
  bool isSupported(Locale locale) => LanguageDataModel.languages().contains(locale.languageCode);

  @override
  bool shouldReload(LocalizationsDelegate<BaseLanguage> old) => false;
}
