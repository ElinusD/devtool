import 'dart:io';
import 'dart:convert';
import 'package:devtool/main.dart';
import 'package:encrypt/encrypt.dart' as cryptoMaker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:url_launcher/url_launcher_string.dart';

final password = RandomPasswordGenerator();

const cryptoString = "78915030";
const String iv    = 'your_secret_iv44'; //16
String str         = cryptoString.padRight(15, cryptoString);
final cryptoKey    = str.substring(0, 32);


String decryptText(String encryptedText) {
  if (encryptedText == '') {
    return '';
  }
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(cryptoKey),
        mode: cryptoMaker.AESMode.cbc),
  );

  final decrypted = encrypter.decrypt(
      cryptoMaker.Encrypted.fromBase64(encryptedText),
      iv: cryptoMaker.IV.fromUtf8(iv));
  return decrypted;
}

String encryptText(String text) {
  if (text == '') {
    return '';
  }
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(cryptoKey),
        mode: cryptoMaker.AESMode.cbc),
  );

  final encrypted = encrypter.encrypt(text, iv: cryptoMaker.IV.fromUtf8(iv));
  return encrypted.base64;
}

Map<String, dynamic> parseJson(String jsonContent) {
  try {
    return json.decode(jsonContent);
  } catch (e) {
    print('Error parsing JSON: $e');
    return {};
  }
}

String mapToJsonString(Map<String, TextEditingController> map) {
  Map<String, String> jsonMap = {};

  map.forEach((key, controller) {
    jsonMap[key] = controller.text;
  });

  return jsonEncode(jsonMap);
}

Future<void> errorMessage(BuildContext context, String message) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(language!.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

//password
(String, Color) passwordStrength(String passwordValue) {
  double passwordstrength = password.checkPassword(password: passwordValue);;
  String passStrength;
  Color color = Colors.white;

  if (passwordstrength < 0.3) {
    color = Colors.red;
    passStrength = ' Weak';
  } else if (passwordstrength < 0.6) {
    color = Colors.yellow;
    passStrength = ' Medium';
  } else if (passwordstrength < 0.9) {
    color = Colors.orange;
    passStrength = ' Good';
  } else {
    color = Colors.green;
    passStrength = ' Strong';
  }

  return (passStrength, color);
}

String generateNewPassword() {
  return password.randomPassword(
      letters: true,
      numbers: true,
      passwordLength: 12,
      specialChar: true,
      uppercase: true);
}

//password end

UnderlineInputBorder focusedUnderLineInputBorder() {
  return const UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.blueAccent,
      // Color when the TextField is focused
      width: 0.9, // Width of the bottom border
    ),
  );
}

UnderlineInputBorder enabledUnderLineInputBorder() {
  return const UnderlineInputBorder(
    borderSide: BorderSide(
      color: Colors.blueAccent,
      // Color when the TextField is focused
      width: 0.4, // Width of the bottom border
    ),
  );
}

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

//////
class HoverableCopyIconButton extends StatefulWidget {
  final TextEditingController textController;

  // Constructor
  const HoverableCopyIconButton({super.key, required this.textController});

  @override
  _HoverableCopyIconButtonState createState() => _HoverableCopyIconButtonState();
}

class _HoverableCopyIconButtonState extends State<HoverableCopyIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(
            text: widget.textController.text)
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // Set cursor to pointer on hover
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Icon(
          Icons.copy,
          size: 15,
          color: _isHovered ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}

//url open icon
Future<void> _launchURL(String url) async {
  url = 'http://${url.replaceAll('http://', '').trim()}';
  if (url != '' && await canLaunchUrlString(url)) {
    await launchUrlString(url);
  }
}

class HoverableUrlOpenIconButton extends StatefulWidget {
  final TextEditingController textController;

  // Constructor
  const HoverableUrlOpenIconButton({super.key, required this.textController});

  @override
  _HoverableUrlOpenIconButtonState createState() => _HoverableUrlOpenIconButtonState();
}

class _HoverableUrlOpenIconButtonState extends State<HoverableUrlOpenIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _launchURL(widget.textController.text);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click, // Set cursor to pointer on hover
        onEnter: (_) {
          setState(() {
            _isHovered = true;
          });
        },
        onExit: (_) {
          setState(() {
            _isHovered = false;
          });
        },
        child: Icon(
          Icons.open_in_browser,
          size: 15,
          color: _isHovered ? Colors.black : Colors.grey,
        ),
      ),
    );
  }
}
