import 'dart:io';
import 'package:flutter/material.dart';
import 'package:devtool/utils/constant.dart';
import 'package:devtool/utils/db.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:devtool/store/AppStore.dart';
import 'package:devtool/pages/home.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';

import 'locale/AppLocalizations.dart';
import 'locale/Languages.dart';

BaseLanguage? language;

AppStore appStore = AppStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initDBConnection();

  const AppLocalizations().initLocale();

  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setSize(const Size(1300, 700));
    WindowManager.instance.setMinimumSize(const Size(1200, 700));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(title: language!.settings),
    );
  }
}
