import 'dart:async';

import 'package:flutter/material.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _pageController = PageController();
  final _currentPageNotifier = ValueNotifier<int>(0);
  final _pageCount = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 2), (Timer timer) {
      if (_currentPageNotifier.value < _pageCount - 1) {
        _currentPageNotifier.value++;
        _pageController.animateToPage(_currentPageNotifier.value,
            duration: Duration(milliseconds: 350), curve: Curves.easeIn);
      } else {
        _currentPageNotifier.value = 0;
        _pageController.jumpToPage(0);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final images = [
    'assets/home_one.png',
    'assets/home_two.png',
    'assets/home_three.png',
  ];
  final title = [
    'Portable Medical History',
    'Digital Prescription',
    'AI Generated Report Insights',
  ];
  final desc = [
    'Access your complete medical records anytime, anywhere',
    'Instant, secure digital prescriptions for efficient medical guidance.',
    'Smart AI analysis for precise diagnostic reports analysis.',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.70,
          child: Stack(alignment: AlignmentDirectional.bottomCenter, children: [
            PageView.builder(
                controller: _pageController,
                itemCount: _pageCount,
                onPageChanged: (int index) {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _currentPageNotifier.value = index;
                  });
                },
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.only(
                        bottom: MediaQuery.of(context).size.height * 0.1),
                    alignment: Alignment.center,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          images[index],
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.38,
                        ),
                        Text(
                          title[index],
                          textAlign: TextAlign.center,
                          style: MedScribe_Theme.home_title,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          desc[index],
                          textAlign: TextAlign.center,
                          style: MedScribe_Theme.home_desc,
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.10,
                        ),
                      ],
                    ),
                  );
                }),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.60,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pageCount, (index) {
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 2.0),
                      height: 8.0,
                      width: 8.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentPageNotifier.value == index
                            ? MedScribe_Theme.secondary_color
                            : Color(0xFFD0D0D0),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ]),
        ),
        Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.30,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF9B63),
                Color(0xFFFF621F),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MedScribe_Widgets.onboarding_button(
                  backgroundColor: Color(0xFFFFFFFF),
                  context: context,
                  routePath: '/acc_type',
                  routeParam: 'login',
                  text: 'Login',
                  textColor: Color(0xFF000000)),
              MedScribe_Widgets.onboarding_button(
                backgroundColor: Color(0xFF161616),
                context: context,
                routePath: '/acc_type',
                routeParam: 'register',
                text: 'Create an account',
                textColor: Color(0xFFFFFFFF),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
