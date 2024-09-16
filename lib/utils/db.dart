import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'common.dart';

late Database? _database;

const String passwordsTableName = 'passwords1';

const String passwordsTableIntiQuery =
    "CREATE TABLE IF NOT EXISTS $passwordsTableName (id INTEGER PRIMARY KEY, "
    "title TEXT,"
    "login TEXT,"
    "password TEXT,"
    "url TEXT,"
    "comment TEXT"
    ")";

Future<void> initDBConnection() async {
  // Initialize the sqflite ffi library for desktop platforms
  sqfliteFfiInit();
  // Set the databaseFactory to use sqflite ffi
  databaseFactory = databaseFactoryFfi;
}

Future<void> initDatabase() async {
  // Get the directory for the app's documents
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final String pathToDatabase = join(appDocumentDir.path, 'data.db');

  // Open/create the database at the specified path
  _database = await openDatabase(pathToDatabase, version: 1,
      onCreate: (Database db, int version) async {
    // Create the table
    await db.execute(passwordsTableIntiQuery);
  }, onOpen: (Database db) async {
    // Create the table
    await db.execute(passwordsTableIntiQuery);
  });
}

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
    'comment':  encryptText(comment)
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
        'comment':  encryptText(comment)
      },
      where: 'id=$id');
}

Future<void> deleteData(int id) async {
  await _database!.delete(passwordsTableName, where: 'id=$id');
}

Future<List<Map<String, dynamic>>> getPasswords() async {
  return await _database!.query(passwordsTableName);
}

// Get the database path
Future<String> getDatabasePath() async {
  String path = join(await getDatabasesPath(), 'data.db');
  return path;
}

Future<void> exportDatabase() async {
  // Get the directory to save the exported file
  final appDocumentDir = await getApplicationDocumentsDirectory();
  final String pathToDatabase = join(appDocumentDir.path, 'data.db');
  Directory appDocDir = await getApplicationDocumentsDirectory();
  String exportPath = join(appDocDir.path, 'data1.db');

  // Copy the database file
  File dbFile = File(pathToDatabase);
  File exportFile = File(exportPath);
  await dbFile.copy(exportFile.path);
}