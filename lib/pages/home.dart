import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devtool/utils/db.dart';
import 'package:flutter/services.dart';
import '../utils/common.dart';
import './includes/header.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool helpIsHovered = false;
  bool aboutIsHovered = false;
  bool itemWidgetVisible = false;
  bool _isObscure = true;

  Widget? itemWidgetData;
  int? _selectedRowIndex;
  List<ListTile> _itemsList = [];
  final TextEditingController _titleEditController = TextEditingController();
  final TextEditingController _loginEditController = TextEditingController();
  final TextEditingController _passwordEditController = TextEditingController();
  final TextEditingController _urlEditController = TextEditingController();
  final TextEditingController _commentEditController = TextEditingController();

  List<Map<String, dynamic>> passwordsFromDB = [];

  void _onRowTap(Map<String, dynamic> item) {
    setState(() {
      _isObscure = true;
      _selectedRowIndex = item['id'];
      itemWidgetData = itemWidget(item);
      itemWidgetVisible = true;
      _loadPasswordsList();
    });
  }

  @override
  void initState() {
    super.initState();

    _loadPasswordsList();
  }

  Future<void> _loadPasswordsList({bool addNew = false}) async {
    await initDatabase();
    passwordsFromDB = await getPasswords();

    setState(() {
      //_selectedRowIndex = passwordsFromDB[0]['id'];
      _itemsList = generatePasswordsList();
    });
  }



  List<Widget> _generateCells(item) {
    List<String> listOfColumns = ['title', 'login', 'password', 'url'];
    List<Widget> listOfCells = [];
    Color color = Colors.white;
    String passStrength;

    for (int i = 0; i < listOfColumns.length; i++) {
      if (listOfColumns[i] == 'password') {
        (passStrength, color) = passwordStrength(item[listOfColumns[i]]);

        listOfCells.add(
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: color,
                    ),
                    Text(passStrength),
                  ],
                ),
              ),
            ),
          ),
        );
      } else {
        listOfCells.add(
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(item[listOfColumns[i]]),
            ),
          ),
        );
      }
    }

    return listOfCells;
  }

  List<ListTile> generatePasswordsList() {
    List<ListTile> listRows = [];

    for (var item in passwordsFromDB) {
      listRows.add(
        ListTile(
          mouseCursor: SystemMouseCursors.click,
          // tileColor: Color.fromRGBO(47, 38, 79, 1),
          //pages[appPageName]?['active'] ? Colors.grey : null,
          // visualDensity: const VisualDensity(vertical: -4),
          // to compact
          // dense: true,
          // leading: SizedBox(
          //   // width: 30, // Constrain the width of the leading widget
          //   child: Icon(
          //     Icons.security,
          //     color: Colors.black87,
          //     size: 18,
          //   ),
          // ),
          onTap: () {
            _onRowTap(item);
          },
          title: Row(
            children: _generateCells(item),
          ),
        ),
      );
    }

    return listRows;
  }

  Widget itemWidget(Map<String, dynamic> item,
      {bool showSaveButton = true, bool hidePassword = true}) {
    _titleEditController.text = item['title'] ?? '';
    _loginEditController.text = item['login'] ?? '';
    _passwordEditController.text = item['password'] ?? '';
    _urlEditController.text = item['url'] ?? '';
    _commentEditController.text = item['comment'] ?? '';

    return Container(
      width: 390,
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(13), topRight: Radius.circular(13)),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Table(
            columnWidths: const {
              0: FixedColumnWidth(90),
            },
            children: [
              TableRow(
                children: [
                  const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Title',
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: _titleEditController,
                            style: TextStyle(fontSize: 12),
                          ))),
                ],
              ),
              TableRow(
                children: [
                  const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'Login',
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Login',
                              contentPadding: const EdgeInsets.only(top: 10),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 17,
                                    ),
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text:
                                              _loginEditController.text ?? ''));
                                    },
                                  ),
                                ],
                              ),
                            ),
                            controller: _loginEditController,
                            style: TextStyle(fontSize: 12),
                          ))),
                ],
              ),
              TableRow(
                children: [
                  const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'password',
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(5),
                    child: TextFormField(
                      // style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      controller: _passwordEditController,
                      obscureText: hidePassword ? _isObscure : false,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        contentPadding: EdgeInsets.only(top: 10),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            hidePassword
                                ? IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 17,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isObscure = !_isObscure;
                                        // _selectedRowIndex = item['id'];

                                        itemWidgetData = itemWidget(item);
                                        // itemWidgetVisible = true;
                                      });
                                    },
                                  )
                                : const SizedBox(),
                            IconButton(
                              icon: const Icon(
                                Icons.autorenew,
                                size: 17,
                              ),
                              onPressed: () {
                                _passwordEditController.text = generateNewPassword();
                              },
                            ),
                            hidePassword
                                ? IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 17,
                                    ),
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text: _passwordEditController.text ??
                                              ''));
                                    },
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ),
                  )),
                ],
              ),
              TableRow(
                children: [
                  const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            'url',
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'URL',
                              contentPadding: const EdgeInsets.only(top: 10),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy,
                                      size: 17,
                                    ),
                                    onPressed: () async {
                                      await Clipboard.setData(ClipboardData(
                                          text: _urlEditController.text ?? ''));
                                    },
                                  ),
                                ],
                              ),
                            ),
                            controller: _urlEditController,
                            style: TextStyle(fontSize: 12),
                          ))),
                ],
              ),
              TableRow(
                children: [
                  const TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5), child: Text('comment'))),
                  TableCell(
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: TextField(
                            controller: _commentEditController,
                            style: TextStyle(fontSize: 12),
                          ))),
                ],
              ),
            ],
          ),
          showSaveButton
              ? Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await updateData(
                            item['id'],
                            _titleEditController.text,
                            _loginEditController.text,
                            _passwordEditController.text,
                            _urlEditController.text,
                            _commentEditController.text);
                        _loadPasswordsList();
                      },
                      child: const Text('SAVE'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        _confirmDeleteRecord(context, item['id']);
                      },
                      child: const Text('DELETE'),
                    )
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> _openModalAddItem(BuildContext context) async {
    _titleEditController.text = '';
    _loginEditController.text = '';
    _passwordEditController.text = '';
    _urlEditController.text = '';
    _commentEditController.text = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter new record data'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            itemWidget({
              'id': 0,
              'title': '',
              'login': '',
              'password': '',
              'url': '',
              'comment': ''
            }, showSaveButton: false, hidePassword: false),
          ]),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                insertData(
                    _titleEditController.text,
                    _loginEditController.text,
                    _passwordEditController.text,
                    _urlEditController.text,
                    _commentEditController.text);
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );

    setState(() {
      _loadPasswordsList();
    });
  }

  Future<void> _confirmDeleteRecord(BuildContext context, int itemId) async {
    final bool? isConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Action'),
          content: Text('Are you sure you want to delete?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User pressed "Cancel"
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed "Confirm"
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (isConfirmed != null && isConfirmed) {
      // User pressed "Confirm", proceed with the action
      await deleteData(itemId);
      itemWidgetVisible = false;
      _loadPasswordsList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(240, 240, 240, 1),
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 12,
            ),
            getHeader(), // header
            const SizedBox(
              height: 12,
            ),
            Expanded(
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                  width: 200,
                  child: Column(children: [
                    Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(13),
                          color: Colors.white,
                        ),
                        child: const Column(
                          children: [
                            ListTile(
                              mouseCursor: SystemMouseCursors.click,
                              // tileColor: Color.fromRGBO(47, 38, 79, 1),
                              //pages[appPageName]?['active'] ? Colors.grey : null,
                              // visualDensity: const VisualDensity(vertical: -4),
                              // to compact
                              // dense: true,
                              leading: SizedBox(
                                // width: 30, // Constrain the width of the leading widget
                                child: Icon(
                                  Icons.security,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                'Passwords',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 12),
                              ),
                            ),
                            ListTile(
                              mouseCursor: SystemMouseCursors.click,
                              // tileColor: Color.fromRGBO(47, 38, 79, 1),
                              leading: SizedBox(
                                // width: 30, // Constrain the width of the leading widget
                                child: Icon(
                                  Icons.security,
                                  color: Colors.black87,
                                  size: 18,
                                ),
                              ),
                              title: Text(
                                'Passwords',
                                style: TextStyle(
                                    color: Colors.black87, fontSize: 12),
                              ),
                            ),
                          ],
                        )),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      child: const ListTile(
                        mouseCursor: SystemMouseCursors.click,
                        leading: SizedBox(
                          child: Icon(
                            Icons.security,
                            color: Colors.black87,
                            size: 18,
                          ),
                        ),
                        title: Text(
                          'Settings',
                          style: TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                        // onTap: () {
                        //   setState(() {});
                        // },
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          itemWidgetData = null;
                          itemWidgetVisible = false;
                        });
                        _openModalAddItem(context);
                      },
                      child: const Text('Insert Data'),
                    ),
                  ]),
                ),
                Expanded(
                  child: Container(
                    // alignment: AlignmentGeometry.,
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13)),
                      color: Colors.white,
                    ),
                    child: Column(children: [
                      ListTile(
                        title: Row(
                          children: [
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Title'))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Login'))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Password Strength'))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('URL'))),
                          ],
                        ),
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: _itemsList,
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
                Visibility(
                  visible: itemWidgetVisible,
                  child: itemWidgetData ?? SizedBox.shrink(),
                )
              ]),
            ),
            Container(
              height: 30.0,
              // Set your desired fixed height
              color: const Color.fromRGBO(7, 38, 79, 25),
              padding: const EdgeInsets.only(bottom: 5),
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        setState(() {
                          helpIsHovered = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          helpIsHovered = false;
                        });
                      },
                      child: Text(
                        'Help',
                        style: TextStyle(
                          color: helpIsHovered ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      onEnter: (event) {
                        setState(() {
                          aboutIsHovered = true;
                        });
                      },
                      onExit: (event) {
                        setState(() {
                          aboutIsHovered = false;
                        });
                      },
                      child: Text(
                        'About',
                        style: TextStyle(
                          color: aboutIsHovered ? Colors.white : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
