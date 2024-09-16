import 'package:devtool/main.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class SettingsPage extends StatefulWidget {
  final void Function(int) redrawMainPage;

  const SettingsPage({super.key, required this.redrawMainPage});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text(language!.language),
              const SizedBox(
                width: 10,
              ),
              LanguageListWidget(
                widgetType: WidgetType.DROPDOWN,
                onLanguageChange: (v) async {
                  await appStore.setLanguage(v.languageCode!, context: context);
                  widget.redrawMainPage(2);
                  setState(() {});
                },
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              // print('object');
            },
            child: Text(language!.cancel),
          ),
        ]));
  }
}
