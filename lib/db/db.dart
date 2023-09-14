import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Database? ContentDB;

class Page {
  int id = -1;
  String link = "";
  String name = "";
  String parent = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

class Meta {
  int id = -1;
  String link = "";
  Uint8List mainLogo = Uint8List(0);
  String logoType = "";
  String name = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

class PageContent {
  int id = -1;
  String link = "";
  String data = "";
  String title = "";
  bool isHtml = false;
  bool isFullHtml = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  static Future<PageContent?> find(int id) async {
    PageContent? content;
    var result = await ContentDB!
        .query('contents', limit: 1, where: "id = ?", whereArgs: [id]);

    if (result.isNotEmpty) {
      var entry = result[0];
      content = PageContent();
      if (entry["id"] != null) {
        content.id = entry["id"] as int;
      }
      if (entry["created_at"] != null) {
        var created = entry["created_at"] as String;
      }
      if (entry["updated_at"] != null) {
        var updated = entry["updated_at"] as String;
      }
      if (entry["data"] != null) {
        content.data = entry["data"] as String;
      }
      if (entry["link"] != null) {
        content.link = entry["link"] as String;
      }
      if (entry["title"] != null) {
        content.title = entry["title"] as String;
      }
      if (entry["is_html"] != null) {
        content.isHtml = (entry["is_html"] as int) > 0;
      }
      if (entry["is_full_html"] != null) {
        content.isFullHtml = (entry["is_full_html"] as int) > 0;
      }
    }
    return content;
  }
}

class ImageAsset {
  int id = -1;
  String url = "";
  Uint8List data = Uint8List(0);
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}

Future<String> getDbFile() async {
  var docDir = await getApplicationDocumentsDirectory();
  String databasesPath = docDir.absolute.path;
  String path = p.join(databasesPath, "db", 'data.db');
  return path;
}

Future<void> initializeDB() async {
  if (ContentDB == null) {
    sqfliteFfiInit();
    var path = await getDbFile();
    var dbFile = File(path);
    var source = await rootBundle.load("assets/data.db");
    if (!await dbFile.exists() ||
        (await dbFile.stat()).size != source.lengthInBytes) {
      dbFile = await dbFile.create(recursive: true);
      dbFile = await dbFile.writeAsBytes(source.buffer.asInt8List());
    }
    databaseFactory = databaseFactoryFfi;
    ContentDB = await databaseFactory.openDatabase(path);
  }
}
