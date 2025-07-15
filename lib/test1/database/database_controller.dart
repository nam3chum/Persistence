import 'package:presient/test1/database/database_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/genre_model.dart';
import '../model/story_model.dart';

class DatabaseController {
  final dbClient = DataBaseProvider.dataBaseProvider;

  Future<void> insertGenres(List<Genre> genres) async {
    final db = await DataBaseProvider.dataBaseProvider.db;

    final batch = db.batch();
    for (var genre in genres) {
      batch.insert('genresTable', genre.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<List<Genre>> getAllGenres() async {
    final db = await DataBaseProvider.dataBaseProvider.db;
    var result = await db.query("genresTable", orderBy: "id DESC");
    return result.isNotEmpty ? result.map((e) => Genre.fromJson(e)).toList() : [];
  }

  Future<int> updateGenre(Genre genre) async {
    final db = await dbClient.db;
    return db.update('genresTable', genre.toJson(), where: 'id = ?', whereArgs: [genre.id]);
  }

  Future<int> deleteGenre(String id) async {
    final db = await dbClient.db;
    return db.delete('genresTable', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> createStory(Story story) async {
    final db = await dbClient.db;
    return db.insert("storiesTable", story.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Story>> getAllStories({List<String>? columns}) async {
    final db = await dbClient.db;
    var result = await db.query("storiesTable", columns: columns, orderBy: "updateAt DESC");
    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList() : [];
  }

  Future<List<Story>> searchStories({List<String>? columns, required String query}) async {
    final db = await dbClient.db;
    var result = await db.query(
      "storiesTable",
      columns: columns,
      where: "(name LIKE ? OR author LIKE ? OR origin_name LIKE ?) OR deleted LIKE ?",
      whereArgs: ["%$query%", '%$query%', '%$query%', '0'],
    );
    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList() : [];
  }

  Future<int> countStory(String status) async {
    final db = await dbClient.db;
    final count = Sqflite.firstIntValue(
      await db.rawQuery("SELECT COUNT(*) FROM storiesTable WHERE status = $status AND deleted = 0"),
    );

    return count ?? 0;
  }

  Future<int> updateStory(Story story) async {
    final db = await dbClient.db;

    return await db.update("storiesTable", story.toJson(), where: "id = ?", whereArgs: [story.id]);
  }

  Future<int> deleteStory(String? id) async {
    final db = await dbClient.db;

    return await db.delete("storiesTable", where: "id = ?", whereArgs: [id]);
  }

  Future<Story?> getStoryById(String id) async {
    final db = await dbClient.db;
    var result = await db.query("storiesTable", limit: 1, where: "id = ?", whereArgs: [id]);
    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList()[0] : null;
  }

  Future<int> removedAllStories() async {
    final db = await dbClient.db;
    return db.delete("storiesTable");
  }

  Future<List<Story>> getAllStoriesSameAuthor(String author) async {
    final db = await dbClient.db;
    var result = await db.query(
      "storiesTable",
      where: "author = ? AND deleted = 0",
      whereArgs: [author],
      orderBy: "date_modified ASC",
    );

    return result.isNotEmpty ? result.map((e) => Story.fromJson(e)).toList() : [];
  }
}
