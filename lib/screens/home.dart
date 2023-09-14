import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/db/db.dart';
import 'package:laradoc_viewer/screens/title_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  static bool showDrawer=false;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {

  var titleView = TitleView();
  static Meta? meta;
  @override
  void initState() {
    super.initState();
    if (meta == null) {
      Meta.getMeta().then((value) => {
            setState(() {
              meta = value;
            })
          });
    }

  
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        Drawer(meta: meta),
        AnimatedContainer(
          duration: Duration(milliseconds: 250),
          color: Colors.transparent,
          transform: Matrix4.translationValues(
             Home. showDrawer ?  250:0, Home.showDrawer ?  100:0, 0),
            transformAlignment: AlignmentDirectional.centerEnd,
          child: titleView,
        )
      ]),
    );
  }
}

class Drawer extends StatelessWidget {
  const Drawer({
    super.key,
    required this.meta,
  });

  final Meta? meta;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      color: AppColours.primary,
      padding: const EdgeInsets.symmetric(vertical: 16),
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
                  meta != null
                      ? Container(
                          width: 72,
                          height: 72,
                          margin: const EdgeInsets.only(top: 16),
                          decoration: BoxDecoration(
                            color: AppColours.lightTone,
                            borderRadius: BorderRadius.circular(60),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: meta!.logoType == "svg"
                              ? SvgPicture.memory(
                                  meta!.mainLogo,
                                  alignment: Alignment.center,
                                  width: 48,
                                  height: 48,
                                )
                              : Image.memory(meta!.mainLogo),
                        )
                      : const Placeholder(),
                  const SizedBox(
                    width: 16,
                  ),
                  Text(
                    meta?.name ?? "",
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
                child: Expanded(
                  child: ListView.builder(
                    itemCount: 100,
                    shrinkWrap: true,
                    controller: ScrollController(),
                    itemBuilder: (context, index) {
                      var isSelected = index == 0;
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: isSelected
                                ? AppColours.lightTone
                                : Colors.transparent),
                        child: Row(
                          children: [
                            Text(
                              "Main content ${index + 1}",
                              style: TextStyle(
                                fontWeight: FontWeight.normal,
                                color: isSelected
                                    ? AppColours.dark
                                    : AppColours.lightTone,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
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
    );
  }
}
