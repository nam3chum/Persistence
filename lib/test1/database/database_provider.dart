import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseProvider {
  static final DataBaseProvider dataBaseProvider = DataBaseProvider();
  late final Future<Database> db = createDatabase();

  Future<Database> createDatabase() async {
    Directory docDirectory = await getApplicationDocumentsDirectory();

    String path = join(docDirectory.path, "Stories.db");

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute(
          "CREATE TABLE storiesTable ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "originName TEXT,"
          "content TEXT,"
          "deleted INTEGER,"
          "author TEXT,"
          "genreId TEXT,"
          "imgUrl TEXT,"
          "status TEXT,"
          "numberOfChapter TEXT,"
          "updateAt TEXT DEFAULT CURRENT_TIMESTAMP"
          ")",
        );

        await db.execute('''
        CREATE TABLE genresTable (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,   
        )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {

        if (oldVersion < 2) {
          await db.execute("ALTER TABLE storiesTable ADD COLUMN storyType TEXT");
        }
      },
    );
  }
}
