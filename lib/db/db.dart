import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
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
  static Future<PageContent?> getContent(int id) async {
    PageContent? data;
    var result = await ContentDB!.query('contents',limit: 1);

    if (result.isNotEmpty){
        var entry=result[0];
        if(entry["id"]!=null){
            id=entry["id"] as int;
        }
        if(entry["created_at"]!=null){
            var created=entry["created_at"] as String;
        }
        if(entry["created_at"]!=null){
            var updated=entry["updated_at"] as String;
        }
        if(entry["data"]!=null){
            var updated=entry["updated_at"] as String;
        }

    }

    return data;
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
  String databasesPath = await databaseFactoryFfi.getDatabasesPath();
  String path = p.join(databasesPath, 'words.db');
  return path;
}

Future<void> initializeDB() async {
  sqfliteFfiInit();
  var path = await getDbFile();
  var dbFile=File(path);
  if (! await dbFile.exists()){
    var source=await rootBundle.load("assets/data.db");
    dbFile=await dbFile.writeAsBytes(source.buffer.asInt8List());
  }
  databaseFactory = databaseFactoryFfi;

  ContentDB = await databaseFactoryFfi.openDatabase(path);
}



