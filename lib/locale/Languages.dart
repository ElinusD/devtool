import 'package:flutter/material.dart';

abstract class BaseLanguage {
  static BaseLanguage of(BuildContext context) =>
      Localizations.of<BaseLanguage>(context, BaseLanguage)!;

  String get help;
  String get helpText;
  String get about;
  String get aboutText;
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
  String get database;
  String get deleteDatabase;
  String get error;
  String get titleIsEmpty;
  String get date;
  String get changed;
  String get passwordStrengthRecommendations;
  String get passwordStrengthRecommendationsText;
}
