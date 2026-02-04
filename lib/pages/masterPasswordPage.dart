import 'package:flutter/material.dart';
import 'package:devtool/utils/db.dart';
import 'package:devtool/main.dart';
import 'package:devtool/locale/Languages.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';

class MasterPasswordPage extends StatefulWidget {
  final bool createNewDB;
  
  const MasterPasswordPage({super.key, this.createNewDB = false});

  @override
  _MasterPasswordPageState createState() => _MasterPasswordPageState();
}

class _MasterPasswordPageState extends State<MasterPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isObscure = true;
  bool _isConfirmObscure = true;
  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;
  String? _masterPhrase;
  bool _isImporting = false;
  bool _showChoice = false; // Show choice between create password or import

  @override
  void initState() {
    super.initState();
    _checkMasterPassword();
  }

  Future<void> _checkMasterPassword() async {
    await initDatabase();
    
    // If coming from welcome page to create new DB, skip all checks
    if (widget.createNewDB) {
      setState(() {
        _isCreating = true;
        _showChoice = false;
      });
      return;
    }
    
    final hasPassword = await hasMasterPassword();
    final phrase = await getMasterPhrase();
    setState(() {
      if (!hasPassword) {
        // Check if database is empty
        _checkIfDatabaseEmpty();
      } else {
        _isCreating = false;
        _showChoice = false;
        _masterPhrase = phrase;
      }
    });
  }

  Future<void> _checkIfDatabaseEmpty() async {
    try {
      final passwords = await getPasswords();
      setState(() {
        _showChoice = passwords.isEmpty;
        _isCreating = !_showChoice; // If DB has data but no master password, go straight to create
      });
    } catch (e) {
      // If error, assume empty and show choice
      setState(() {
        _showChoice = true;
        _isCreating = false;
      });
    }
  }

  Future<void> _createMasterPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      final language = BaseLanguage.of(context);
      setState(() {
        _errorMessage = language.passwordsDoNotMatch;
      });
      return;
    }

    if (_passwordController.text.length < 4) {
      final language = BaseLanguage.of(context);
      setState(() {
        _errorMessage = language.passwordMinLength;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await initDatabase();
      await setMasterPassword(_passwordController.text);
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MainPage()),
        );
      }
    } catch (e) {
      final language = BaseLanguage.of(context);
      setState(() {
        _errorMessage = '${language.errorCreatingMasterPassword}: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyMasterPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await initDatabase();
      final isValid = await verifyMasterPassword(_passwordController.text);
      
      if (isValid) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainPage()),
          );
        }
      } else {
        final language = BaseLanguage.of(context);
        setState(() {
          _errorMessage = language.incorrectMasterPassword;
          _isLoading = false;
        });
      }
    } catch (e) {
      final language = BaseLanguage.of(context);
      setState(() {
        _errorMessage = '${language.errorVerifyingPassword}: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importDatabase() async {
    setState(() {
      _isImporting = true;
    });

    try {
      // Ensure window is focused
      await windowManager.show();
      await windowManager.focus();
      await Future.delayed(const Duration(milliseconds: 300));

      // Show file picker dialog to choose database file
      final language = BaseLanguage.of(context);
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        dialogTitle: language.importDatabase,
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result != null && result.files.single.path != null) {
        final importPath = result.files.single.path!;
        
        // Confirm import with user
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            final language = BaseLanguage.of(context);
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
            final language = BaseLanguage.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(language.databaseImportedSuccessfully),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Reload master phrase in case imported DB has different one
            final phrase = await getMasterPhrase();
            setState(() {
              _masterPhrase = phrase;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) {
        final language = BaseLanguage.of(context);
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
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final language = BaseLanguage.of(context);
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withOpacity(0.3),
              colorScheme.surface,
              colorScheme.secondaryContainer.withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Form(
                key: _formKey,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Icon with gradient background
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  colorScheme.primary,
                                  colorScheme.primary.withOpacity(0.7),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(0.3),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              _showChoice
                                  ? Icons.storage
                                  : (_isCreating ? Icons.lock_person : Icons.lock),
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // Title
                          Text(
                            _showChoice
                                ? language.welcome
                                : (_isCreating ? language.createMasterPassword : language.welcomeBack),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Subtitle
                          Text(
                            _showChoice
                                ? language.chooseHowToProceed
                                : (_isCreating
                                    ? language.secureYourData
                                    : language.enterMasterPassword),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          // Choice buttons (when no master password and empty DB)
                          if (_showChoice) ...[
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: _isImporting ? null : () async {
                                  await _importDatabase();
                                  if (mounted && !_isImporting) {
                                    // After import, check if master password was created
                                    final hasPassword = await hasMasterPassword();
                                    final phrase = await getMasterPhrase();
                                    if (hasPassword) {
                                      // Imported DB has master password, go to login
                                      setState(() {
                                        _showChoice = false;
                                        _isCreating = false;
                                        _masterPhrase = phrase;
                                      });
                                    } else {
                                      // Imported DB has no master password, create one
                                      setState(() {
                                        _showChoice = false;
                                        _isCreating = true;
                                      });
                                    }
                                  }
                                },
                                icon: _isImporting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : const Icon(Icons.upload, size: 20),
                                label: Text(
                                  _isImporting ? 'Importing...' : 'Import Database',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorScheme.secondary,
                                  foregroundColor: colorScheme.onSecondary,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _showChoice = false;
                                    _isCreating = true;
                                  });
                                },
                                icon: const Icon(Icons.lock_person, size: 20),
                                label: Text(
                                  language.createMasterPassword,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colorScheme.primary, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                          ],
                          // Master phrase hint
                          if (!_showChoice && !_isCreating && _masterPhrase != null && _masterPhrase!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: colorScheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Icons.lightbulb_outline,
                                      color: colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Hint',
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colorScheme.primary,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _masterPhrase!,
                                          style: theme.textTheme.bodySmall?.copyWith(
                                            color: colorScheme.onSurface.withOpacity(0.8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Password fields (only show when creating or logging in)
                          if (!_showChoice) ...[
                            const SizedBox(height: 32),
                            // Password field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _isObscure,
                              enabled: !_isLoading,
                              autofocus: true,
                              textInputAction: _isCreating ? TextInputAction.next : TextInputAction.done,
                              onFieldSubmitted: (value) {
                                if (!_isCreating && !_isLoading) {
                                  _verifyMasterPassword();
                                }
                              },
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: language.passwordField,
                                hintText: language.enterPassword,
                                filled: true,
                                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: colorScheme.outline.withOpacity(0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: colorScheme.error,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: colorScheme.primary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _isObscure = !_isObscure;
                                    });
                                  },
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 18,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return language.pleaseEnterPassword;
                                }
                                if (_isCreating && value.length < 4) {
                                  return language.passwordMinLength;
                                }
                                return null;
                              },
                            ),
                            // Confirm password field
                            if (_isCreating) ...[
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: _confirmPasswordController,
                                obscureText: _isConfirmObscure,
                                enabled: !_isLoading,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (value) {
                                  if (!_isLoading) {
                                    _createMasterPassword();
                                  }
                                },
                                style: theme.textTheme.bodyLarge,
                                decoration: InputDecoration(
                                  labelText: language.confirmPasswordField,
                                  hintText: language.confirmPasswordHint,
                                  filled: true,
                                  fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.primary,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide(
                                      color: colorScheme.error,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isConfirmObscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isConfirmObscure = !_isConfirmObscure;
                                      });
                                    },
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 18,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return language.pleaseConfirmPassword;
                                  }
                                  if (value != _passwordController.text) {
                                    return language.passwordsDoNotMatch;
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ],
                          // Error message
                          if (!_showChoice && _errorMessage != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colorScheme.errorContainer.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: colorScheme.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline_rounded,
                                    color: colorScheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          // Import button (only show when not creating and not importing)
                          if (!_showChoice && !_isCreating && _isImporting) ...[
                            const SizedBox(height: 20),
                            const Center(
                              child: CircularProgressIndicator(),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              language.importingDatabase,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Import DB option (show when creating new master password, but not when creating new DB from welcome page)
                          if (_isCreating && !_showChoice && !widget.createNewDB) ...[
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: OutlinedButton.icon(
                                onPressed: _isImporting ? null : () async {
                                  await _importDatabase();
                                  if (mounted) {
                                    // After import, check if master password was created
                                    final hasPassword = await hasMasterPassword();
                                    final phrase = await getMasterPhrase();
                                    if (hasPassword) {
                                      // Imported DB has master password, go to login
                                      setState(() {
                                        _showChoice = false;
                                        _isCreating = false;
                                        _masterPhrase = phrase;
                                      });
                                    } else {
                                      // Imported DB has no master password, stay in create mode
                                      // User can still create password or import another DB
                                    }
                                  }
                                },
                                icon: _isImporting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.upload, size: 20),
                                label: Text(
                                  _isImporting ? 'Importing...' : 'Import Database Instead',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: colorScheme.secondary, width: 2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          // Submit button (only show when not showing choice)
                          if (!_showChoice)
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: (_isLoading || _isImporting)
                                    ? null
                                    : (_isCreating ? _createMasterPassword : _verifyMasterPassword),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                elevation: 2,
                                shadowColor: colorScheme.primary.withOpacity(0.3),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ).copyWith(
                                elevation: MaterialStateProperty.resolveWith<double>(
                                  (Set<MaterialState> states) {
                                    if (states.contains(MaterialState.pressed)) {
                                      return 0;
                                    }
                                    return 2;
                                  },
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          colorScheme.onPrimary,
                                        ),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          _isCreating ? language.createPassword : language.unlock,
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          _isCreating ? Icons.arrow_forward : Icons.lock_open,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
