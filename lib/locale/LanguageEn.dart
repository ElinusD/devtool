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
    3. Avoid Common Words: Don’t use easily guessable information like names, birthdays, or common words. Instead, opt for random phrases or a combination of unrelated words.
    4. Use Passphrases: Create a memorable passphrase by stringing together random words or a sentence. For example, “BlueSky!Runs5Fast.”
    5. Unique for Each Account: Never reuse passwords across multiple sites. Use a password manager to help keep track of them securely.
    6. Enable Two-Factor Authentication (2FA): Whenever possible, enable 2FA for an extra layer of security, requiring a second form of verification in addition to your password.
  ''';
}
