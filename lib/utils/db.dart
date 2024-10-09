import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'common.dart';

late Database? _database;

const String databaseName = 'data.db';
const String databaseExportName = 'dataExport.db';
const String passwordsTableName = 'passwords1';

const String passwordsTableIntiQuery =
    "CREATE TABLE IF NOT EXISTS $passwordsTableName (id INTEGER PRIMARY KEY, "
    "title TEXT,"
    "login TEXT,"
    "password TEXT,"
    "url TEXT,"
    "comment TEXT,"
    "changed INTEGER"
    ")";

//DB commands
Future<void> initDBConnection() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

Future<void> initDatabase() async {
  final String pathToDatabase = await getDBPath();

  _database = await openDatabase(pathToDatabase, version: 1,
      onCreate: (Database db, int version) async {
    await db.execute(passwordsTableIntiQuery);
  }, onOpen: (Database db) async {
    await db.execute(passwordsTableIntiQuery);
  });
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

Future<void> exportDatabase() async {
  final String pathToDatabase = await getDBPath();
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String exportPath = join(appDocDir.path, databaseExportName);

  // Copy the database file
  File dbFile = File(pathToDatabase);
  File exportFile = File(exportPath);
  await dbFile.copy(exportFile.path);
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
    'title':    encryptText(title),
    'login':    encryptText(login),
    'password': encryptText(password),
    'url':      encryptText(url),
    'comment':  encryptText(comment),
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
        'title':    encryptText(title),
        'login':    encryptText(login),
        'password': encryptText(password),
        'url':      encryptText(url),
        'comment':  encryptText(comment),
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
