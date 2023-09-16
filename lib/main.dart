// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:laradoc_viewer/colors/colors.dart';
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
      title: 'NextJS documentation',
      theme: ThemeData(
        fontFamily: "Poppins",
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColours.primary,
          background: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: contentDB == null ? Splash() : const Home(),
    );
  }
}
