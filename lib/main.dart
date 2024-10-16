import 'dart:io';
import 'package:flutter/material.dart';
import 'package:devtool/utils/constant.dart';
import 'package:devtool/utils/db.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:devtool/store/AppStore.dart';
import 'package:devtool/pages/passwords.dart';
import 'package:devtool/pages/docsPage.dart';
import 'package:devtool/pages/settingsPage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import 'pages/includes/footer.dart';

import 'locale/AppLocalizations.dart';
import 'locale/Languages.dart';

BaseLanguage? language;

AppStore appStore = AppStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initDBConnection();

  const AppLocalizations().initLocale();

  await windowManager.ensureInitialized();

  WindowManager.instance.setSize(const Size(1300, 700));
  WindowManager.instance.setMinimumSize(const Size(1200, 700));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        UkrainianMaterialLocalizationsDelegate(),
      ],
      supportedLocales: const AppLocalizations().getSupportedLocales(),
      localeResolutionCallback: (locale, supportedLocales) => locale,
      locale: Locale(getStringAsync(SELECTED_LANGUAGE_CODE,
          defaultValue: defaultLanguage)),
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  Widget _selectedPage = const PasswordsPage();

  Widget getWidgetByIndex(int widgetIndex) {
    switch (widgetIndex) {
      case 0:
        return const PasswordsPage();
      case 1:
        return DocsPage(redrawMainPage: _onItemTapped);
      case 2:
        return SettingsPage(redrawMainPage: _onItemTapped);
      default:
        return Container();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _selectedPage = getWidgetByIndex(_selectedIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 150,
                  color: const Color.fromRGBO(7, 38, 79, 25),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            const Icon(
                              Icons.developer_board,
                              size: 110,
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.shield,
                                color: Colors.white,
                              ),
                              hoverColor: Colors.grey,
                              selectedColor: Colors.white,
                              selectedTileColor: const Color.fromRGBO(7, 38, 79, 60),
                              title: Text(language!.passwords),
                              titleTextStyle: const TextStyle(fontSize: 13),
                              textColor: Colors.grey,
                              selected: _selectedIndex == 0,
                              onTap: () => _onItemTapped(0),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.find_in_page,
                                color: Colors.white,
                              ),
                              title: Text(language!.documents),
                              titleTextStyle: const TextStyle(fontSize: 13),
                              hoverColor: Colors.grey,
                              selectedColor: Colors.white,
                              selectedTileColor: const Color.fromRGBO(7, 38, 79, 60),
                              textColor: Colors.grey,
                              selected: _selectedIndex == 1,
                              onTap: () => _onItemTapped(1),
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.settings,
                                color: Colors.white,
                              ),
                              title: Text(language!.settings),
                              titleTextStyle: const TextStyle(fontSize: 13),
                              selectedColor: Colors.white,
                              selectedTileColor: const Color.fromRGBO(7, 38, 79, 60),
                              hoverColor: Colors.grey,
                              textColor: Colors.grey,
                              selected: _selectedIndex == 2,
                              onTap: () => _onItemTapped(2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _selectedPage,
                ),
              ],
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
