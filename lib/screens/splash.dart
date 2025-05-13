// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:laradoc_viewer/colors/colors.dart';
import 'package:laradoc_viewer/db/db.dart';
import 'package:laradoc_viewer/screens/home.dart';
import 'package:laradoc_viewer/utils/utils.dart';

class Splash extends StatefulWidget {
  Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  Meta? meta;
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    await initAppState();
    setState(() {
      meta = appState.meta;
    });

    await Future.delayed(const Duration(milliseconds: 500));
    Navigator.pushReplacement<void, void>(context, MaterialPageRoute<void>(
      builder: (context) {
        return const Home();
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            color: AppColours.lightTone,
          ),
          SvgPicture.asset(
            'assets/bg.svg',
            width: double.maxFinite,
            height: double.maxFinite,
            alignment: Alignment.center,
            fit: BoxFit.cover,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              child: CircularProgressIndicator(
                color: AppColours.primary,
              ),
            ),
          ),
          meta != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      meta!.logoType == "svg"
                          ? SvgPicture.memory(
                              meta!.mainLogo,
                              alignment: Alignment.center,
                              width: 48,
                              height: 48,
                            )
                          : Image.memory(meta!.mainLogo),
                      Container(
                        margin: const EdgeInsets.all(16),
                        child: Text(
                          meta!.name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColours.primaryDark,
                              fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                )
              : Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Loading",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColours.primaryDark,
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          color: AppColours.primary,
                        ),
                      ),
                    ],
                  ),
                )
        ],
      ),
    );
  }
}
