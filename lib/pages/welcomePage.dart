import 'package:flutter/material.dart';
import 'package:devtool/utils/db.dart';
import 'package:devtool/main.dart';
import 'package:devtool/pages/masterPasswordPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:devtool/locale/Languages.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _isLoading = true;
  bool _isDatabaseEmpty = true;
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _checkDatabase();
  }

  Future<void> _checkDatabase() async {
    try {
      await initDatabase();
      final passwords = await getPasswords();
      setState(() {
        _isDatabaseEmpty = passwords.isEmpty;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isDatabaseEmpty = true;
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
            // Navigate to master password page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const MasterPasswordPage()),
            );
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

  void _createNewDatabase() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const MasterPasswordPage(createNewDB: true)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // If database is not empty, navigate to master password page
    if (!_isLoading && !_isDatabaseEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const MasterPasswordPage()),
        );
      });
    }

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
            child: _isLoading
                ? CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Icon
                          Container(
                            width: 120,
                            height: 120,
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
                              Icons.storage,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Title
                          Text(
                            language.welcome,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Subtitle
                          Text(
                            language.chooseHowToProceed,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 64),
                          // Two square buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Create New DB square
                              _OptionSquare(
                                title: language.createNewDB,
                                icon: Icons.add_circle_outline,
                                color: colorScheme.primary,
                                onTap: _isImporting ? null : _createNewDatabase,
                              ),
                              const SizedBox(width: 32),
                              // Import DB square
                              _OptionSquare(
                                title: language.importDB,
                                icon: Icons.upload,
                                color: colorScheme.secondary,
                                onTap: _isImporting ? null : _importDatabase,
                                isLoading: _isImporting,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _OptionSquare extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final bool isLoading;

  const _OptionSquare({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        strokeWidth: 3,
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 40,
                        color: color,
                      ),
                    ),
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    textAlign: TextAlign.center,
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
