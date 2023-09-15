import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/db/db.dart' as db;
import 'package:markdown/markdown.dart' as md;
import 'package:laradoc_viewer/utils/utils.dart';

class ContentView extends StatefulWidget {
  db.Page contentPage;
  ContentView({super.key, required this.contentPage});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  db.PageContent? content;
  @override
  void initState() {
    super.initState();
    loadContent();
  }

  TextStyle defaultTextStyle = TextStyle(
    color: AppColours.dark,
    fontSize: 16,
  );
  TextStyle codeStyle = TextStyle(
    fontSize: 16
  );
  TextStyle linkTextStyle = TextStyle(
    color: AppColours.primary,
    decoration: TextDecoration.underline,
    fontSize: 16,
  );
  void loadContent() async {
    if (content == null) {
      var ct = await db.PageContent.findWithUrl(widget.contentPage.link);
      setState(() {
        content = ct;
      });
    }
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
                  widget.contentPage.name!,
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
              Icon(
                Icons.bookmark_outline,
                color: AppColours.primary,
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
                    : Markdown(
                        shrinkWrap: true,
                        data: content!.data,
                        selectable: true,
                        extensionSet: md.ExtensionSet(
                          md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                          <md.InlineSyntax>[
                            md.EmojiSyntax(),
                            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                          ],
                        ),
                        styleSheet: MarkdownStyleSheet(
                          a: linkTextStyle,
                          p: defaultTextStyle,
                          codeblockPadding: EdgeInsets.symmetric(vertical: 16),
                       
                          pPadding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        listItemCrossAxisAlignment:
                            MarkdownListItemCrossAxisAlignment.start,
                        onTapLink: (text, href, title) async {
                          if (href != null) {
                            if (!href.startsWith("http")) {
                              href = appState.meta!.link + href;
                            }
                            var data =
                                await db.PageContent.findWithUrl(href ?? "");
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
                            }
                          }
                        },
                        controller: ScrollController(),
                      )),
          )
        ]),
      ),
    );
  }
}
