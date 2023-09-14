import 'package:laradoc_viewer/db/db.dart';

class AppState {
  Meta? meta;
  List<Page> pages = [];
}

initAppState() async {
  if (appState.meta == null) {
    appState.meta = await Meta.getMeta();
    var pages = await Page.getPages();

    var parents = pages.where((element) => element.parentName == "").toList();
    for (var parent in parents) {
      parent.children =
          pages.where((element) => element.parentName == parent.name).toList();
    }
    appState.pages = parents;
  }
}

AppState appState = AppState();
