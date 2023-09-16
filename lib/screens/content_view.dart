import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/db/db.dart' as db;
import 'package:laradoc_viewer/screens/home.dart';
import 'package:laradoc_viewer/utils/utils.dart';
import 'package:markdown_widget/config/all.dart';
import 'package:markdown_widget/widget/all.dart';
import 'package:markdown_widget/widget/markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

class ContentView extends StatefulWidget {
  db.Page contentPage;

  ContentView({super.key, required this.contentPage});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  db.PageContent? content;
  bool isBookmarked = false;
  @override
  void initState() {
    super.initState();
    loadContent();
  }

  TextStyle defaultTextStyle = TextStyle(
    color: AppColours.dark,
    fontSize: 16,
  );
  TextStyle codeStyle = TextStyle(fontSize: 16);
  TextStyle linkTextStyle = TextStyle(
    color: AppColours.primary,
    decoration: TextDecoration.underline,
    fontSize: 16,
  );
  void loadContent() async {
    if (content == null) {
      var ct = await db.PageContent.findWithUrl(widget.contentPage.link);
      if (ct != null) {
        await processContent(ct);
      }
      var inBookmarks = await db.findBookmark(widget.contentPage.id) != null;
      setState(() {
        content = ct;
        isBookmarked = inBookmarks;
      });
    }
  }

  Future<void> processContent(db.PageContent dbContent) async {
    var images = await db.ImageAsset.findWithQuery(
        false, "source_page = ?", [dbContent!.link]);
    for (var image in images) {
      var assetName = await getImageAssetFileNameFromUrl(image.url);
      // var uri = File(assetName).uri.toString();
      dbContent!.data =
          dbContent!.data.replaceAll(image.originalurl, assetName);
    }
    // if (images.isNotEmpty) {
    //   await File(r"C:\users\james\desktop\doc.md")
    //       .writeAsString(dbContent.data);
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(
            Icons.arrow_back,
            color: AppColours.dark,
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  (content == null || content!.title.isEmpty)
                      ? widget.contentPage.name!
                      : content!.title,
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: AppColours.primary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                width: 16,
              ),
              GestureDetector(
                onTap: () async {
                  bool res = false;
                  if (isBookmarked) {
                    await db.deleteBookmark(widget.contentPage.id);
                  } else {
                    await db.addBookmark(widget.contentPage);
                  }
                  res = await db.findBookmark(widget.contentPage.id) != null;
                  Home.bookmarks = await db.getBookMarks();
                  setState(() {
                    isBookmarked = res;
                  });
                },
                child: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_outline,
                  color: AppColours.primary,
                ),
              )
            ],
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 16),
            height: 1,
            color: AppColours.primary,
          ),
          Expanded(
            child: content == null
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColours.primary,
                    ),
                  )
                : (content!.isHtml
                    ? Placeholder()
                    : getMarkDown(content!.data)),
          )
        ]),
      ),
    );
  }

  // Widget getMarkDown(String markdown) {
  //   return Markdown(
  //     shrinkWrap: true,
  //     data: markdown,
  //     selectable: true,
  //     styleSheet: MarkdownStyleSheet(
  //       a: linkTextStyle,
  //       p: defaultTextStyle,
  //       strong: defaultTextStyle,
  //       codeblockPadding: EdgeInsets.symmetric(vertical: 16),
  //       pPadding: const EdgeInsets.symmetric(vertical: 16),
  //     ),
  //     listItemCrossAxisAlignment: MarkdownListItemCrossAxisAlignment.start,
  //     onTapLink: (text, href, title) async {
  //       if (href != null && !href.startsWith("#")) {
  //         if (!href.startsWith("http")) {
  //           href = appState.meta!.link + href;
  //         }
  //         var data = await db.PageContent.findWithUrl(href ?? "");
  //         if (data != null) {
  //           var pg = await db.Page.findWithUrl(href);
  //           if (pg != null) {
  //             Navigator.push(
  //               context,
  //               MaterialPageRoute(builder: (context) {
  //                 return ContentView(contentPage: pg);
  //               }),
  //             );
  //           }
  //         } else {
  //           await launchUrl(Uri.parse(href));
  //         }
  //       }
  //     },
  //     controller: ScrollController(),
  //   );
  // }
  openLink(String? href) async {
    if (href != null && !href.startsWith("#")) {
      if (!href.startsWith("http")) {
        if (href.startsWith("/")) {
          var uri = Uri.parse(appState.meta!.link);
          // var host = uri.scheme + "://" + uri.host;
          var host = uri.origin;
          href = host + href;
        } else {
          href = appState.meta!.link + href;
        }
      }
      var hashIdx = href.lastIndexOf("#");
      if (hashIdx > 0) {
        href = href.substring(0, hashIdx - 1);
      }
      if (widget.contentPage.link == href) {
        return;
      }
      var data = await db.PageContent.findWithUrl(href ?? "");
      if (data != null) {
        var pg = await db.Page.findWithUrl(href);
        if (pg != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) {
              return ContentView(contentPage: pg);
            }),
          );
        }
      } else {
        await launchUrl(Uri.parse(href));
      }
    }
  }

  Widget getMarkDown(String markdown) {
    return MarkdownWidget(
      data: markdown,
      config: MarkdownConfig(configs: [
        LinkConfig(
          onTap: (value) {
            openLink(value);
          },
        ),
      ]),
    );
  }
}
