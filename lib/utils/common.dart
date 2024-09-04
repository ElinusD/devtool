import 'dart:io';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as cryptoMaker;
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:random_password_generator/random_password_generator.dart';

String settingsPassFileName = 'wwrSfferfF57567VDrrfVge';
final password = RandomPasswordGenerator();

Future<String> readFileContents(String group, String fileName) async {
  try {
    String filePath = './src/data/docs/$group/$fileName';
    File file = File(filePath);
    String contents = await file.readAsString();
    return contents;
  } catch (e) {
    return 'Error loading file contents';
  }
}

Future<void> saveToFile(String group, String fileName, String content) async {
  try {
    final file = File('./src/data/docs/$group/$fileName');
    if (!file.existsSync()) {
      file.createSync();
    }
    await file.writeAsString(content);
  } catch (e) {
    print('Error saving text to file: $e');
  }
}

Future<Map<String, dynamic>> readPasswordFileContents(String fileName) async {
  Map<String, dynamic> jsonData = {};
  String filePath = '';
  try {
    if (Platform.isWindows) {
      filePath = './src/pass/$fileName';
    } else if (Platform.isMacOS) {
      Directory docDirectory = await getApplicationDocumentsDirectory();
      String docDirectoryPath = docDirectory.path;
      Directory docPasDirectory = Directory('$docDirectoryPath/pass');
      filePath = '${docPasDirectory.path}/$fileName';
    } else {
      print('Running on an unknown platform');
      exit(1);
    }

    File file = File(filePath);
    String contents = file.readAsStringSync();
    String str = "78915030";
    str = str.padRight(15, str);
    final keyString = str.substring(0, 32);
    const String iv = 'your_secret_iv44'; //16

    jsonData = parseJson(decryptText(contents, keyString, iv));

    return jsonData;
  } catch (e) {
    print('readPasswordFileContents ERROR: ${e.toString()}');
    return jsonData;
  }
}

Future<void> saveToFilePassword(String fileName, String content) async {
  try {
    Directory docPasDirectory = Directory('');
    if (Platform.isWindows) {
      docPasDirectory = Directory('./src/pass');
    } else if (Platform.isMacOS) {
      Directory docDirectory = await getApplicationDocumentsDirectory();
      String docDirectoryPath = docDirectory.path;
      docPasDirectory = Directory('$docDirectoryPath/pass');
    } else {
      print('Running on an unknown platform');
      exit(1);
    }

    // Check if the pass directory exists
    bool directoryExists = await docPasDirectory.exists();

    // If the directory doesn't exist, create it
    if (!directoryExists) {
      await docPasDirectory.create(recursive: true);
    }

    // Construct the file path
    String filePath = '${docPasDirectory.path}/$fileName';
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }

    String str = "78915030";
    str = str.padRight(15, str);
    final keyString = str.substring(0, 32);
    const String iv = 'your_secret_iv44'; //16

    await file.writeAsString(encryptText(content, keyString, iv));
  } catch (e) {
    print('Error saving text to file: $e');
  }
}

void deletePassFile(String fileName) {
  File file = File('./src/data/passwords/$fileName');

  // Check if the file exists before attempting to delete
  if (file.existsSync()) {
    try {
      file.deleteSync();
    } catch (e) {
      print('Error deleting file: $e');
    }
  } else {
    print('File does not exist.');
  }
}

Future<void> createDocsFolder(String folderName) async {
  String folderPath = './src/data/docs/$folderName';
  Directory myFolder = Directory(folderPath);

  if (await myFolder.exists()) {
  } else {
    await myFolder.create(recursive: true);
  }
}

String decryptText(String encryptedText, String key, String iv) {
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(key),
        mode: cryptoMaker.AESMode.cbc),
  );

  final decrypted = encrypter.decrypt(
      cryptoMaker.Encrypted.fromBase64(encryptedText),
      iv: cryptoMaker.IV.fromUtf8(iv));
  return decrypted;
}

String encryptText(String text, String key, String iv) {
  final encrypter = cryptoMaker.Encrypter(
    cryptoMaker.AES(cryptoMaker.Key.fromUtf8(key),
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
        title: const Text('Error'),
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

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

Future<String> dialogBuilder(
    BuildContext context, String title, String text) async {
  Completer<String> completer = Completer<String>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        // content: TextField(
        //   onChanged: (value) {
        //     // Update the value whenever the text changes.
        //     completer.complete(value);
        //   },
        // ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Complete the completer with the current text field value.
              completer.complete('Confirmed');
              Navigator.of(context).pop();
            },
            child: Text('Confirm'),
          ),
        ],
      );
    },
  );

  return completer.future;
}

Future<void> saveSettingsPassword(String content) async {
  try {
    Directory docPasDirectory = Directory('');
    if (Platform.isWindows) {
      docPasDirectory = Directory('./src/settings/pass');
    } else if (Platform.isMacOS) {
      Directory docDirectory = await getApplicationDocumentsDirectory();
      String docDirectoryPath = docDirectory.path;
      docPasDirectory = Directory('$docDirectoryPath/settings/pass');
    } else {
      print('Running on an unknown platform');
      exit(1);
    }

    // Check if the pass directory exists
    bool directoryExists = await docPasDirectory.exists();

    // If the directory doesn't exist, create it
    if (!directoryExists) {
      await docPasDirectory.create(recursive: true);
    }

    // Construct the file path
    String filePath = '${docPasDirectory.path}/$settingsPassFileName';
    final file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }

    String str = "78915030";
    str = str.padRight(15, str);
    final keyString = str.substring(0, 32);
    const String iv = 'your_secret_iv44'; //16

    await file.writeAsString(encryptText(content, keyString, iv));
  } catch (e) {
    print('Error saving text to file: $e');
  }
}

Future<String?> readSettingsPassFileContents() async {
  String filePath = '';
  try {
    Directory docPasDirectory = Directory('');
    if (Platform.isWindows) {
      docPasDirectory = Directory('./src/settings/pass');
    } else if (Platform.isMacOS) {
      Directory docDirectory = await getApplicationDocumentsDirectory();
      String docDirectoryPath = docDirectory.path;
      docPasDirectory = Directory('$docDirectoryPath/settings/pass');
    } else {
      print('Running on an unknown platform');
      exit(1);
    }

    // Check if the pass directory exists
    bool directoryExists = await docPasDirectory.exists();

    // If the directory doesn't exist, create it
    if (!directoryExists) {
      await docPasDirectory.create(recursive: true);
    }

    filePath = "${docPasDirectory.path}/$settingsPassFileName";

    File file = File(filePath);
    if (!file.existsSync()) {
      file.createSync();
    }
    String contents = file.readAsStringSync();

    if (contents != "") {
      String str = "78915030";
      str = str.padRight(15, str);
      final keyString = str.substring(0, 32);
      const String iv = 'your_secret_iv44'; //16

      return decryptText(contents, keyString, iv);
    }
  } catch (e) {
    print('readPasswordFileContents ERROR: ${e.toString()}');
  }

  return null;
}