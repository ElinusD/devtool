import 'dart:io';
import 'dart:convert';
import 'package:devtool/main.dart';
import 'package:encrypt/encrypt.dart' as cryptoMaker;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:random_password_generator/random_password_generator.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'db.dart';

// Initialize crypto string cache
Future<void> initCryptoString() async {
  await _refreshCryptoString();
}

final password = RandomPasswordGenerator();

const String iv = 'your_secret_iv44'; //16

// Cached crypto string for synchronous operations
String? _cachedCryptoString;

Future<String> _getCryptoString() async {
  if (_cachedCryptoString != null && _cachedCryptoString!.isNotEmpty) {
    return _cachedCryptoString!;
  }
  await initDatabase();
  _cachedCryptoString = await getSetting('crypto_string');
  if (_cachedCryptoString == null || _cachedCryptoString!.isEmpty) {
    throw StateError(
      'Crypto string not set. Set it in Settings or when creating a new database.',
    );
  }
  return _cachedCryptoString!;
}

Future<void> _refreshCryptoString() async {
  await initDatabase();
  _cachedCryptoString = await getSetting('crypto_string');
}

// Public function to refresh crypto string cache
Future<void> refreshCryptoStringCache() async {
  await _refreshCryptoString();
}

String _getCryptoKey(String cryptoString) {
  String str = cryptoString.padRight(15, cryptoString);
  return str.substring(0, 32);
}

Future<String> decryptText(String encryptedText) async {
  if (encryptedText == '') {
    return '';
  }
  final cryptoString = await _getCryptoString();
  final cryptoKey = _getCryptoKey(cryptoString);
  
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(cryptoKey),
        mode: cryptoMaker.AESMode.cbc),
  );

  final decrypted = encrypter.decrypt(
      cryptoMaker.Encrypted.fromBase64(encryptedText),
      iv: cryptoMaker.IV.fromUtf8(iv));
  return decrypted;
}

Future<String> encryptText(String text) async {
  if (text == '') {
    return '';
  }
  final cryptoString = await _getCryptoString();
  final cryptoKey = _getCryptoKey(cryptoString);
  
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(cryptoKey),
        mode: cryptoMaker.AESMode.cbc),
  );

  final encrypted = encrypter.encrypt(text, iv: cryptoMaker.IV.fromUtf8(iv));
  return encrypted.base64;
}

// Synchronous versions for backward compatibility
String decryptTextSync(String encryptedText, {String? cryptoString}) {
  if (encryptedText == '') {
    return '';
  }
  final cs = cryptoString ?? _cachedCryptoString;
  if (cs == null || cs.isEmpty) {
    throw StateError('Crypto string not set.');
  }
  final cryptoKey = _getCryptoKey(cs);
  
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(cryptoKey),
        mode: cryptoMaker.AESMode.cbc),
  );

  final decrypted = encrypter.decrypt(
      cryptoMaker.Encrypted.fromBase64(encryptedText),
      iv: cryptoMaker.IV.fromUtf8(iv));
  return decrypted;
}

String encryptTextSync(String text, {String? cryptoString}) {
  if (text == '') {
    return '';
  }
  final cs = cryptoString ?? _cachedCryptoString;
  if (cs == null || cs.isEmpty) {
    throw StateError('Crypto string not set.');
  }
  final cryptoKey = _getCryptoKey(cs);
  
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
        title: Text(language.error),
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

Future<String> generateNewPassword() async {
  await initDatabase();
  
  final length = int.tryParse(await getSetting('password_length') ?? '12') ?? 12;
  final useLetters = (await getSetting('password_letters') ?? 'true') == 'true';
  final useNumbers = (await getSetting('password_numbers') ?? 'true') == 'true';
  final useSpecialChar = (await getSetting('password_special_char') ?? 'true') == 'true';
  final useUppercase = (await getSetting('password_uppercase') ?? 'true') == 'true';
  
  return password.randomPassword(
      letters: useLetters,
      numbers: useNumbers,
      passwordLength: length.toDouble(),
      specialChar: useSpecialChar,
      uppercase: useUppercase);
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
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();

  void _showPopup() {
    final RenderBox? renderBox = _buttonKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final Offset offset = renderBox.localToGlobal(Offset.zero);
    final Size size = renderBox.size;

    // Calculate popup size to center it above the button
    const double popupWidth = 60.0;
    const double popupHeight = 28.0;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx + (size.width / 2) - (popupWidth / 2),
        top: offset.dy - popupHeight - 5,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: popupWidth,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'COPIED',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await Clipboard.setData(ClipboardData(
            text: widget.textController.text)
        );
        _showPopup();
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
        child: Padding(
          key: _buttonKey,
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.copy,
            size: 24,
            color: _isHovered ? Colors.black : Colors.grey,
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.open_in_browser,
            size: 24,
            color: _isHovered ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }
}
