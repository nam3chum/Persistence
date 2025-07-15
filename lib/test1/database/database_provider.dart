import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

class DataBaseProvider {
  static final DataBaseProvider dataBaseProvider = DataBaseProvider();
  late final Future<Database> db = createDatabase();

  Future<Database> createDatabase() async {
    Directory? dir;
    // try {
    //   if (await Permission.storage.request().isGranted) {
    //     dir = await getExternalStorageDirectory();
    //   } else {
    //     debugPrint("không truy cập được thư mục");
    //   }
    // } catch (e) {
    //   debugPrint("Lỗi : $e");
    // }

    dir = await getApplicationDocumentsDirectory();
    String path = join(dir.path, "Stories.db");
    debugPrint("đươờng dẫn : $path");
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE genresTable (
          id TEXT PRIMARY KEY ,
          name TEXT
        )
        ''');
        await db.execute(
          "CREATE TABLE storiesTable ("
          "id INTEGER PRIMARY KEY AUTOINCREMENT,"
          "name TEXT,"
          "originName TEXT,"
          "content TEXT,"
          "deleted INTEGER,"
          "author TEXT,"
          "imgUrl TEXT,"
          "status TEXT,"
          "genreId TEXT,"
          "numberOfChapter TEXT,"
          "updateAt TEXT DEFAULT CURRENT_TIMESTAMP,"
          "FOREIGN KEY (genreId) REFERENCES genresTable(id)"
          ")",
        );

        await db.execute('''
        CREATE TABLE story_genres_table (
          storyId INTEGER,
          genreId TEXT,
          PRIMARY KEY (storyId, genreId),
          FOREIGN KEY (storyId) REFERENCES storiesTable(id),
          FOREIGN KEY (genreId) REFERENCES genresTable(id)
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
