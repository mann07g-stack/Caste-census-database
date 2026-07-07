import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    // Using v4 to ensure a completely fresh start with correct columns
    final path = join(dbPath, 'census_v4.db'); 

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE census(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            householdId TEXT,
            caste TEXT,
            education TEXT,
            occupation TEXT,
            income INTEGER,
            region TEXT,
            status TEXT,
            profileImageBase64 TEXT
          )
        ''');
      },
    );
  }
}