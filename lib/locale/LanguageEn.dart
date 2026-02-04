import 'Languages.dart';

class LanguageEn extends BaseLanguage {
  @override
  String get help => "Help";

  @override
  String get helpText => '''
  Welcome to the Help Center!
We’re here to assist you with any questions or issues you may have while using DevTool. Below are some common topics and tips to help you navigate our app effectively.

Getting Started
Adding Passwords:
Tap the "Add" button on the main screen.
Fill in the required fields: title, login, and password.
Save your entry to store it securely.

Using the Password Generator:
Click "Generate."
Managing Your Passwords
Editing an Entry: Tap on any saved password to edit its details.
Deleting an Entry: Tap on any saved password to edit its details and then tap DELETE button.

Troubleshooting
Forgot Master Password: If you forget your master password, you can reset it using the recovery options provided during setup. Note: This may involve verification steps to secure your account.
App Crashing or Not Responding: Ensure you have the latest version of the app. Try restarting your device or reinstalling the app if issues persist.
FAQs
Q: Is my data secure?
A: Yes! Your passwords are encrypted using industry-standard security protocols.

Q: Can I use the app on multiple devices?
A: Absolutely! Just log in with your account on any device to access your passwords.

Contact Us
If you need further assistance, please reach out to our support team:

Email: [support email]
Website: [website link]
Help Desk: Available from [operating hours].
Thank you for using DevTool! Your security is our priority, and we’re here to help you every step of the way.
  ''';

  @override
  String get about => "About";

  @override
  String get aboutText => '''
Welcome to DevTool!

Our mission is to provide you with a secure solution to store and manage your passwords, helping you stay safe online.
Our features:
Secure storage: Your passwords are encrypted and stored securely, ensuring that only you have access.
User-friendly interface: Our app is designed with simplicity in mind, making it easy for anyone, regardless of technical experience, to use.
Password generator: Create strong, unique passwords with our built-in password generator to increase your security.
Our commitment to safety:
We take your privacy seriously. DevTool uses the latest encryption standards to protect your data.
We never share your information with third parties, ensuring the confidentiality of your passwords.

Contact us
If you have any questions, suggestions or concerns, please contact us at test@gmail.com.

Thank you for choosing DevTool

  ''';

  @override
  String get password => "Password";

  @override
  String get passwordStrength => "Password strength";

  @override
  String get passwords => 'Passwords';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search';

  @override
  String get documents => 'Documents';

  @override
  String get title => 'Title';

  @override
  String get login => 'Login';

  @override
  String get comment => 'Comment';

  @override
  String get url => 'URL';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get add => 'Add';

  @override
  String get language => 'Language';

  @override
  String get database => 'Database';

  @override
  String get deleteDatabase => 'Delete database';

  @override
  String get error => 'Error';

  @override
  String get titleIsEmpty => '"Title" is empty';

  @override
  String get date => 'Date';

  @override
  String get changed => 'Changed';

  @override
  String get passwordStrengthRecommendations =>
      'Password strength recommendations';

  @override
  String get passwordStrengthRecommendationsText => '''
    1. Length Matters: Aim for at least 12-16 characters. Longer passwords are generally harder to crack.
    2. Use a Mix of Characters: Incorporate uppercase and lowercase letters, numbers, and special symbols (e.g., !, @, #, \$).
    3. Avoid Common Words: Don't use easily guessable information like names, birthdays, or common words. Instead, opt for random phrases or a combination of unrelated words.
    4. Use Passphrases: Create a memorable passphrase by stringing together random words or a sentence. For example, "BlueSky!Runs5Fast."
    5. Unique for Each Account: Never reuse passwords across multiple sites. Use a password manager to help keep track of them securely.
    6. Enable Two-Factor Authentication (2FA): Whenever possible, enable 2FA for an extra layer of security, requiring a second form of verification in addition to your password.
  ''';
  
  // Welcome Page
  @override
  String get welcome => 'Welcome';
  
  @override
  String get chooseHowToProceed => 'Choose how you want to proceed';
  
  @override
  String get createNewDB => 'Create New DB';
  
  @override
  String get importDB => 'Import DB';
  
  // Master Password Page
  @override
  String get createMasterPassword => 'Create Master Password';
  
  @override
  String get welcomeBack => 'Welcome Back';
  
  @override
  String get secureYourData => 'Secure your data with a master password';
  
  @override
  String get enterMasterPassword => 'Enter your master password to continue';
  
  @override
  String get hint => 'Hint';
  
  @override
  String get passwordField => 'Password';
  
  @override
  String get enterPassword => 'Enter your password';
  
  @override
  String get confirmPasswordField => 'Confirm Password';
  
  @override
  String get confirmPasswordHint => 'Confirm your password';
  
  @override
  String get pleaseEnterPassword => 'Please enter a password';
  
  @override
  String get passwordMinLength => 'Password must be at least 4 characters';
  
  @override
  String get pleaseConfirmPassword => 'Please confirm your password';
  
  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
  
  @override
  String get createPassword => 'Create Password';
  
  @override
  String get unlock => 'Unlock';
  
  @override
  String get importDatabase => 'Import Database';
  
  @override
  String get importing => 'Importing...';
  
  @override
  String get importDatabaseInstead => 'Import Database Instead';
  
  @override
  String get importingDatabase => 'Importing database...';
  
  @override
  String get incorrectMasterPassword => 'Incorrect master password';
  
  @override
  String get errorCreatingMasterPassword => 'Error creating master password';
  
  @override
  String get errorVerifyingPassword => 'Error verifying password';
  
  // Import/Export
  @override
  String get importDatabaseQuestion => 'Import Database?';
  
  @override
  String get importDatabaseWarning => 'This will replace your current database with the imported one. Your current database will be backed up. Are you sure you want to continue?';
  
  @override
  String get databaseImportedSuccessfully => 'Database imported successfully';
  
  @override
  String get errorImportingDatabase => 'Error importing database';
  
  @override
  String get exportDatabase => 'Export Database';
  
  @override
  String get exporting => 'Exporting...';
  
  @override
  String get databaseExportedTo => 'Database exported to';
  
  @override
  String get filePickerCancelled => 'File picker was cancelled';
  
  @override
  String get filePickerPermissionError => 'File picker dialog did not open. Please ensure the app has file access permissions and was rebuilt after adding entitlements.';
  
  // Settings Page
  @override
  String get settingsSaved => 'Settings saved';
  
  @override
  String get pleaseFillAllFields => 'Please fill in all fields';
  
  @override
  String get newPasswordMinLength => 'New password must be at least 4 characters';
  
  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match';
  
  @override
  String get masterPasswordChangedSuccessfully => 'Master password changed successfully';
  
  @override
  String get masterPhraseSaved => 'Master phrase saved';
  
  @override
  String get pleaseEnterEncryptionKey => 'Please enter an encryption key';
  
  @override
  String get encryptionKeyMinLength => 'Encryption key must be at least 8 characters';
  
  @override
  String get changeEncryptionKeyQuestion => 'Change Encryption Key?';
  
  @override
  String get changeEncryptionKeyWarning => 'This will re-encrypt all your data. This process cannot be undone. Are you sure you want to continue?';
  
  @override
  String get continueAction => 'Continue';
  
  @override
  String get encryptionKeyChangedSuccessfully => 'Encryption key changed successfully. All data has been re-encrypted.';
  
  @override
  String get passwordLength => 'Password Length';
  
  @override
  String get decrease => 'Decrease';
  
  @override
  String get increase => 'Increase';
  
  @override
  String get includeLetters => 'Include Letters';
  
  @override
  String get includeLettersDesc => 'Include Letters (a-z)';
  
  @override
  String get includeNumbers => 'Include Numbers';
  
  @override
  String get includeNumbersDesc => 'Include Numbers (0-9)';
  
  @override
  String get specialCharacters => 'Special Characters';
  
  @override
  String get includeSpecialCharacters => 'Include Special Characters (!@#\$%...)';
  
  @override
  String get includeUppercase => 'Include Uppercase';
  
  @override
  String get includeUppercaseDesc => 'Include Uppercase Letters (A-Z)';
  
  @override
  String get savePasswordSettings => 'Save Password Settings';
  
  @override
  String get currentPassword => 'Current Password';
  
  @override
  String get currentPasswordField => 'Current Password';
  
  @override
  String get newPassword => 'New Password';
  
  @override
  String get newPasswordField => 'New Password';
  
  @override
  String get confirmNewPassword => 'Confirm New Password';
  
  @override
  String get changeMasterPassword => 'Change Master Password';
  
  @override
  String get changing => 'Changing...';
  
  @override
  String get masterPhrase => 'Master Phrase';
  
  @override
  String get masterPhraseField => 'Master Phrase';
  
  @override
  String get masterPhraseHint => 'Enter a hint phrase to remember your password';
  
  @override
  String get saveMasterPhrase => 'Save Master Phrase';
  
  @override
  String get encryptionKey => 'Encryption Key';
  
  @override
  String get encryptionKeyWarning => 'Warning: This will re-encrypt all data';
  
  @override
  String get encryptionKeyField => 'Encryption Key';
  
  @override
  String get encryptionKeyHint => 'Enter at least 8 characters';
  
  @override
  String get changeEncryptionKey => 'Change Encryption Key';
  
  @override
  String get reEncrypting => 'Re-encrypting...';
  
  @override
  String get openingFilePicker => 'Opening file picker...';
  
  // Delete
  @override
  String get deleteDatabaseQuestion => 'Delete Database?';
  
  @override
  String get deleteDatabaseWarning => 'Are you sure you want to delete the database? This action cannot be undone. All your passwords and settings will be permanently deleted.';
  
  @override
  String get databaseDeleted => 'Database deleted';
  
  // Passwords Page
  @override
  String get enterNewRecordData => 'Enter new record data';
  
  @override
  String get ok => 'OK';
  
  @override
  String get confirmAction => 'Confirm Action';
  
  @override
  String get areYouSureDelete => 'Are you sure you want to delete?';
}
