import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/screens/content_view.dart';
import 'package:laradoc_viewer/utils/utils.dart';
import 'package:laradoc_viewer/db/db.dart' as db;

class Home extends StatefulWidget {
  static List<db.Page> bookmarks = [];
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  static bool isHomeDrawerOpen = false;
  static bool showBookmarks = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    db.getBookMarks().then((bk) {
      setState(() {
        Home.bookmarks = bk;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: Colors.white,
      ),
      getDrawer(),
      AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          color: Colors.white,
          transformAlignment: AlignmentDirectional.centerEnd,
          transform: Matrix4.translationValues(
              isHomeDrawerOpen ? 72 : 0, isHomeDrawerOpen ? 8 : 0, 0)
            ..scale(isHomeDrawerOpen ? 0.7 : 1.0),
          child: Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: AppColours.dark.withAlpha(80),
              ),
            ]),
            child: getTitleView(),
          )),
    ]);
  }

  Widget getDrawer() {
    return Container(
      width: 240,
      color: AppColours.primary,
      padding: const EdgeInsets.only(top: 16),
      child: Material(
        color: AppColours.primary,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(
                height: 16,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    appState.meta != null
                        ? Container(
                            width: 72,
                            height: 72,
                            // margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              color: AppColours.lightTone,
                              borderRadius: BorderRadius.circular(60),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: appState.meta!.logoType == "svg"
                                ? SvgPicture.memory(
                                    appState.meta!.mainLogo,
                                    alignment: Alignment.center,
                                    width: 48,
                                    height: 48,
                                  )
                                : Image.memory(appState.meta!.mainLogo),
                          )
                        : const Placeholder(),
                    const SizedBox(
                      width: 16,
                    ),
                    Text(
                      appState.meta?.name ?? "",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColours.lightTone,
                          fontSize: 20),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 48),
                  child: ListView.builder(
                    itemCount: appState.pages.length,
                    shrinkWrap: true,
                    controller: ScrollController(),
                    itemBuilder: (context, index) {
                      var isSelected =
                          !showBookmarks && appState.selectedpage == index;
                      var hovered = false;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isHomeDrawerOpen = !isHomeDrawerOpen;
                              appState.selectedpage = index;
                              showBookmarks = false;
                            });
                          },
                          onHover: (value) {
                            setState(() {
                              hovered = value;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: isSelected || hovered
                                    ? AppColours.lightTone
                                    : Colors.transparent),
                            child: IntrinsicWidth(
                              child: Text(
                                "${appState.pages[index].name} (${appState.pages[index].children.length})",
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: isSelected
                                      ? AppColours.dark
                                      : AppColours.lightTone,
                                  fontSize: 16,
                                ),
                                softWrap: true,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      showBookmarks = true;
                      isHomeDrawerOpen = !isHomeDrawerOpen;
                    });
                  },
                  onHover: (value) {},
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: showBookmarks
                            ? AppColours.lightTone
                            : Colors.transparent),
                    child: Row(children: [
                      Icon(
                        Icons.bookmark,
                        color: showBookmarks
                            ? AppColours.dark
                            : AppColours.lightTone,
                      ),
                      Container(
                        width: 16,
                      ),
                      IntrinsicWidth(
                        child: Text(
                          "Bookmarks (${Home.bookmarks.length})",
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: showBookmarks
                                ? AppColours.dark
                                : AppColours.lightTone,
                            fontSize: 16,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  Widget getTitleView() {
    List<db.Page> titles = showBookmarks ? Home.bookmarks : appState.pages;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColours.primary,
        title: Text(
          showBookmarks ? "Bookmarks" : titles[appState.selectedpage].name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColours.lightTone,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        leading: GestureDetector(
          child: Icon(isHomeDrawerOpen ? Icons.arrow_back : Icons.menu,
              color: AppColours.lightTone),
          onTap: () {
            setState(() {
              isHomeDrawerOpen = !isHomeDrawerOpen;
            });
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: titles.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: AppColours.primary,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Icon(
                        Icons.list_alt,
                        size: 48,
                        color: AppColours.dark,
                      ),
                    ),
                    Container(
                      height: 16,
                    ),
                    Text(
                      showBookmarks
                          ? "No bookmark entries to show"
                          : "No pages to show",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColours.primaryDark,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: showBookmarks
                    ? titles.length
                    : titles[appState.selectedpage].children.length,
                itemBuilder: (context, index) {
                  var page = showBookmarks
                      ? titles[index]
                      : titles[appState.selectedpage].children[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) {
                          return ContentView(contentPage: page);
                        }),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 16,
                              spreadRadius: 2,
                              blurStyle: BlurStyle.normal,
                              color: AppColours.dark.withAlpha(40)),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            index < 9 ? "0${index + 1}." : "${index + 1}.",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              color: AppColours.primary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Text(
                              page.name,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: AppColours.dark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                              softWrap: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
