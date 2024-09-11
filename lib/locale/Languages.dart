import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get password;
  String get passwordStrength;
  String get passwords;
  String get settings;
  String get search;
  String get documents;
  String get title;
  String get login;
  String get comment;
  String get url;
  String get save;
  String get delete;
  String get cancel;
  String get confirm;
  String get add;
  String get language;
}
