import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:laradoc_viewer/db/db.dart';
import 'package:laradoc_viewer/screens/home.dart';
import 'package:laradoc_viewer/screens/splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Laravel documentation',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ContentDB == null ? Splash() : Home(),
    );
  }
}

// class MyHomePage extends StatefulWidget {
//   MyHomePage({super.key, this.title = ""});
//   String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int id = 89;
//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       body: FutureBuilder(
//         future: PageContent.find(id),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             if (snapshot.hasData || snapshot.data != null) {
//               // setState(() {
//               //   widget.title=snapshot.data!.title;
//               // });
//               return Column(
//                 // shrinkWrap: true,
//                 children: [
//                   AppBar(
//                     // TRY THIS: Try changing the color here to a specific color (to
//                     // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//                     // change color while the other colors stay the same.
//                     backgroundColor:
//                         Theme.of(context).colorScheme.inversePrimary,
//                     // Here we take the value from the MyHomePage object that was created by
//                     // the App.build method, and use it to set our appbar title.
//                     title: Text(snapshot.data!.title),
//                   ),
//                   Expanded(
//                     child: Markdown(
//                       data: snapshot.data!.data,
//                       onTapLink: (text, href, title) {
//                         print("Tapped link");
//                       },
//                     ),
//                   ),
//                 ],
//               );
//             } else {
//               return Center(
//                 child: Text("Sorry data could not be loaded"),
//               );
//             }
//           }
//           if (snapshot.hasError) {
//             return Center(
//               child: Text("Sorry an error occured while loading"),
//             );
//           }

//           return Center(child: CircularProgressIndicator());
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           int next = 0;
//           if (id > 90) {
//             next = 0;
//           } else {
//             next = id + 1;
//           }
//           setState(() {
//             id = next;
//           });
//         },
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
