import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:medscribe_app/screens/onboarding_screens.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isAnimated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    _controller.forward().whenComplete(() {
      setState(() {
        _isAnimated = true;
      });
    });
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3));
    Get.toNamed('/home');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
            colors: [Color(0xFFFF9B62), Color(0xC9FF621E)],
            begin: Alignment(0.00, -1.00),
            end: Alignment(0, 1),
          )),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            FadeTransition(
                opacity: _controller.drive(CurveTween(curve: Curves.easeIn)),
                child: Image.asset(
                  "assets/medscribe_logo.png",
                  height: MediaQuery.of(context).size.height * 0.28,
                  width: MediaQuery.of(context).size.width * 0.7,
                )),
            Typewriter('Where health meets history for a better tomorrow',
                _navigateToHome),
          ]),
        ),
      ),
    );
  }
}

class Typewriter extends StatefulWidget {
  final String text;
  final VoidCallback onEnd;

  Typewriter(this.text, this.onEnd);

  @override
  _TypewriterState createState() => _TypewriterState();
}

class _TypewriterState extends State<Typewriter> {
  int _charPosition = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), _printChar);
  }

  void _printChar() {
    setState(() {
      _charPosition++;
    });
    if (_charPosition < widget.text.length) {
      Future.delayed(Duration(milliseconds: 100), _printChar);
    } else {
      widget.onEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.20),
      child: Text(
        widget.text.substring(0, _charPosition),
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          fontSize: 14.0,
          fontWeight: FontWeight.w400,
          color: Color(0xFFFFFFFF),
        ),
      ),
    );
  }
}
