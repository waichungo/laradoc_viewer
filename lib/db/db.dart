import 'dart:io';

import 'package:flutter/services.dart';
import 'package:laradoc_viewer/utils/utils.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Database? contentDB;
Database? bookmarksDB;

Future<List<Page>> getBookMarks() async {
  List<Page> bookmarks = [];
  var result = await bookmarksDB!.query('bookmarks');
  bookmarks = result.map((e) => Page.fillPageWithResultEntry(e)).toList();
  return bookmarks;
}

Future<bool> deleteBookmark(int id) async {
  var result =
      await bookmarksDB!.delete('bookmarks', where: "id = ?", whereArgs: [id]);
  return result > 0;
}

Future<Page?> findBookmark(int id) async {
  Page? page;
  var result = await bookmarksDB!
      .query('bookmarks', limit: 1, where: "id = ?", whereArgs: [id]);
  if (result.isNotEmpty) {
    page = Page.fillPageWithResultEntry(result[0]);
  }
  return page;
}

Future<bool> addBookmark(Page page) async {
  Map<String, Object?> values = {
    "id": page.id,
    "name": page.name,
    "link": page.link,
    "parent": page.parentName
  };
  var result = await bookmarksDB!
      .insert('bookmarks', values, conflictAlgorithm: ConflictAlgorithm.abort);
  return result > 0;
}

class Page {
  int id = -1;
  String link = "";
  String name = "";
  String parentName = "";
  List<Page> children = [];
  bool isNested = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  static Future<Page?> findWithUrl(String url) async {
    var result = await contentDB!
        .query('contents', limit: 1, where: "link = ?", whereArgs: [url]);
    if (result.isNotEmpty) {
      return fillPageWithResultEntry(result[0]);
    }

    return null;
  }

  static Page fillPageWithResultEntry(Map<String, dynamic> entry) {
    Page page = Page();
    if (entry["id"] != null) {
      page.id = entry["id"] as int;
    }
    if (entry["created_at"] != null) {
      var created = entry["created_at"] as String;
    }
    if (entry["updated_at"] != null) {
      var updated = entry["updated_at"] as String;
    }
    if (entry["name"] != null) {
      page.name = entry["name"] as String;
    }
    if (entry["link"] != null) {
      page.link = entry["link"] as String;
    }
    if (entry["parent"] != null) {
      page.parentName = entry["parent"] as String;
    }
    if (entry["is_nested"] != null) {
      page.isNested = entry["is_nested"] as int > 0;
    }
    return page;
  }

  static Future<List<Page>> getPages() async {
    List<Page> pages = [];
    var result = await contentDB!.query('pages');
    if (result.isNotEmpty) {
      for (var entry in result) {
        pages.add(fillPageWithResultEntry(entry));
      }
    }
    return pages;
  }
}

class Meta {
  int id = -1;
  String link = "";
  Uint8List mainLogo = Uint8List(0);
  String logoType = "";
  String name = "";
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();

  static Future<Meta?> getMeta() async {
    Meta? meta;
    var result = await contentDB!.query('meta', limit: 1);

    if (result.isNotEmpty) {
      var entry = result[0];
      meta = Meta();
      if (entry["id"] != null) {
        meta.id = entry["id"] as int;
      }
      if (entry["created_at"] != null) {
        var created = entry["created_at"] as String;
      }
      if (entry["updated_at"] != null) {
        var updated = entry["updated_at"] as String;
      }
      if (entry["main_logo"] != null) {
        meta.mainLogo = entry["main_logo"] as Uint8List;
      }
      if (entry["name"] != null) {
        meta.name = entry["name"] as String;
      }
      if (entry["logo_type"] != null) {
        meta.logoType = entry["logo_type"] as String;
      }
      if (entry["source"] != null) {
        meta.link = entry["source"] as String;
      }
    }
    return meta;
  }
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
  static PageContent? loadResultSet(List<Map<String, Object?>> result) {
    PageContent? content;
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

  static Future<PageContent?> find(int id) async {
    var result = await contentDB!
        .query('contents', limit: 1, where: "id = ?", whereArgs: [id]);
    return loadResultSet(result);
  }

  static Future<PageContent?> findWithUrl(String url) async {
    var result = await contentDB!
        .query('contents', limit: 1, where: "link = ?", whereArgs: [url]);
    return loadResultSet(result);
  }
}

class ImageAsset {
  int id = -1;
  String url = "";
  String originalurl = "";
  String sourcePage = "";
  Uint8List data = Uint8List(0);
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
  static ImageAsset? loadImage(Map<String, Object?> result,
      {bool loadData = true}) {
    ImageAsset? content;
    if (result.isNotEmpty) {
      var entry = result;
      content = ImageAsset();
      if (entry["id"] != null) {
        content.id = entry["id"] as int;
      }
      if (entry["created_at"] != null) {
        var created = entry["created_at"] as String;
      }
      if (entry["updated_at"] != null) {
        var updated = entry["updated_at"] as String;
      }
      if (loadData && entry["data"] != null) {
        content.data = entry["data"] as Uint8List;
      }
      if (entry["url"] != null) {
        content.url = entry["url"] as String;
      }
      if (entry["original_url"] != null) {
        content.originalurl = entry["original_url"] as String;
      }
      if (entry["source_page"] != null) {
        content.sourcePage = entry["source_page"] as String;
      }
    }
    return content;
  }

  static List<ImageAsset> loadResultSet(List<Map<String, Object?>> result,
      {bool loadData = true}) {
    List<ImageAsset> res =
        result.map((entry) => loadImage(entry, loadData: loadData)!).toList();
    return res;
  }

  static Future<ImageAsset?> find(int id, bool loadData) async {
    ImageAsset? image;
    var result = await contentDB!
        .query('images', limit: 1, where: "id = ?", whereArgs: [id]);
    if (result.isNotEmpty) {
      image = loadImage(result[0], loadData: loadData);
    }
    return image;
  }

  static Future<List<ImageAsset>> findWithQuery(
      bool loadData, String query, List<Object?>? bindArgs) async {
    var result =
        await contentDB!.query('images', where: query, whereArgs: bindArgs);
    if (result.isNotEmpty) {
      return result.map((e) => loadImage(e, loadData: loadData)!).toList();
    }
    return [];
  }

  static Future<List<ImageAsset>> getImages(bool loadData) async {
    List<ImageAsset> images = [];
    var result = await contentDB!.query('images');
    if (result.isNotEmpty) {
      images = loadResultSet(result, loadData: loadData);
    }
    return images;
  }

  static Future<List<String>> getImageLinks() async {
    var result = await contentDB!.query('images');
    List<String> links =
        loadResultSet(result, loadData: false).map((e) => e.url).toList();
    return links;
  }
}

Future<String> getDocDbFile() async {
  String path = p.join(await getAppDirectory(), "db", 'data.db');
  return path;
}

Future<String> getBookmarkDbFile() async {
  String path = p.join(await getAppDirectory(), "db", 'bookmarks.db');
  return path;
}

Future<void> initializeDB() async {
  if (contentDB == null) {
    sqfliteFfiInit();
    var path = await getDocDbFile();
    var bookmarkDbPath = await getBookmarkDbFile();
    var dbFile = File(path);
    var source = await rootBundle.load("assets/data.db");
    if (!await dbFile.exists() ||
        (await dbFile.stat()).size != source.lengthInBytes) {
      dbFile = await dbFile.create(recursive: true);
      dbFile = await dbFile.writeAsBytes(source.buffer.asInt8List());
    }
    databaseFactory = databaseFactoryFfi;
    contentDB = await databaseFactory.openDatabase(path);
    bookmarksDB = await databaseFactory.openDatabase(bookmarkDbPath,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await db.execute(r'''
            CREATE TABLE IF NOT EXISTS bookmarks (
              id	INTEGER NOT NULL UNIQUE,
              name	TEXT,
              link	TEXT NOT NULL UNIQUE,
              parent	TEXT,
              PRIMARY KEY("id")
            );
            ''');
          },
        ));
  }
}
