import 'dart:async';

import 'package:devtool/main.dart';
import 'package:flutter/material.dart';
import 'package:devtool/utils/db.dart';
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
  bool _isHoveredCloseBtn = false;

  Widget? itemWidgetData;
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
      itemWidgetData = itemWidget(item);
      itemWidgetVisible = true;
      _loadPasswordsList(item['id']);
    });
  }

  @override
  void initState() {
    super.initState();

    _loadPasswordsList(0);
  }

  Future<void> _loadPasswordsList(int selectedId, {bool addNew = false}) async {
    await initDatabase();
    passwordsFromDB = await getPasswords();

    setState(() {
      _itemsList = generatePasswordsList(selectedId);
    });
  }

  List<Widget> generatePasswordsList(int selectedId) {
    List<Widget> listRows = [];

    for (var item in passwordsFromDB) {
      if (_searchEditController.text == '' ||
          decryptText(item['title'])
              .toLowerCase()
              .contains(_searchEditController.text.toLowerCase())) {
        listRows.add(HoverablePasswordItem(
            item: item,
            selectItemOnHomePage: _onRowTap,
            selectedOnHomePage: selectedId));
      }
    }

    return listRows;
  }

  Widget itemWidget(Map<String, dynamic> item,
      {bool showSaveButton = true, bool hidePassword = true}) {
    _titleEditController.text = decryptText(item['title']) ?? '';
    _loginEditController.text = decryptText(item['login']) ?? '';
    _passwordEditController.text = decryptText(item['password']) ?? '';
    _urlEditController.text = decryptText(item['url']) ?? '';
    _commentEditController.text = decryptText(item['comment']) ?? '';
    String changed = '';
    if (item['changed'] != null) {
      final changedValue = DateTime.fromMillisecondsSinceEpoch(item['changed']);
      changed = changedValue.toString();
      changed = changed.substring(0, 19);
    }

    return Container(
      width: 340,
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
          Row(
            children: [
              const Spacer(),
              Text(_titleEditController.text),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  setState(() {
                    itemWidgetVisible = !itemWidgetVisible;
                  });
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.click, // Set cursor to pointer on hover
                  onEnter: (_) {
                    setState(() {
                      _isHoveredCloseBtn = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _isHoveredCloseBtn = false;
                    });
                  },
                  child: Icon(
                    Icons.close,
                    size: 15,
                    color: _isHoveredCloseBtn ? Colors.black : Colors.grey,
                  ),
                ),
              )
            ],
          ),
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
                            style: const TextStyle(fontSize: 12),
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
                                        itemWidgetData = itemWidget(item);
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
                                padding: const EdgeInsets.only(right: 12),
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
                        suffixIcon:
                            Row(mainAxisSize: MainAxisSize.min, children: [
                          HoverableUrlOpenIconButton(
                              textController: _urlEditController),
                          const SizedBox(
                            width: 10,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: HoverableCopyIconButton(
                                textController: _urlEditController),
                          )
                        ])),
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
                      hintStyle: const TextStyle(color: Colors.black26),
                      contentPadding:
                          const EdgeInsets.only(top: 17, bottom: 14, left: 5),
                    ),
                    controller: _commentEditController,
                    style: const TextStyle(fontSize: 12),
                  )),
                ],
              ),
              TableRow(
                children: [
                  TableCell(
                      verticalAlignment: TableCellVerticalAlignment.middle,
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 5),
                          child: Text(
                            language!.changed,
                            style: const TextStyle(fontSize: 12, color: Colors.black38),
                          ))),
                  TableCell(
                      child: Padding(
                          padding: const EdgeInsets.only(top: 10, left: 5),
                          child: Text(changed,
                    style: const TextStyle(fontSize: 12, color: Colors.black38),
                  )),)
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
                          errorMessage(context, language!.titleIsEmpty);
                        } else {
                          await updateData(
                              item['id'],
                              _titleEditController.text,
                              _loginEditController.text,
                              _passwordEditController.text,
                              _urlEditController.text,
                              _commentEditController.text);
                          _loadPasswordsList(item['id']);
                        }
                      },
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    ElevatedButton.icon(
                      icon: Icon(Icons.delete_forever),
                      label: Text(language!.delete),
                      style: ElevatedButton.styleFrom(
                        // primary: Colors.green, // Background color
                        // onPrimary: Colors.white, // Text and icon color
                        padding: const EdgeInsets.symmetric(
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
              : const SizedBox(),
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
        SizedBox(
          width: 300.0, // Fixed width of TextField
          height: 34,
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
                    _itemsList = generatePasswordsList(0);
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
              setState(() {
                _itemsList = generatePasswordsList(0);
              });
            },
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        ElevatedButton.icon(
          icon: const Icon(
            Icons.add,
            size: 13,
          ),
          onPressed: () {
            setState(() {
              itemWidgetData = null;
              itemWidgetVisible = false;
            });
            _openModalAddItem(context);
          },
          label: Text(
            language!.add,
            style: const TextStyle(fontSize: 12),
          ),
          style: ElevatedButton.styleFrom(
            iconColor: Colors.white,
            foregroundColor: Colors.white,
            backgroundColor: Colors.green,
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
                    padding: const EdgeInsets.only(left: 14, right: 14),
                    margin: const EdgeInsets.fromLTRB(10, 0, 12, 0),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(13),
                          topRight: Radius.circular(13)),
                      color: Colors.white,
                    ),
                    child: Column(children: [
                      Row(
                        children: [
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    language!.title,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ))),
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    language!.login,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ))),
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    language!.passwordStrength,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ))),
                          Expanded(
                              child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: Text(
                                    language!.url,
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  ))),
                        ],
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
                  child: itemWidgetData ?? const SizedBox.shrink(),
                ),
                Visibility(
                  visible: !itemWidgetVisible,
                  child: Container(
                      width: 340,
                      padding: const EdgeInsets.all(16.0),
                      margin: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(13), topRight: Radius.circular(13)),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Text(language!.passwordStrengthRecommendations, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),),
                          Expanded(child: Text(language!.passwordStrengthRecommendationsText, style: const TextStyle(fontSize: 12),))
                        ],
                      ),
                  )
                ),

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
                  errorMessage(context, language!.titleIsEmpty);
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
      _loadPasswordsList(0);
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
      _loadPasswordsList(0);
    }
  }
}

class HoverablePasswordItem extends StatefulWidget {
  final Function(Map<String, dynamic>) selectItemOnHomePage;
  final Map<String, dynamic> item;
  final int selectedOnHomePage;

  // Constructor
  const HoverablePasswordItem(
      {super.key,
      required this.item,
      required this.selectItemOnHomePage,
      required this.selectedOnHomePage});

  @override
  _HoverablePasswordItemState createState() => _HoverablePasswordItemState();
}

class _HoverablePasswordItemState extends State<HoverablePasswordItem> {
  bool _isHovered = false;
  bool _isSelected = false;

  List<Widget> _generateCells(item) {
    List<String> listOfColumns = ['title', 'login', 'password', 'url'];
    List<Widget> listOfCells = [];
    Color color = Colors.white;
    String passStrength;

    for (int i = 0; i < listOfColumns.length; i++) {
      Widget cellValue;

      if (listOfColumns[i] == 'password') {
        (passStrength, color) =
            passwordStrength(decryptText(item[listOfColumns[i]]));
        cellValue = Row(
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
        );
      } else {
        var text = item[listOfColumns[i]] == '' ? '--' : decryptText(item[listOfColumns[i]]);
        if (text.length > 17) {
          text = '${text.substring(0,17)}...';
        }
        cellValue = Text(
          text,
          style: const TextStyle(fontSize: 13),
        );
      }

      listOfCells.add(
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            child: cellValue,
          ),
        ),
      );
    }

    return listOfCells;
  }

  @override
  Widget build(BuildContext context) {
    Color itemColor;
    _isSelected = widget.selectedOnHomePage == widget.item['id'];

    if (_isSelected) {
      itemColor = Colors.grey.shade200;
    } else if (_isHovered) {
      itemColor = Colors.black12;
    } else {
      itemColor = Colors.transparent;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _isHovered = false;
          _isSelected = true;
        });
        widget.selectItemOnHomePage(widget.item);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) {
          setState(() {
            if (!_isSelected) {
              _isHovered = true;
            }
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            color: itemColor,
          ),
          child: ListTile(
            mouseCursor: SystemMouseCursors.click,
            hoverColor: Colors.white,
            contentPadding: const EdgeInsets.all(0),
            selected: _isSelected,
            title: Row(
              children: _generateCells(widget.item),
            ),
          ),
        ),
      ),
    );
  }
}
