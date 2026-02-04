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
  
  // Welcome Page
  String get welcome;
  String get chooseHowToProceed;
  String get createNewDB;
  String get importDB;
  
  // Master Password Page
  String get createMasterPassword;
  String get welcomeBack;
  String get secureYourData;
  String get enterMasterPassword;
  String get hint;
  String get passwordField;
  String get enterPassword;
  String get confirmPasswordField;
  String get confirmPasswordHint;
  String get pleaseEnterPassword;
  String get passwordMinLength;
  String get pleaseConfirmPassword;
  String get passwordsDoNotMatch;
  String get createPassword;
  String get unlock;
  String get importDatabase;
  String get importing;
  String get importDatabaseInstead;
  String get importingDatabase;
  String get incorrectMasterPassword;
  String get errorCreatingMasterPassword;
  String get errorVerifyingPassword;
  
  // Import/Export
  String get importDatabaseQuestion;
  String get importDatabaseWarning;
  String get databaseImportedSuccessfully;
  String get errorImportingDatabase;
  String get exportDatabase;
  String get exporting;
  String get databaseExportedTo;
  String get filePickerCancelled;
  String get filePickerPermissionError;
  
  // Settings Page
  String get settingsSaved;
  String get pleaseFillAllFields;
  String get newPasswordMinLength;
  String get newPasswordsDoNotMatch;
  String get masterPasswordChangedSuccessfully;
  String get masterPhraseSaved;
  String get pleaseEnterEncryptionKey;
  String get encryptionKeyMinLength;
  String get changeEncryptionKeyQuestion;
  String get changeEncryptionKeyWarning;
  String get continueAction;
  String get encryptionKeyChangedSuccessfully;
  String get passwordLength;
  String get decrease;
  String get increase;
  String get includeLetters;
  String get includeLettersDesc;
  String get includeNumbers;
  String get includeNumbersDesc;
  String get specialCharacters;
  String get includeSpecialCharacters;
  String get includeUppercase;
  String get includeUppercaseDesc;
  String get savePasswordSettings;
  String get currentPassword;
  String get currentPasswordField;
  String get newPassword;
  String get newPasswordField;
  String get confirmNewPassword;
  String get changeMasterPassword;
  String get changing;
  String get masterPhrase;
  String get masterPhraseField;
  String get masterPhraseHint;
  String get saveMasterPhrase;
  String get encryptionKey;
  String get encryptionKeyWarning;
  String get encryptionKeyField;
  String get encryptionKeyHint;
  String get changeEncryptionKey;
  String get reEncrypting;
  String get openingFilePicker;
  
  // Delete
  String get deleteDatabaseQuestion;
  String get deleteDatabaseWarning;
  String get databaseDeleted;
  
  // Passwords Page
  String get enterNewRecordData;
  String get ok;
  String get confirmAction;
  String get areYouSureDelete;
}
