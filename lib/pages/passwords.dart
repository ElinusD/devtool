import 'dart:async';

import 'package:devtool/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:devtool/utils/db.dart';
import 'package:flutter/services.dart';
import '../utils/common.dart';

class PasswordsPage extends StatefulWidget {
  const PasswordsPage({super.key});

  @override
  State<PasswordsPage> createState() => _PasswordsPageState();
}

class _PasswordsPageState extends State<PasswordsPage> {
  bool helpIsHovered = false;
  bool aboutIsHovered = false;
  bool itemWidgetVisible = false;
  bool _isObscure = true;

  Widget? itemWidgetData;
  int? _selectedRowIndex;
  List<Widget> _itemsList = [];
  final TextEditingController _searchEditController = TextEditingController();
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Icon(
                      Icons.shield,
                      color: color,
                    ),
                    Text(
                      passStrength,
                      style: const TextStyle(fontSize: 13),
                    ),
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
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                item[listOfColumns[i]] == '' ? '--' : item[listOfColumns[i]],
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        );
      }
    }

    return listOfCells;
  }

  List<Widget> generatePasswordsList() {
    List<Widget> listRows = [];

    for (var item in passwordsFromDB) {
      if (_searchEditController.text == '' ||
          item['title'].contains(_searchEditController.text)) {
        listRows.add(
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7),
              color: _selectedRowIndex == item['id'] ? Colors.black12 : null,
            ),
            child: ListTile(
              mouseCursor: SystemMouseCursors.click,
              hoverColor: Colors.white,
              contentPadding: EdgeInsets.all(0),
              // focusColor: Colors.grey,
              selected: _selectedRowIndex == item['id'],
              onTap: () {
                _onRowTap(item);
              },
              title: Row(
                children: _generateCells(item),
              ),
            ),
          ),
        );
      }
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
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            language!.title,
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: enabledUnderLineInputBorder(),
                      focusedBorder: focusedUnderLineInputBorder(),
                      isDense: true,
                      hintText: language!.title,
                      hintStyle: const TextStyle(color: Colors.black26),
                      contentPadding:
                          const EdgeInsets.only(top: 17, bottom: 14, left: 5),
                    ),
                    controller: _titleEditController,
                    style: const TextStyle(fontSize: 12),
                  )),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            language!.login,
                            style: const TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: enabledUnderLineInputBorder(),
                      focusedBorder: focusedUnderLineInputBorder(),
                      isDense: true,
                      hintText: language!.login,
                      hintStyle: TextStyle(color: Colors.black26),
                      contentPadding:
                          const EdgeInsets.only(top: 15, bottom: 0, left: 5),
                      suffixIcon: HoverableCopyIconButton(
                          textController: _loginEditController),
                    ),
                    controller: _loginEditController,
                    style: const TextStyle(fontSize: 12),
                  )),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            language!.password,
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                    child: TextFormField(
                      style: const TextStyle(fontSize: 13),
                      controller: _passwordEditController,
                      obscureText: hidePassword ? _isObscure : false,
                      decoration: InputDecoration(
                        enabledBorder: enabledUnderLineInputBorder(),
                        focusedBorder: focusedUnderLineInputBorder(),
                        isDense: true,
                        hintText: language!.password,
                        hintStyle: TextStyle(color: Colors.black26),
                        contentPadding:
                            const EdgeInsets.only(top: 15, bottom: 0, left: 5),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            hidePassword
                                ? IconButton(
                                    icon: Icon(
                                      _isObscure
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      size: 15,
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
                                size: 15,
                              ),
                              onPressed: () {
                                _passwordEditController.text =
                                    generateNewPassword();
                              },
                            ),
                            Padding(
                                padding: EdgeInsets.only(right: 13),
                                child: HoverableCopyIconButton(
                                    textController: _passwordEditController))
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            language!.url,
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: TextField(
                    decoration: InputDecoration(
                        enabledBorder: enabledUnderLineInputBorder(),
                        focusedBorder: focusedUnderLineInputBorder(),
                        isDense: true,
                        hintText: language!.url,
                        hintStyle: TextStyle(color: Colors.black26),
                        contentPadding:
                            const EdgeInsets.only(top: 16, bottom: 0, left: 5),
                        suffixIcon: HoverableUrlOpenIconButton(
                            textController: _urlEditController)),
                    controller: _urlEditController,
                    style: TextStyle(fontSize: 12),
                  )),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: EdgeInsets.all(5),
                          child: Text(
                            language!.comment,
                            style: TextStyle(fontSize: 12),
                          ))),
                  TableCell(
                      child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: enabledUnderLineInputBorder(),
                      focusedBorder: focusedUnderLineInputBorder(),
                      isDense: true,
                      hintText: language!.comment,
                      hintStyle: TextStyle(color: Colors.black26),
                      contentPadding:
                          const EdgeInsets.only(top: 17, bottom: 14, left: 5),
                    ),
                    controller: _commentEditController,
                    style: TextStyle(fontSize: 12),
                  )),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          showSaveButton
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      label: Text(language!.save),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 12.0), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18.0), // Rounded corners
                        ),
                      ),
                      onPressed: () async {
                        if (_titleEditController.text == '') {
                          errorMessage(context, 'Title is empty');
                        } else {
                          await updateData(
                              item['id'],
                              _titleEditController.text,
                              _loginEditController.text,
                              _passwordEditController.text,
                              _urlEditController.text,
                              _commentEditController.text);
                          _loadPasswordsList();
                        }
                      },
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever),
                      label: Text(language!.delete),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.green, // Background color
                        // onPrimary: Colors.white, // Text and icon color
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 12.0), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(18.0), // Rounded corners
                        ),
                      ),
                      onPressed: () async {
                        _confirmDeleteRecord(context, item['id']);
                      },
                    ),
                  ],
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Row getHeader() {
    return Row(
      children: [
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              itemWidgetData = null;
              itemWidgetVisible = false;
            });
            _openModalAddItem(context);
          },
          label: Text(language!.add),
          style: ElevatedButton.styleFrom(
            iconColor: Colors.white,
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
          ),
        ),
        // Icon on the left side
        const Spacer(),
        // Spacer to push the TextField to the center
        SizedBox(
          width: 300.0, // Fixed width of TextField
          height: 30,
          child: TextField(
            controller: _searchEditController,
            textAlign: TextAlign.center,
            // Center the hint text
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              suffixIcon: IconButton(
                icon: const Icon(
                  Icons.clear,
                  size: 15,
                ),
                onPressed: () {
                  setState(() {
                    _searchEditController.text = '';
                    _itemsList = generatePasswordsList();
                  });
                },
              ),
              contentPadding: const EdgeInsets.only(top: 10),
              hintText: language!.search,
              hintStyle: const TextStyle(fontSize: 12, color: Colors.black26),
              filled: true,
              // Enable the background color
              fillColor: const Color.fromRGBO(230, 230, 230, 1),
              // Set the background color
              //contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0), // Adjust the height of the text field
              border: InputBorder.none,
              // Remove the border
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                // Border radius
                borderSide: BorderSide.none, // Remove the border
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                // Border radius
                borderSide: BorderSide.none, // Remove the border
              ),
            ),
            onChanged: (input) {
              // print(_searchEditController.text);
              setState(() {
                _itemsList = generatePasswordsList();
              });
            },
          ),
        ),
        const Spacer(),
      ],
    );
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
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    margin: const EdgeInsets.fromLTRB(10, 0, 12, 0),
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
                                    child: Text(language!.title))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(language!.login))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(language!.passwordStrength))),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(language!.url))),
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
          ],
        ),
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
              child: Text(language!.cancel),
            ),
            TextButton(
              onPressed: () {
                if (_titleEditController.text == '') {
                  errorMessage(context, 'Title is empty');
                } else {
                  insertData(
                      _titleEditController.text,
                      _loginEditController.text,
                      _passwordEditController.text,
                      _urlEditController.text,
                      _commentEditController.text);
                  Navigator.of(context).pop();
                }
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
              child: Text(language!.cancel),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User pressed "Confirm"
              },
              child: Text(language!.confirm),
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
}
