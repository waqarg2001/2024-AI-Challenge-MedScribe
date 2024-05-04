import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medscribe_app/screens/contact_screen.dart';
import 'package:medscribe_app/screens/profile_screens_patient/health_history_screen.dart';
import 'package:medscribe_app/screens/profile_screens_patient/medical_profile_screen.dart';
import 'package:medscribe_app/screens/profile_screens_patient/settings_screen.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/shimmers.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PatientMainScreen extends StatefulWidget {
  PatientMainScreen({Key? key}) : super(key: key);

  @override
  PatientMainScreenState createState() => PatientMainScreenState();
}

class PatientMainScreenState extends State<PatientMainScreen>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _animationController2;

  String? patientCode = Get.parameters['profileCode'];

  String? authToken;

  bool health_history = false,
      profile = true,
      support = false,
      setting = false,
      transcribe = false;

  bool drawerOpen = false;

  @override
  void initState() {
    super.initState();
    getTokens();

    _pageController = PageController(initialPage: 1);
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _animationController2 = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  void getTokens() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      authToken = prefs.getString('authToken');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _animationController2.dispose();
    super.dispose();
  }

  String getAppBarTitleText() {
    if (profile) {
      return "Medical Profile";
    } else if (health_history) {
      return "Health History";
    } else if (support) {
      return "Support";
    } else if (setting) {
      return "Settings";
    }
    return "Health History";
  }

  String getAppBarTitleImagePath() {
    if (profile) {
      return "assets/patient_info.png";
    } else if (health_history) {
      return "assets/health_history.png";
    } else if (support) {
      return "assets/support.png";
    } else if (setting) {
      return "assets/setting.png";
    }
    return "assets/health_history.png";
  }

  bool getProfileVisibility() {
    if (profile) {
      return true;
    } else if (health_history) {
      return true;
    } else if (support) {
      return false;
    } else if (setting) {
      return true;
    }
    return true;
  }

  Future<dynamic> profileDetailsFetch() async {
    var response = await http.get(
      Uri.parse('${MedScribeBackenAPI().baseURL}/patient/$patientCode'),
      headers: {
        'authorization': 'token $authToken',
      },
    );
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (drawerOpen) {
          _animationController.reverse();
          _animationController2.reverse();
          setState(() {
            drawerOpen = false;
          });
          return false;
        }
        return false;
      },
      child: Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            Column(children: [
              FutureBuilder(
                  future: profileDetailsFetch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        var responseJson = jsonDecode(snapshot.data.body);
                        DateTime birthDate = DateTime.parse(
                            responseJson['result'][0]['birth_date']);
                        DateTime currentDate = DateTime.now();
                        int age = currentDate.year - birthDate.year;
                        return MedScribe_Widgets.main_screen_appbar(
                          context: context,
                          itemImagePath: getAppBarTitleImagePath(),
                          profileImagePath: responseJson['result'][0]
                              ['profile_picture'],
                          titleText: getAppBarTitleText(),
                          patientAge: age.toString(),
                          patientName: responseJson['result'][0]
                              ['patient_name'],
                          lastVisitDate: "12th May 2021",
                          showProfile: getProfileVisibility(),
                        );
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                    }
                    return MedScribe_Widgets.main_screen_appbar_shimmer(
                        context: context);
                  }),
              Expanded(
                child: (PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    HealthHistoryScreen(
                      patientCode: patientCode!,
                      authToken: authToken!,
                    ),
                    FutureBuilder(
                        future: profileDetailsFetch(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              var responseJson = jsonDecode(snapshot.data.body);
                              DateTime dateTime = DateTime.parse(
                                  responseJson['result'][0]['birth_date']);
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(dateTime);

                              return MedicalProfile(
                                fatherName: responseJson['result'][0]
                                    ['father_name'],
                                gender: responseJson['result'][0]['gender'],
                                dob: formattedDate,
                                bloodGroup: responseJson['result'][0]
                                    ['blood_group'],
                                maritalStatus: responseJson['result'][0]
                                    ['marital_status'],
                                height: responseJson['result'][0]
                                    ['patient_height'],
                                weight: responseJson['result'][0]
                                    ['patient_weight'],
                                bp: responseJson['result'][0]['bloodpressure'],
                                pulse: responseJson['result'][0]['pulse']
                                    .toString(),
                              );
                            }
                          }
                          return MedScribe_Shimmers.profileScreenShimmer(
                              context: context);
                        }),
                    ContactScreen(),
                    SettingScreen(
                      action: () {
                        _animationController2.reverse();
                        setState(() {
                          drawerOpen = true;
                        });
                        _animationController.forward();
                      },
                      action2: () {
                        _animationController.reverse();
                        setState(() {
                          drawerOpen = true;
                        });
                        _animationController2.forward();
                      },
                    )
                  ],
                )),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.20,
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).size.width * 0.10,
                      ),
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            margin: EdgeInsets.only(
                              left: MediaQuery.of(context).size.width * 0.03,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(seconds: 1),
                                  child: GestureDetector(
                                    key: Key(health_history.toString()),
                                    onTap: () {
                                      setState(() {
                                        health_history = true;
                                        profile = false;
                                        support = false;
                                        setting = false;
                                        transcribe = false;
                                      });
                                      _pageController.animateToPage(
                                        0,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: MedScribe_Widgets.navigation_item(
                                      context: context,
                                      active: health_history,
                                      imagePath: "assets/menu-item1.png",
                                      text: "Health\nHistory",
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: Duration(seconds: 1),
                                  child: GestureDetector(
                                    key: Key(profile.toString()),
                                    onTap: () {
                                      setState(() {
                                        health_history = false;
                                        profile = true;
                                        support = false;
                                        setting = false;
                                        transcribe = false;
                                      });
                                      _pageController.animateToPage(
                                        1,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: MedScribe_Widgets.navigation_item(
                                      context: context,
                                      active: profile,
                                      imagePath: "assets/menu-item2.png",
                                      text: "Profile",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 0.4,
                            margin: EdgeInsets.only(
                              right: MediaQuery.of(context).size.width * 0.03,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                AnimatedSwitcher(
                                  duration: Duration(seconds: 1),
                                  child: GestureDetector(
                                    key: Key(support.toString()),
                                    onTap: () {
                                      setState(() {
                                        health_history = false;
                                        profile = false;
                                        support = true;
                                        setting = false;
                                        transcribe = false;
                                      });
                                      _pageController.animateToPage(
                                        2,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: MedScribe_Widgets.navigation_item(
                                      context: context,
                                      active: support,
                                      imagePath: "assets/menu-item4.png",
                                      text: "Support",
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: Duration(seconds: 1),
                                  child: GestureDetector(
                                    key: Key(setting.toString()),
                                    onTap: () {
                                      setState(() {
                                        health_history = false;
                                        profile = false;
                                        support = false;
                                        setting = true;
                                        transcribe = false;
                                      });
                                      _pageController.animateToPage(
                                        3,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: MedScribe_Widgets.navigation_item(
                                      context: context,
                                      active: setting,
                                      imagePath: "assets/menu-item5.png",
                                      text: "Settings",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: MediaQuery.of(context).size.width * 0.41,
                      bottom: MediaQuery.of(context).size.height * 0.10,
                      child: GestureDetector(
                        onTap: () {},
                        key: Key(transcribe.toString()),
                        child: AnimatedSwitcher(
                          duration: Duration(seconds: 2),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            height: MediaQuery.of(context).size.height * 0.085,
                            decoration: BoxDecoration(
                              color: MedScribe_Theme.grey.withOpacity(0.66),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: FittedBox(
                              child: Image.asset(
                                "assets/menu-item3.png",
                                width: MediaQuery.of(context).size.width * 0.01,
                                height:
                                    MediaQuery.of(context).size.height * 0.01,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
            if (drawerOpen)
              IgnorePointer(
                child: Container(
                  color: Color(0xFF000000).withOpacity(0.4),
                ),
              ),
            Positioned(
              bottom: 0,
              child: MedScribe_Widgets.drawerContainer(
                  context: context,
                  animationController: _animationController,
                  dragabbleTitle: "Who are we?",
                  onDrawerChanged: (value) {
                    setState(() {
                      drawerOpen = value;
                    });
                  },
                  aboutUsText:
                      "We're Masood, Waqar, and Aneeq 🙌, final-year software engineering students passionate about healthcare innovation. With our expertise in generative AI, mobile app dev, cloud computing and UI design, we're crafting an Electronic Health Record (EHR) app that revolutionizes healthcare.📱\nOur app offers AI-generated SOAP notes 📝, diagnostic report interpretation 📃, and pocket-sized patient history records, replacing cumbersome files with seamless digital solutions. By combining our skills and vision, we're empowering healthcare providers to deliver superior care efficiently and effectively. \n Join us on our journey to transform healthcare for a brighter future 🚀."),
            ),
            Positioned(
              bottom: 0,
              child: FutureBuilder(
                  future: profileDetailsFetch(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (snapshot.hasData) {
                        var responseJson = jsonDecode(snapshot.data.body);
                        return MedScribe_Widgets.drawerContainer2(
                          context: context,
                          animationController: _animationController2,
                          dragabbleTitle: "Patient Code",
                          description:
                              "Scan this QR code or enter the above code to access the patient’s medical history",
                          qrURL: responseJson['result'][0]['patient_code'],
                          onDrawerChanged: (value) {
                            setState(() {
                              drawerOpen = value;
                            });
                          },
                        );
                      }
                    }
                    return Container();
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
