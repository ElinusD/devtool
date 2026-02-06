import 'package:devtool/main.dart';
import 'package:devtool/utils/db.dart';
import 'package:devtool/pages/masterPasswordPage.dart';
import 'package:devtool/pages/welcomePage.dart';
import 'package:devtool/locale/Languages.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

class SettingsPage extends StatefulWidget {
  final void Function(int) redrawMainPage;

  const SettingsPage({super.key, required this.redrawMainPage});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _passwordLength = 12;
  bool _useLetters = true;
  bool _useNumbers = true;
  bool _useSpecialChar = true;
  bool _useUppercase = true;
  bool _isLoading = true;
  
  // Master password change
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isChangingPassword = false;
  
  // Master phrase
  final TextEditingController _masterPhraseController = TextEditingController();
  
  // Crypto string
  final TextEditingController _cryptoStringController = TextEditingController();
  bool _isCryptoStringVisible = false;
  bool _isChangingCryptoString = false;
  
  // Export database
  bool _isExporting = false;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _masterPhraseController.dispose();
    _cryptoStringController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await initDatabase();
    setState(() {
      _isLoading = true;
    });

    final length = int.tryParse(await getSetting('password_length') ?? '12') ?? 12;
    final letters = (await getSetting('password_letters') ?? 'true') == 'true';
    final numbers = (await getSetting('password_numbers') ?? 'true') == 'true';
    final specialChar = (await getSetting('password_special_char') ?? 'true') == 'true';
    final uppercase = (await getSetting('password_uppercase') ?? 'true') == 'true';
    final masterPhrase = await getMasterPhrase() ?? '';
    final cryptoString = await getSetting('crypto_string') ?? '';

    setState(() {
      _passwordLength = length;
      _useLetters = letters;
      _useNumbers = numbers;
      _useSpecialChar = specialChar;
      _useUppercase = uppercase;
      _masterPhraseController.text = masterPhrase;
      _cryptoStringController.text = cryptoString;
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    await initDatabase();
    await setSetting('password_length', _passwordLength.toString());
    await setSetting('password_letters', _useLetters.toString());
    await setSetting('password_numbers', _useNumbers.toString());
    await setSetting('password_special_char', _useSpecialChar.toString());
    await setSetting('password_uppercase', _useUppercase.toString());
    
    final language = BaseLanguage.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(language.settingsSaved),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _changeMasterPassword() async {
    if (_oldPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      final language = BaseLanguage.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language.pleaseFillAllFields),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 4) {
      final language = BaseLanguage.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language.newPasswordMinLength),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      final language = BaseLanguage.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language.newPasswordsDoNotMatch),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      await initDatabase();
      await changeMasterPassword(
        _oldPasswordController.text,
        _newPasswordController.text,
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      if (mounted) {
        final language = BaseLanguage.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language.masterPasswordChangedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  Future<void> _saveMasterPhrase() async {
    await initDatabase();
    await setMasterPhrase(_masterPhraseController.text);
    
    final language = BaseLanguage.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(language.masterPhraseSaved),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Future<void> _changeCryptoString() async {
    final newCryptoString = _cryptoStringController.text.trim();
    
    if (newCryptoString.isEmpty) {
      final language = BaseLanguage.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language.pleaseEnterEncryptionKey),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    if (newCryptoString.length < 8) {
      final language = BaseLanguage.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(language.encryptionKeyMinLength),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    
    // Confirm with user
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        final language = BaseLanguage.of(context);
        return AlertDialog(
          title: Text(language.changeEncryptionKeyQuestion),
          content: Text(language.changeEncryptionKeyWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(language.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              child: Text(language.continueAction),
            ),
          ],
        );
      },
    );
    
    if (confirmed != true) {
      return;
    }
    
    setState(() {
      _isChangingCryptoString = true;
    });
    
    try {
      await initDatabase();
      await changeCryptoString(newCryptoString);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(language.encryptionKeyChangedSuccessfully),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingCryptoString = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primaryContainer.withOpacity(0.2),
            colorScheme.surface,
            colorScheme.secondaryContainer.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  // Language Settings
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.language,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dividerColor: Colors.transparent,
                            inputDecorationTheme: InputDecorationTheme(
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                            ),
                            dropdownMenuTheme: DropdownMenuThemeData(
                              menuStyle: MenuStyle(
                                elevation: WidgetStateProperty.all(0),
                                shadowColor: WidgetStateProperty.all(Colors.transparent),
                                surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
                              ),
                            ),
                            popupMenuTheme: PopupMenuThemeData(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                            ),
                          ),
                          child: LanguageListWidget(
                            widgetType: WidgetType.DROPDOWN,
                            onLanguageChange: (v) async {
                              await appStore.setLanguage(v.languageCode!, context: context);
                              widget.redrawMainPage(2);
                              setState(() {});
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Password Length
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Password Length',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: () async {
                                if (_passwordLength > 4) {
                                  setState(() {
                                    _passwordLength--;
                                  });
                                  await initDatabase();
                                  await setSetting('password_length', _passwordLength.toString());
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: language.decrease,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: colorScheme.outline.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: (_passwordLength - 4) / 28,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: () async {
                                if (_passwordLength < 32) {
                                  setState(() {
                                    _passwordLength++;
                                  });
                                  await initDatabase();
                                  await setSetting('password_length', _passwordLength.toString());
                                }
                              },
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: language.increase,
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_passwordLength',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Include Letters
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.includeLetters,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            language.includeLettersDesc,
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _useLetters,
                          onChanged: (bool? value) async {
                            setState(() {
                              _useLetters = value ?? true;
                            });
                            await initDatabase();
                            await setSetting('password_letters', _useLetters.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                  // Include Numbers
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.includeNumbers,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            language.includeNumbersDesc,
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _useNumbers,
                          onChanged: (bool? value) async {
                            setState(() {
                              _useNumbers = value ?? true;
                            });
                            await initDatabase();
                            await setSetting('password_numbers', _useNumbers.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                  // Include Special Characters
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.specialCharacters,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            language.includeSpecialCharacters,
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _useSpecialChar,
                          onChanged: (bool? value) async {
                            setState(() {
                              _useSpecialChar = value ?? true;
                            });
                            await initDatabase();
                            await setSetting('password_special_char', _useSpecialChar.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                  // Include Uppercase
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.includeUppercase,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            language.includeUppercaseDesc,
                            style: const TextStyle(fontSize: 12),
                          ),
                          value: _useUppercase,
                          onChanged: (bool? value) async {
                            setState(() {
                              _useUppercase = value ?? true;
                            });
                            await initDatabase();
                            await setSetting('password_uppercase', _useUppercase.toString());
                          },
                        ),
                      ),
                    ],
                  ),
                  // Save Button
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _saveSettings,
                            icon: const Icon(Icons.save, size: 18),
                            label: Text(
                              language.savePasswordSettings,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Current Password
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.currentPassword,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            key: ValueKey('old_password_$_isOldPasswordVisible'),
                            controller: _oldPasswordController,
                            obscureText: !_isOldPasswordVisible,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: language.currentPasswordField,
                                  labelStyle: const TextStyle(fontSize: 12),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isOldPasswordVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isOldPasswordVisible = !_isOldPasswordVisible;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // New Password
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.newPassword,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            key: ValueKey('new_password_$_isNewPasswordVisible'),
                            controller: _newPasswordController,
                            obscureText: !_isNewPasswordVisible,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: language.newPasswordField,
                              labelStyle: const TextStyle(fontSize: 12),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isNewPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isNewPasswordVisible = !_isNewPasswordVisible;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Confirm Password
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.confirmPasswordField,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            key: ValueKey('confirm_password_$_isConfirmPasswordVisible'),
                            controller: _confirmPasswordController,
                            obscureText: !_isConfirmPasswordVisible,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: language.confirmNewPassword,
                              labelStyle: const TextStyle(fontSize: 12),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.primary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: colorScheme.primary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isConfirmPasswordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                                  });
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Change Master Password Button
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 16, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _isChangingPassword ? null : _changeMasterPassword,
                            icon: _isChangingPassword
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.lock_reset, size: 18),
                            label: Text(
                              _isChangingPassword ? language.changing : language.changeMasterPassword,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Master Phrase
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            language.masterPhrase,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 400),
                          child: TextField(
                            controller: _masterPhraseController,
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              labelText: language.masterPhraseField,
                              labelStyle: const TextStyle(fontSize: 12),
                              hintText: language.masterPhraseHint,
                              hintStyle: const TextStyle(fontSize: 12),
                              filled: true,
                              fillColor: colorScheme.surface,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: colorScheme.secondary,
                                  width: 2,
                                ),
                              ),
                              prefixIcon: Icon(
                                Icons.lightbulb_outline,
                                color: colorScheme.secondary,
                                size: 20,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Save Master Phrase Button
                  TableRow(
                    children: [
                      const SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton.icon(
                            onPressed: _saveMasterPhrase,
                            icon: const Icon(Icons.save, size: 18),
                            label: Text(
                              language.saveMasterPhrase,
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.secondaryContainer,
                              foregroundColor: colorScheme.onSecondaryContainer,
                              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Encryption Key
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                language.encryptionKey,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                language.encryptionKeyWarning,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: colorScheme.error.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 400),
                              child: TextField(
                                key: ValueKey('crypto_string_$_isCryptoStringVisible'),
                                controller: _cryptoStringController,
                                obscureText: !_isCryptoStringVisible,
                                style: const TextStyle(fontSize: 12),
                                decoration: InputDecoration(
                                  labelText: language.encryptionKeyField,
                                  labelStyle: const TextStyle(fontSize: 12),
                                  hintText: language.encryptionKeyHint,
                                  hintStyle: const TextStyle(fontSize: 12),
                                  filled: true,
                                  fillColor: colorScheme.surface,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(
                                      color: colorScheme.tertiary,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.vpn_key,
                                    color: colorScheme.tertiary,
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isCryptoStringVisible
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isCryptoStringVisible = !_isCryptoStringVisible;
                                      });
                                    },
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: ElevatedButton.icon(
                                onPressed: _isChangingCryptoString ? null : _changeCryptoString,
                                icon: _isChangingCryptoString
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : const Icon(Icons.vpn_key, size: 18),
                                label: Text(
                                  _isChangingCryptoString ? language.reEncrypting : language.changeEncryptionKey,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.tertiaryContainer,
                                  foregroundColor: colorScheme.onTertiaryContainer,
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Database Actions
                  TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 20, top: 8, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            'Database',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _isExporting ? null : () async {
                                // Show immediate feedback
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Opening file picker...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                
                                setState(() {
                                  _isExporting = true;
                                });
                                
                                try {
                                  print('Opening file picker...');
                                  
                                  // Ensure window is focused and brought to front
                                  await windowManager.show();
                                  await windowManager.focus();
                                  
                                  // Small delay to ensure window is active
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  
                                  // Show file picker dialog to choose save location
                                  // On macOS, the dialog might need to be modal
                                  String? outputPath = await FilePicker.platform.saveFile(
                                    dialogTitle: language.exportDatabase,
                                    fileName: 'dataExport.db',
                                    type: FileType.any,
                                  );

                                  print('File picker returned: $outputPath');

                                  if (outputPath != null && outputPath.isNotEmpty) {
                                    print('Exporting database to: $outputPath');
                                    await exportDatabase(exportPath: outputPath);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('${language.databaseExportedTo}: $outputPath'),
                                          backgroundColor: Colors.green,
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    }
                                  } else {
                                    print('File picker was cancelled or returned null');
                                    // File picker might not be working - show info message
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(language.filePickerPermissionError),
                                          backgroundColor: Colors.orange,
                                          duration: const Duration(seconds: 4),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e, stackTrace) {
                                  print('FilePicker error: $e');
                                  print('Stack trace: $stackTrace');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isExporting = false;
                                    });
                                  }
                                }
                              },
                              icon: _isExporting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.download, size: 18),
                              label: Text(
                                _isExporting ? language.exporting : language.exportDatabase,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.primary,
                                side: BorderSide(color: colorScheme.primary.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: _isImporting ? null : () async {
                                // Show immediate feedback
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Opening file picker...'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                                
                                setState(() {
                                  _isImporting = true;
                                });
                                
                                try {
                                  print('Opening file picker for import...');
                                  
                                  // Ensure window is focused and brought to front
                                  await windowManager.show();
                                  await windowManager.focus();
                                  
                                  // Small delay to ensure window is active
                                  await Future.delayed(const Duration(milliseconds: 300));
                                  
                                  // Show file picker dialog to choose database file
                                  FilePickerResult? result = await FilePicker.platform.pickFiles(
                                    dialogTitle: language.importDatabase,
                                    type: FileType.custom,
                                    allowedExtensions: ['db'],
                                  );

                                  print('File picker returned: ${result?.files.single.path}');

                                  if (result != null && result.files.single.path != null) {
                                    final importPath = result.files.single.path!;
                                    print('Importing database from: $importPath');
                                    
                                    // Confirm import with user
                                    final confirmed = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(language.importDatabaseQuestion),
                                          content: Text(language.importDatabaseWarning),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: Text(language.cancel),
                                            ),
                                            ElevatedButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Theme.of(context).colorScheme.primary,
                                                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                                              ),
                                              child: Text(language.importDatabase),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                    
                                    if (confirmed == true) {
                                      await importDatabase(importPath);
                                      if (mounted) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(language.databaseImportedSuccessfully),
                                            backgroundColor: Colors.green,
                                            duration: const Duration(seconds: 2),
                                          ),
                                        );
                                        // Navigate to master password page since imported DB might have different master password
                                        Navigator.of(context).pushAndRemoveUntil(
                                          MaterialPageRoute(
                                            builder: (context) => const MasterPasswordPage(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    }
                                  } else {
                                    print('File picker was cancelled or returned null');
                                  }
                                } catch (e, stackTrace) {
                                  print('Import error: $e');
                                  print('Stack trace: $stackTrace');
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${language.errorImportingDatabase}: ${e.toString()}'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() {
                                      _isImporting = false;
                                    });
                                  }
                                }
                              },
                              icon: _isImporting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.upload, size: 18),
                              label: Text(
                                _isImporting ? language.importing : language.importDatabase,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.secondary,
                                side: BorderSide(color: colorScheme.secondary.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () async {
                                // Show confirmation dialog
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(language.deleteDatabaseQuestion),
                                      content: Text(language.deleteDatabaseWarning),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(false),
                                          child: Text(language.cancel),
                                        ),
                                        ElevatedButton(
                                          onPressed: () => Navigator.of(context).pop(true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Theme.of(context).colorScheme.error,
                                            foregroundColor: Theme.of(context).colorScheme.onError,
                                          ),
                                          child: Text(language.delete),
                                        ),
                                      ],
                                    );
                                  },
                                );

                                if (confirmed == true) {
                                  await deleteDB();
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(language.databaseDeleted),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                    // Navigate to welcome page and clear navigation stack
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) => const WelcomePage(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                }
                              },
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: Text(
                                language.deleteDatabase,
                                style: const TextStyle(fontSize: 12),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: colorScheme.error,
                                side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
