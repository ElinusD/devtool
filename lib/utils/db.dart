import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

late Database? _database;

Future<void> initDBConnection() async {
  // Initialize the sqflite ffi library for desktop platforms
  sqfliteFfiInit();
  // Set the databaseFactory to use sqflite ffi
  databaseFactory = databaseFactoryFfi;
}

Future<void> initDatabase() async {
  // Get the directory for the app's documents
  final appDocumentDir        = await getApplicationDocumentsDirectory();
  final String pathToDatabase = join(appDocumentDir.path, 'data.db');

  // Open/create the database at the specified path
  _database = await openDatabase(pathToDatabase, version: 1,
      onCreate: (Database db, int version) async {
        // Create the table
        await db.execute(
            'CREATE TABLE demo_table (id INTEGER PRIMARY KEY, name TEXT)');
      });
}

Future<void> insertData() async {
  // Insert some data into the table
  await _database!.insert('demo_table', {'name': 'John'});
}

Future<List<Map<String, dynamic>>> getData() async {
  // Get all rows from the table
  return await _database!.query('demo_table');
}
