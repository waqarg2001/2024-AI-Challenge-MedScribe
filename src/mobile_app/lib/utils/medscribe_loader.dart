import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MedScribeLoader extends StatefulWidget {
  @override
  _MedScribeLoaderState createState() => _MedScribeLoaderState();
}

class _MedScribeLoaderState extends State<MedScribeLoader> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Lottie.asset(
        "assets/medscribeloader.json",
      ),
    );
  }
}
