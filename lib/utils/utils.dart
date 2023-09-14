import 'package:laradoc_viewer/db/db.dart';

class AppState {
  Meta? meta;
  Page? page;
  int selectedPage = 0;
}

initAppState() async {
  if (appState.meta == null) {}
}

AppState appState = AppState();
