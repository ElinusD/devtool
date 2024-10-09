import 'Languages.dart';

class LanguageUa extends BaseLanguage {
  @override
  String get help => "Допомога";

  @override
  String get helpText => '''
  
  Welcome to the Help Center!
We’re here to assist you with any questions or issues you may have while using [Your App Name]. Below are some common topics and tips to help you navigate our app effectively.

Getting Started
Creating an Account:

Download the app from [App Store/Google Play].
Open the app and select "Create Account."
Follow the prompts to set up your account and secure your master password.
Adding Passwords:

Tap the "Add Password" button on the main screen.
Fill in the required fields: website, username, and password.
Save your entry to store it securely.
Using the Password Generator:

Access the password generator from the main menu.
Choose your preferences for length and complexity, then click "Generate."
Managing Your Passwords
Editing an Entry: Tap on any saved password to edit its details.
Deleting an Entry: Swipe left on the entry in the list and tap "Delete."
Organizing with Folders: Create folders to categorize your passwords for easier access.
Security Features
Two-Factor Authentication: Enable 2FA for an added layer of security. Go to Settings > Security > Two-Factor Authentication.
Backup Your Data: Regularly back up your passwords by exporting them through the app’s settings.
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
Thank you for using [Your App Name]! Your security is our priority, and we’re here to help you every step of the way.
  ''';

  @override
  String get about => "Про программу";

  @override
  String get aboutText => '''
Ласкаво просимо до DevTool!

Наша місія — надати вам безпечне рішення для зберігання і керувати вашими паролями, допомагаючи вам залишатися в безпеці в Інтернеті.
Наші особливості:
Безпечне зберігання: ваші паролі зашифровано та безпечно зберігаються, гарантуючи, що лише ви маєте доступ.
Зручний інтерфейс: наша програма розроблена з урахуванням простоти, полегшуючи використання для будь-кого, незалежно від технічного досвіду.
Генератор паролів: створюйте надійні унікальні паролі за допомогою нашого вбудованого генератора паролів щоб підвищити вашу безпеку.
Наша відданість безпеці:
Ми серйозно ставимося до вашої конфіденційності. DevTool використовує найновіше шифрування стандарти захисту ваших даних. 
Ми ніколи не передаємо вашу інформацію третім сторонам, забезпечення конфіденційності ваших паролів.

Зв'яжіться з нами
Якщо у вас є запитання, пропозиції чи сумніви, зв’яжіться з нами за адресою test@gmail.com.

Дякуємо, що вибрали DevTool

  ''';

  @override
  String get password => 'Пароль';

  @override
  String get passwordStrength => "Складність паролю";

  @override
  String get passwords => 'Паролі';

  @override
  String get settings => 'Налаштування';

  @override
  String get search => 'Пошук';

  @override
  String get documents => 'Документи';

  @override
  String get title => 'Назва';

  @override
  String get login => 'Логін';

  @override
  String get comment => 'Коментар';

  @override
  String get url => 'Посилання';

  @override
  String get save => 'Зберегти';

  @override
  String get delete => 'Видалити';

  @override
  String get cancel => 'Відмінити';

  @override
  String get confirm => 'Підтвердити';

  @override
  String get add => 'Додати';

  @override
  String get language => 'Мова';

  @override
  String get database => 'База даних';

  @override
  String get deleteDatabase => 'Видалити базу даних';

  @override
  String get error => 'Помилка';

  @override
  String get titleIsEmpty => '"Назва" не може бути порожньою';

  @override
  String get date => 'Дата';

  @override
  String get changed => 'Змінено';

  @override
  String get passwordStrengthRecommendations => 'Рекомендації міцності паролю';

  @override
  String get passwordStrengthRecommendationsText => '''
    1. Довжина має значення: прагніть до принаймні 12-16 символів. Довші паролі, як правило, важче зламати.
    2. Використовуйте комбінацію символів: додайте великі та малі літери, цифри та спеціальні символи (наприклад, !, @, #, \$).
    3. Уникайте загальних слів: не використовуйте інформацію, яку легко вгадати, як-от імена, дні народження чи загальні слова. Замість цього вибирайте випадкові фрази або поєднання незв’язаних слів.
    4. Використовуйте парольні фрази: створіть запам’ятовувану парольну фразу, з’єднавши випадкові слова чи речення. Наприклад, «BlueSky! Runs5Fast».
    5. Унікальний для кожного облікового запису: ніколи не використовуйте паролі на кількох сайтах. Використовуйте менеджер паролів, щоб безпечно відстежувати їх.
    6. Увімкніть двофакторну автентифікацію (2FA): якщо можливо, увімкніть 2FA для додаткового рівня безпеки, вимагаючи другу форму перевірки на додаток до вашого пароля.
  ''';
}
