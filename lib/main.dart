import 'dart:io';
import 'package:devtool/utils/locale.dart';
import 'package:flutter/material.dart';
import 'package:devtool/utils/constant.dart';
import 'package:devtool/utils/db.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:devtool/store/AppStore.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';

import 'locale/AppLocalizations.dart';
import 'locale/Languages.dart';

BaseLanguage? language;

AppStore appStore = AppStore();

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  initDBConnection();

  initLocale();

  await windowManager.ensureInitialized();
  if (Platform.isWindows) {
    WindowManager.instance.setSize(const Size(800, 700));
    WindowManager.instance.setMinimumSize(const Size(800, 700));
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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
      supportedLocales: getSupportedLocales(),
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      //   title: Text(widget.title),
      // ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await insertData();
                setState(() {});
              },
              child: Text('Insert Data'),
            ),
            ElevatedButton(
              onPressed: () async {
                List<Map<String, dynamic>> data = await getData();
                print(data);
              },
              child: Text('Get Data'),
            ),
          ],
        ),
      ),
    );
  }
}
