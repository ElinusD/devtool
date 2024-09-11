import 'package:devtool/utils/common.dart';
import 'package:devtool/main.dart';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class DocsPage extends StatefulWidget {
  final void Function(int) redrawMainPage;

  const DocsPage({super.key, required this.redrawMainPage});

  @override
  _DocsPageState createState() => _DocsPageState();
}

class _DocsPageState extends State<DocsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(language!.documents),
        ]));
  }
}
