import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/screens/home.dart';

class TitleView extends StatefulWidget {
  TitleView({super.key});


  @override
  State<TitleView> createState() => _TitleViewState();

}

class _TitleViewState extends State<TitleView> {
    String title = "Prologue";
  List<String> titles = List.filled(20, "title", growable: true);
  bool isOpened = false;
  bool isLoading = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColours.primary,
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColours.lightTone,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        leading: GestureDetector(
          child: Icon(isOpened ? Icons.arrow_back : Icons.menu),
          onTap: () {
            setOpenState(!isOpened);
          },
        ),
      ),
      body: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
          child: titles.length == 0
              ? Center()
              : Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: titles.length,
                    itemBuilder: (context, index) {
                      return Container(
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
                            Text(
                              titles[index],
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                  color: AppColours.dark,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )),
    );
  }

  void setTitles(List<String> titles) {
    setState(() {
      titles = titles;
    });
  }

  void setOpenState(bool state) {
    if (isOpened != state) {
      setState(() {
        isOpened = state;
        Home.showDrawer=state;
        
      });
    }
  }

  void setLoadingState(bool state) {
    if (isLoading != state) {
      setState(() {
        isLoading = state;
      });
    }
  }
}
