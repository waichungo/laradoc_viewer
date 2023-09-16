import 'dart:io';

import 'package:laradoc_viewer/db/db.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class AppState {
  Meta? meta;
  List<Page> pages = [];
  int selectedpage = 0;
}

String generateHash(String input) {
  var bytes = utf8.encode(input); // data being hashed

  var digest = sha256.convert(bytes);

  var result = digest.toString();
  return result;
}

List<Page> _getParents(List<Page> pages) {
  Map<String, Page> map = {};
  Set<String> parentSet = {};

  List<Page> parents = [];
  for (var page in pages) {
    map[page.name] = page;
  }

  for (var page in pages) {
    if (page.parentName.isNotEmpty &&
        !map.containsKey(page.parentName) &&
        !page.isNested) {
      parentSet.add(page.parentName);
    }
  }
  for (var name in parentSet) {
    var page = Page()..name = name;
    if (map.containsKey(name)) {
      page = map[name] ?? page;
    }
    parents.add(page);
  }
  return parents;
}

Future<String> getAppDirectory() async {
  var docDir = await getApplicationDocumentsDirectory();
  String baseDir = docDir.absolute.path;
  String path = p.join(baseDir, "lara_doc_viewer");
  var dir = Directory(path);
  if (!await dir.exists()) {
    dir.create(recursive: true);
  }
  return dir.path;
}

Future<String> getImagesDirectory() async {
  String path = p.join(await getAppDirectory(), "images");
  return path;
}

Future<String> getImageAssetFileNameFromUrl(String url) async {
  String dir = await getImagesDirectory();
  var ext = "";

  var link = Uri.parse(url).path;
  var idx = link.lastIndexOf(".");
  if (idx > -1) {
    ext = link.substring(idx);
  }
  if (ext == "") {
    if (url.toLowerCase().contains("jpg")) {
      ext = ".jpg";
    } else if (url.toLowerCase().contains("png")) {
      ext = ".png";
    } else if (url.toLowerCase().contains("svg")) {
      ext = ".svg";
    }
  }
  var imageFileName = p.join(dir, generateHash(url) + ext);
  return imageFileName;
}

Future<void> loadImages() async {
  var images = await ImageAsset.getImages(false);
  var dir = await getImagesDirectory();
  for (var image in images) {
    var imageFileName = await getImageAssetFileNameFromUrl(image.url);
    var imageFile = File(imageFileName);
    if (!await imageFile.exists()) {
      await imageFile.create(recursive: true);
      var data = (await ImageAsset.find(image.id, true))!.data;
      await imageFile.writeAsBytes(data);
    }
  }
}

initAppState() async {
  if (appState.meta == null) {
    await initializeDB();
    appState.meta = await Meta.getMeta();
    var pages = await Page.getPages();
    await loadImages();
    var parents = pages
        .where((element) => element.parentName == "" && !element.isNested)
        .toList();
    if (parents.isEmpty) {
      parents = _getParents(pages);
    }
    for (var parent in parents) {
      parent.children =
          pages.where((element) => element.parentName == parent.name).toList();
      if (parent.link.isNotEmpty &&
          !parent.children.map((e) => e.link).contains(parent.link)) {
        parent.children.insert(0, parent);
      }
    }
    appState.pages = parents;
  }
}

AppState appState = AppState();
