import 'package:laradoc_viewer/db/db.dart';

class AppState {
  Meta? meta;
  List<Page> pages = [];
  int selectedpage = 0;
  bool isHomeDrawerOpen = false;
}

List<Page> _getParents(List<Page> pages) {
  Map<String, Page> map = {};
  Set<String> parentSet = {};

  List<Page> parents = [];
  for (var page in pages) {
    map[page.name] = page;
  }

  for (var page in pages) {
    if (page.parentName.isNotEmpty && !map.containsKey(page.parentName)) {
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

initAppState() async {
  if (appState.meta == null) {
    await initializeDB();
    appState.meta = await Meta.getMeta();
    var pages = await Page.getPages();

    var parents = pages.where((element) => element.parentName == "").toList();
    if (parents.isEmpty) {
      parents = _getParents(pages);
    }
    for (var parent in parents) {
      parent.children =
          pages.where((element) => element.parentName == parent.name).toList();
      if (parent.link.isNotEmpty) {
        parent.children.insert(0, parent);
      }
    }
    appState.pages = parents;
  }
}

AppState appState = AppState();
