import 'dart:io';
import 'dart:convert';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:crypto/crypto.dart';

import 'common.dart';

late Database? _database;

const String databaseName = 'data.db';
const String databaseExportName = 'dataExport.db';
const String passwordsTableName = 'passwords1';
const String settingsTableName = 'settings';

const String passwordsTableIntiQuery =
    "CREATE TABLE IF NOT EXISTS $passwordsTableName (id INTEGER PRIMARY KEY, "
    "title TEXT,"
    "login TEXT,"
    "password TEXT,"
    "url TEXT,"
    "comment TEXT,"
    "changed INTEGER"
    ")";

const String settingsTableInitQuery =
    "CREATE TABLE IF NOT EXISTS $settingsTableName ("
    "key TEXT PRIMARY KEY,"
    "value TEXT"
    ")";

//DB commands
Future<void> initDBConnection() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> initDatabase() async {
  final String pathToDatabase = await getDBPath();

  _database = await openDatabase(pathToDatabase, version: 2,
      onCreate: (Database db, int version) async {
    await db.execute(passwordsTableIntiQuery);
    await db.execute(settingsTableInitQuery);
    await _initializeDefaultSettings(db);
  }, onOpen: (Database db) async {
    await db.execute(passwordsTableIntiQuery);
    await db.execute(settingsTableInitQuery);
    await _initializeDefaultSettings(db);
  }, onUpgrade: (Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(settingsTableInitQuery);
      await _initializeDefaultSettings(db);
    }
  });
}

Future<void> _initializeDefaultSettings(Database db) async {
  // Check if settings already exist
  final existingSettings = await db.query(settingsTableName);
  if (existingSettings.isNotEmpty) return;

  // Insert default settings
  await db.insert(settingsTableName, {'key': 'password_length', 'value': '12'});
  await db.insert(settingsTableName, {'key': 'password_letters', 'value': 'true'});
  await db.insert(settingsTableName, {'key': 'password_numbers', 'value': 'true'});
  await db.insert(settingsTableName, {'key': 'password_special_char', 'value': 'true'});
  await db.insert(settingsTableName, {'key': 'password_uppercase', 'value': 'true'});
}

Future<String> getDBPath() async {
  final appDocumentDir = await getApplicationDocumentsDirectory();

  return join(appDocumentDir.path, databaseName);
}

Future<void> deleteDB() async {
  try {
    final String pathToDatabase = await getDBPath();
    await deleteDatabase(pathToDatabase);
    print('Database deleted successfully.');
  } catch (e) {
    print('Error deleting database: $e');
  }
}

Future<void> exportDatabase({String? exportPath}) async {
  final String pathToDatabase = await getDBPath();
  
  // If no path provided, use default location
  if (exportPath == null) {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    exportPath = join(appDocDir.path, databaseExportName);
  }

  // Copy the database file
  File dbFile = File(pathToDatabase);
  File exportFile = File(exportPath);
  await dbFile.copy(exportFile.path);
}

Future<void> importDatabase(String importPath) async {
  // Close current database connection if open
  if (_database != null) {
    await _database!.close();
    _database = null;
  }
  
  final String pathToDatabase = await getDBPath();
  
  // Check if import file exists
  File importFile = File(importPath);
  if (!await importFile.exists()) {
    throw Exception('Import file does not exist');
  }
  
  // Backup current database if it exists
  File currentDbFile = File(pathToDatabase);
  if (await currentDbFile.exists()) {
    final backupPath = '${pathToDatabase}.backup.${DateTime.now().millisecondsSinceEpoch}';
    await currentDbFile.copy(backupPath);
  }
  
  // Copy imported file to database location
  await importFile.copy(pathToDatabase);
  
  // Reinitialize database connection
  await initDatabase();
}

// CRUD
Future<void> insertData(
  String title,
  String login,
  String password,
  String url,
  String comment,
) async {
  await _database!.insert(passwordsTableName, {
    'title':    await encryptText(title),
    'login':    await encryptText(login),
    'password': await encryptText(password),
    'url':      await encryptText(url),
    'comment':  await encryptText(comment),
    'changed':  DateTime.now().millisecondsSinceEpoch
  });
}

Future<void> updateData(
  int id,
  String title,
  String login,
  String password,
  String url,
  String comment,
) async {
  await _database!.update(
      passwordsTableName,
      {
        'title':    await encryptText(title),
        'login':    await encryptText(login),
        'password': await encryptText(password),
        'url':      await encryptText(url),
        'comment':  await encryptText(comment),
        'changed':  DateTime.now().millisecondsSinceEpoch
      },
      where: 'id=$id');
}

Future<void> deleteData(int id) async {
  await _database!.delete(passwordsTableName, where: 'id=$id');
}

Future<List<Map<String, dynamic>>> getPasswords() async {
  return await _database!.query(passwordsTableName);
}

// Settings CRUD
Future<String?> getSetting(String key) async {
  final result = await _database!.query(
    settingsTableName,
    where: 'key = ?',
    whereArgs: [key],
  );
  if (result.isEmpty) return null;
  return result.first['value'] as String?;
}

Future<void> setSetting(String key, String value) async {
  await _database!.insert(
    settingsTableName,
    {'key': key, 'value': value},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

Future<Map<String, String>> getAllSettings() async {
  final result = await _database!.query(settingsTableName);
  final Map<String, String> settings = {};
  for (var row in result) {
    settings[row['key'] as String] = row['value'] as String;
  }
  return settings;
}

// Master Password functions
Future<bool> hasMasterPassword() async {
  final masterPasswordHash = await getSetting('master_password_hash');
  return masterPasswordHash != null && masterPasswordHash.isNotEmpty;
}

Future<void> setMasterPassword(String password) async {
  final hash = _hashPassword(password);
  await setSetting('master_password_hash', hash);
}

Future<bool> verifyMasterPassword(String password) async {
  final storedHash = await getSetting('master_password_hash');
  if (storedHash == null) return false;
  final inputHash = _hashPassword(password);
  return storedHash == inputHash;
}

String _hashPassword(String password) {
  // Using SHA-256 hash for password storage
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<void> changeMasterPassword(String oldPassword, String newPassword) async {
  // Verify old password first
  final isValid = await verifyMasterPassword(oldPassword);
  if (!isValid) {
    throw Exception('Current password is incorrect');
  }
  
  // Set new password
  await setMasterPassword(newPassword);
}

Future<String?> getMasterPhrase() async {
  return await getSetting('master_phrase');
}

Future<void> setMasterPhrase(String phrase) async {
  await setSetting('master_phrase', phrase);
}

// Change crypto string and re-encrypt all data
Future<void> changeCryptoString(String newCryptoString) async {
  if (newCryptoString.length < 8) {
    throw Exception('Crypto string must be at least 8 characters');
  }
  
  await initDatabase();
  
  // Get old crypto string (required for re-encryption)
  final oldCryptoString = await getSetting('crypto_string');
  if (oldCryptoString == null || oldCryptoString.isEmpty) {
    throw Exception('No existing encryption key. Set it in Settings first.');
  }
  if (oldCryptoString == newCryptoString) {
    return; // No change needed
  }
  
  // Get all passwords
  final passwords = await getPasswords();
  
  // Decrypt all data with old crypto string and re-encrypt with new one
  for (var password in passwords) {
    // Decrypt with old crypto string
    final title = decryptTextSync(password['title'] as String, cryptoString: oldCryptoString);
    final login = decryptTextSync(password['login'] as String, cryptoString: oldCryptoString);
    final pwd = decryptTextSync(password['password'] as String, cryptoString: oldCryptoString);
    final url = decryptTextSync(password['url'] as String, cryptoString: oldCryptoString);
    final comment = decryptTextSync(password['comment'] as String, cryptoString: oldCryptoString);
    
    // Encrypt with new crypto string
    final encryptedTitle = encryptTextSync(title, cryptoString: newCryptoString);
    final encryptedLogin = encryptTextSync(login, cryptoString: newCryptoString);
    final encryptedPwd = encryptTextSync(pwd, cryptoString: newCryptoString);
    final encryptedUrl = encryptTextSync(url, cryptoString: newCryptoString);
    final encryptedComment = encryptTextSync(comment, cryptoString: newCryptoString);
    
    // Update in database
    await _database!.update(
      passwordsTableName,
      {
        'title': encryptedTitle,
        'login': encryptedLogin,
        'password': encryptedPwd,
        'url': encryptedUrl,
        'comment': encryptedComment,
        'changed': DateTime.now().millisecondsSinceEpoch
      },
      where: 'id=${password['id']}',
    );
  }
  
  // Update crypto string setting
  await setSetting('crypto_string', newCryptoString);
  
  // Refresh cached crypto string
  await refreshCryptoStringCache();
}
