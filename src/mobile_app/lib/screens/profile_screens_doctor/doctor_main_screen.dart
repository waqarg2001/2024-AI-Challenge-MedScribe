import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:medscribe_app/screens/patient_health_history_screen.dart';
import 'package:medscribe_app/screens/profile_screens_doctor/access_record_screen.dart';
import 'package:medscribe_app/screens/profile_screens_doctor/doctor_profile_screen.dart';
import 'package:medscribe_app/screens/profile_screens_doctor/settings_screen.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/shimmers.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:medscribe_app/screens/contact_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart' as dio;
import 'package:http/http.dart' as http;

class DoctorMainScreen extends StatefulWidget {
  const DoctorMainScreen({super.key});

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  late AnimationController _animationController;
  late AnimationController _aboutusanimationController;

  String? doctorCode = Get.parameters['profileCode'];

  String? authToken;

  bool access_record = true,
      profile = false,
      support = false,
      setting = false,
      transcribe = false;

  String getAppBarTitleText() {
    if (profile) {
      return "Profile";
    } else if (access_record) {
      return "Access\nRecord";
    } else if (support) {
      return "Support";
    } else if (setting) {
      return "Settings";
    }
    return "Edit Profile";
  }

  String getAppBarTitleImagePath() {
    if (profile) {
      return "assets/doctor_profile.png";
    } else if (access_record) {
      return "assets/access_record.png";
    } else if (support) {
      return "assets/support.png";
    } else if (setting) {
      return "assets/setting.png";
    }
    return "assets/access_record.png";
  }

  bool getProfileVisibility() {
    if (profile) {
      return true;
    } else if (access_record && patientData) {
      return true;
    } else if (access_record) {
      return false;
    } else if (support) {
      return false;
    } else if (setting) {
      return true;
    }
    return true;
  }

  bool drawerOpen = false;
  String? patientCode;
  bool recordConversation = false;

  bool patientData = false, doctorData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTokens();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _aboutusanimationController = AnimationController(
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

  Future<dynamic> profileDetailsFetch() async {
    try {
      dio.Dio dioClient = dio.Dio();
      var response = await dioClient.get(
        '${MedScribeBackenAPI().baseURL}/doctor/$doctorCode',
        options: dio.Options(
          headers: {
            'authorization': 'token $authToken',
          },
        ),
      );
      return response;
    } catch (e) {
      if (e is dio.DioError) {
        // Handle the Dio error here
        print('Dio error occurred: ${e.message}');
      } else {
        // Handle other errors here
        print('Error occurred: $e');
      }
      return null;
    }
  }

  Future<dynamic> patientprofileDetailsFetch() async {
    Dio dio = Dio();
    try {
      var future1 = dio.get(
        '${MedScribeBackenAPI().baseURL}/patient/$patientCode',
        options: Options(headers: {
          'authorization': 'token $authToken',
        }),
      );

      var future2 = dio.get(
        '${MedScribeBackenAPI().baseURL}/visitHistory/$patientCode',
        options: Options(headers: {
          'authorization': 'token $authToken',
        }),
      );

      var results = await Future.wait([future1, future2]);

      var response1Data = results[0].data;
      var response2Data = results[1].data;

      var combinedData = {
        'patientData': response1Data,
        'visitHistory': response2Data,
      };

      return combinedData;
    } catch (e) {
      print('Request error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              // Title Widget Doctor
              !patientData
                  ? FutureBuilder(
                      future: profileDetailsFetch(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            var responseJson = snapshot.data;

                            return MedScribe_Widgets.doctor_main_screen_appbar(
                              context: context,
                              itemImagePath: getAppBarTitleImagePath(),
                              profileImagePath: responseJson
                                  .data['doctorResult'][0]['profile_picture'],
                              titleText: getAppBarTitleText(),
                              DoctorName: responseJson.data['doctorResult'][0]
                                  ['doctor_name'],
                              DoctorSpeciality:
                                  responseJson.data['doctorResult'][0]
                                          ['area_of_experties'] ??
                                      "General Expertise",
                              showProfile: getProfileVisibility(),
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                        }
                        return MedScribe_Widgets.main_screen_appbar_shimmer(
                            context: context,
                            showProfile: getProfileVisibility());
                      })
                  : FutureBuilder(
                      future: patientprofileDetailsFetch(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          if (snapshot.hasData) {
                            var responseJson = snapshot.data;
                            String visitDateStr = responseJson['visitHistory']
                                ['result'][0]['visit_date'];
                            DateTime visitDate = DateTime.parse(visitDateStr);

                            String dayWithSuffix(int day) {
                              if (!(day >= 1 && day <= 31)) {
                                throw Exception('Invalid day of month');
                              }

                              if (day >= 11 && day <= 13) {
                                return '${day}th';
                              }

                              switch (day % 10) {
                                case 1:
                                  return '${day}st';
                                case 2:
                                  return '${day}nd';
                                case 3:
                                  return '${day}rd';
                                default:
                                  return '${day}th';
                              }
                            }

                            String formattedVisitDate =
                                '${dayWithSuffix(visitDate.day)} ${DateFormat('MMMM yyyy').format(visitDate)}';
                            DateTime birthDate = DateTime.parse(
                                responseJson['patientData']['result'][0]
                                    ['birth_date']);
                            DateTime currentDate = DateTime.now();
                            int age = currentDate.year - birthDate.year;
                            return MedScribe_Widgets.main_screen_appbar(
                              context: context,
                              itemImagePath: "assets/health_history.png",
                              profileImagePath: responseJson['patientData']
                                  ['result'][0]['profile_picture'],
                              titleText: "Health History",
                              patientAge: age.toString(),
                              patientName: responseJson['patientData']['result']
                                  [0]['patient_name'],
                              lastVisitDate: formattedVisitDate,
                              showProfile: true,
                            );
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                        }
                        return MedScribe_Widgets.main_screen_appbar_shimmer(
                            context: context);
                      }),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    patientCode == null
                        ? AccessRecordScreen(
                            onQRButtonPressed: () {
                              _animationController.reverse();

                              setState(() {
                                drawerOpen = true;
                              });
                            },
                            onCodeButtonPressed: () {
                              setState(() {
                                drawerOpen = true;
                              });
                              _animationController.forward();
                            },
                          )
                        : PatientHealthHistory(
                            patientCode: patientCode!,
                            doctorCode: doctorCode!,
                            authToken: authToken!,
                          ),
                    FutureBuilder(
                        future: profileDetailsFetch(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasData) {
                              var responseJson = snapshot.data;
                              DateTime dateTime = DateTime.parse(responseJson
                                  .data['doctorResult'][0]['birth_date']);
                              String formattedDate =
                                  DateFormat('dd/MM/yyyy').format(dateTime);

                              return DocterProfileScreen(
                                gender: responseJson.data['doctorResult'][0]
                                    ['gender'],
                                birth_date: formattedDate,
                                cnic: responseJson.data['doctorResult'][0]
                                    ['doctorDetails'][0]['cnic'],
                                email: responseJson.data['doctorResult'][0]
                                    ['doctorDetails'][0]['email'],
                                phone: responseJson.data['doctorResult'][0]
                                    ['doctorDetails'][0]['phone'],
                                city: responseJson.data['doctorResult'][0]
                                    ['city_of_practice'],
                                hospital: responseJson.data['doctorResult'][0]
                                    ['place_of_practice'],
                              );
                            }
                          }
                          return MedScribe_Shimmers.profileScreenShimmer(
                              context: context);
                        }),
                    ContactScreen(),
                    DoctorSettings(action: () {
                      setState(() {
                        drawerOpen = true;
                      });
                      _aboutusanimationController.forward();
                    }),
                  ],
                ),
              ),

              // Bottom Navigation Bar
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
                                    key: Key(access_record.toString()),
                                    onTap: () {
                                      setState(() {
                                        access_record = true;
                                        profile = false;
                                        support = false;
                                        setting = false;
                                        transcribe = false;
                                        if (patientCode != null) {
                                          patientData = true;
                                        }
                                      });
                                      _pageController.animateToPage(
                                        0,
                                        duration: Duration(milliseconds: 400),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                    child: MedScribe_Widgets.navigation_item(
                                      context: context,
                                      active: access_record,
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
                                        access_record = false;
                                        profile = true;
                                        support = false;
                                        setting = false;
                                        transcribe = false;
                                        if (patientCode != null) {
                                          patientData = false;
                                        }
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
                                        access_record = false;
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
                                        access_record = false;
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
                        onTap: () {
                          if (recordConversation) {
                            Get.toNamed('/record_conversation_screen',
                                parameters: {
                                  'doctorCode': doctorCode!,
                                  'patientCode': patientCode!,
                                  'authToken': authToken!,
                                });
                          } else {}
                        },
                        key: Key(transcribe.toString()),
                        child: AnimatedSwitcher(
                          duration: Duration(seconds: 2),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.18,
                            height: MediaQuery.of(context).size.height * 0.085,
                            decoration: BoxDecoration(
                              color: !recordConversation
                                  ? MedScribe_Theme.grey.withOpacity(0.66)
                                  : MedScribe_Theme.secondary_color,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: FittedBox(
                              child: !recordConversation
                                  ? Image.asset(
                                      "assets/menu-item3.png",
                                      width: MediaQuery.of(context).size.width *
                                          0.01,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.01,
                                      fit: BoxFit.contain,
                                    )
                                  : Image.asset(
                                      "assets/menu-item6.png",
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.04,
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (drawerOpen)
            IgnorePointer(
              child: Container(
                color: Color(0xFF000000).withOpacity(0.4),
              ),
            ),
          Positioned(
            bottom: 0,
            child: MedScribe_Widgets.doctordrawerContainer(
              proceed: (value) {
                setState(() {
                  patientCode = value;
                  drawerOpen = false;
                  patientData = true;
                  recordConversation = true;
                });
                _animationController.reverse();
              },
              controller: TextEditingController(),
              context: context,
              animationController: _animationController,
              dragabbleTitle: "Enter Code",
              onDrawerChanged: (value) {
                setState(() {
                  drawerOpen = value;
                });
              },
            ),
          ),
          Positioned(
            bottom: 0,
            child: MedScribe_Widgets.drawerContainer(
                context: context,
                animationController: _aboutusanimationController,
                dragabbleTitle: "Who are we?",
                onDrawerChanged: (value) {
                  setState(() {
                    drawerOpen = value;
                  });
                },
                aboutUsText:
                    "We're Masood, Waqar, and Aneeq 🙌, final-year software engineering students passionate about healthcare innovation. With our expertise in generative AI, mobile app dev, cloud computing and UI design, we're crafting an Electronic Health Record (EHR) app that revolutionizes healthcare.📱\nOur app offers AI-generated SOAP notes 📝, diagnostic report interpretation 📃, and pocket-sized patient history records, replacing cumbersome files with seamless digital solutions. By combining our skills and vision, we're empowering healthcare providers to deliver superior care efficiently and effectively. \n Join us on our journey to transform healthcare for a brighter future 🚀."),
          ),
        ],
      ),
    );
  }
}
