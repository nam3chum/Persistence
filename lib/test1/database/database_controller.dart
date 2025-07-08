import 'package:presient/test1/database/database_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../model/story_model.dart';

class DatabaseController {
  final dbClient = DataBaseProvider.dataBaseProvider;

  Future<int> createStory(Story? story) async {
    final db = await dbClient.db;
    return db.insert("storiesTable", story!.toJson());
  }

  Future<List<Story>> getAllStories({List<String>? columns}) async {
    final db = await dbClient.db;
    var result = await db.query("storiesTable", columns: columns,orderBy: "updateAt DESC");
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

  Future<int> countStory({List<String>? columns, required String status}) async {
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
