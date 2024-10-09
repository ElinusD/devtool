import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';

class Footer extends StatefulWidget {
  const Footer({super.key});

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  bool _isHelpHovered = false;
  bool _isAboutHovered = false;

  void _showAlertDialog(BuildContext context, String title, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(children: [
            Spacer(),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),),
            Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: const MouseRegion(
                cursor: SystemMouseCursors.click, // Set cursor to pointer on hover
                // onEnter: (_) {
                //   setState(() {
                //     _isHoveredCloseBtn = true;
                //   });
                // },
                // onExit: (_) {
                //   setState(() {
                //     _isHoveredCloseBtn = false;
                //   });
                // },
                child: Icon(
                  Icons.close,
                  size: 15,
                  // color: _isHoveredCloseBtn ? Colors.black : Colors.grey,
                ),
              ),
            )
          ]),
          content: Container(
            width: 450,
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 30.0,
            color: const Color.fromRGBO(7, 38, 79, 25),
            padding: const EdgeInsets.only(bottom: 5),
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        _showAlertDialog(
                            context, language!.help, language!.helpText);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (event) {
                          setState(() {
                            _isHelpHovered = true;
                          });
                        },
                        onExit: (event) {
                          setState(() {
                            _isHelpHovered = false;
                          });
                        },
                        child: Text(
                          language!.help,
                          style: TextStyle(
                            color: _isHelpHovered ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    )),
                Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: GestureDetector(
                      onTap: () {
                        _showAlertDialog(
                            context, language!.about, language!.aboutText);
                      },
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        onEnter: (event) {
                          setState(() {
                            _isAboutHovered = true;
                          });
                        },
                        onExit: (event) {
                          setState(() {
                            _isAboutHovered = false;
                          });
                        },
                        child: Text(
                          language!.about,
                          style: TextStyle(
                            color: _isAboutHovered ? Colors.white : Colors.grey,
                          ),
                        ),
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
