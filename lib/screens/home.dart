import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/db/db.dart';
import 'package:laradoc_viewer/screens/content_view.dart';
import 'package:laradoc_viewer/utils/utils.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  bool isLoading = true;
  bool isHomeDrawerOpen = true;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
        color: Colors.white,
      ),
      getDrawer(),
      AnimatedContainer(
          duration: Duration(milliseconds: 250),
          color: Colors.white,
          transformAlignment: AlignmentDirectional.centerEnd,
          transform: Matrix4.translationValues(
              isHomeDrawerOpen ? 72 : 0, isHomeDrawerOpen ? 8 : 0, 0)
            ..scale(isHomeDrawerOpen ? 0.7 : 1.0),
          child: Container(
            child: getTitleView(),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                blurRadius: 16,
                color: AppColours.dark.withAlpha(80),
              ),
            ]),
          )),
    ]);
  }

  Widget getDrawer() {
    return Container(
      width: 240,
      color: AppColours.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Material(
        color: AppColours.primary,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    appState.meta != null
                        ? Container(
                            width: 72,
                            height: 72,
                            margin: const EdgeInsets.only(top: 16),
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
                      var isSelected = appState.selectedpage == index;
                      var hovered = false;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isHomeDrawerOpen = !isHomeDrawerOpen;
                              appState.selectedpage = index;
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
              Container(
                margin: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark,
                      color: AppColours.lightTone,
                    ),
                    SizedBox(
                      width: 16,
                    ),
                    Text(
                      "Bookmarks",
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        color: AppColours.lightTone,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Widget getTitleView() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColours.primary,
        title: Text(
          appState.pages[appState.selectedpage].name,
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
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: appState.pages.length == 0
            ? Center()
            : ListView.builder(
                shrinkWrap: true,
                itemCount:
                    appState.pages[appState.selectedpage].children.length,
                itemBuilder: (context, index) {
                  var page =
                      appState.pages[appState.selectedpage].children[index];
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
                      margin: EdgeInsets.only(
                          top: 16, left: 16, right: 16, bottom: 8),
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 24),
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
                          SizedBox(
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
