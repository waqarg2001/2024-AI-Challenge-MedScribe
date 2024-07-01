import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/screens/profile_screens_patient/patient_main_screen.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:http/http.dart' as http;

class TranscribeScreen extends StatefulWidget {
  const TranscribeScreen({super.key});

  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool recording = false;
  double recordingPosition = 0.0;

  late Map<String, dynamic> arguments;
  late dynamic record;
  late String authToken;
  late String patientCode;
  

  bool subjectiveExpanded = true,
      objectiveExpanded = false,
      assessmentExpanded = false,
      planExpanded = false;

  double subjectivePosition = 0.0,
      objectivePosition = 0.0,
      assessmentPosition = 0.0,
      planPosition = 0.0,
      reportsPosition = 0.0;

  late AnimationController _subjectivecontroller,
      _objectivecontroller,
      _assessmentcontroller,
      _plancontroller;

  late Future<dynamic> profileDetailsFuture;

  String subjective = "", objective = "", assessment = "", plan = "";

  @override
  void initState() {
    super.initState();
    arguments = Get.arguments;
    record = arguments['record'];
    authToken = arguments['authToken'];
    patientCode = arguments['patientCode'];
    generateSoapReport();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _subjectivecontroller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _objectivecontroller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _assessmentcontroller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _plancontroller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    profileDetailsFuture = profileDetailsFetch(); // Initialize the Future here
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

  void generateSoapReport() async {
    try {
      String report = record['notes_id']['result'][0]['soap'] ?? "";

      String subjective = "";
      String objective = "";
      String assessment = "";
      String plan = "";

      if (report.contains("Subjective:")) {
        subjective = report.split("Subjective:")[1].split("Objective:")[0];
      }

      if (report.contains("Objective:")) {
        objective = report.split("Objective:")[1].split("Assessment:")[0];
      }

      if (report.contains("Assessment:")) {
        assessment = report.split("Assessment:")[1].split("Plan:")[0];
      }

      if (report.contains("Plan:")) {
        plan = report.split("Plan:")[1];
        if (plan.contains("Subjective:")) {
          plan = plan.split("Subjective:")[0];
        }
        if (plan.contains("Objective:")) {
          plan = plan.split("Objective:")[0];
        }
        if (plan.contains("Assessment:")) {
          plan = plan.split("Assessment:")[0];
        }
      }

      setState(() {
        this.subjective = subjective.trim();
        this.objective = objective.trim();
        this.assessment = assessment.trim();
        this.plan = plan.trim();
      });

      setState(() {
        // soapGenerated = true;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          FutureBuilder(
              future: profileDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasData) {
                    var responseJson = jsonDecode(snapshot.data.body);
                    DateTime birthDate =
                        DateTime.parse(responseJson['result'][0]['birth_date']);
                    DateTime currentDate = DateTime.now();
                    int age = currentDate.year - birthDate.year;
                    return MedScribe_Widgets.main_screen_appbar(
                      context: context,
                      itemImagePath: "assets/health_history.png",
                      profileImagePath: responseJson['result'][0]
                          ['profile_picture'],
                      titleText: "Transcriptions",
                      patientAge: age.toString(),
                      patientName: responseJson['result'][0]['patient_name'],
                      lastVisitDate: "12th May 2021",
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
              child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                  ),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MedScribe_Widgets.transcribe_buttons(
                        onTap: () {
                          setState(() {
                            recording = !recording;
                            recordingPosition = 0.50;
                          });
                        },
                        controller: _controller,
                        context: context,
                        buttonIconPath: "assets/audio-wave.png",
                        buttonText: "Recording",
                        active: recording,
                        initialPosition: recordingPosition,
                        AnimatedContainer: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          duration: Duration(seconds: 1),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: recording
                              ? MediaQuery.of(context).size.height * 0.30
                              : 0.0,
                          decoration: BoxDecoration(
                            color: MedScribe_Theme.white,
                            border: Border.all(
                              color: MedScribe_Theme.secondary_color,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              record['notes_id']['result'][0]
                                      ['transcription'] ??
                                  "No transcription available",
                              style: GoogleFonts.inter(
                                color: Color(0xff777779),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MedScribe_Widgets.transcribe_buttons(
                        onTap: () {
                          setState(() {
                            subjectiveExpanded = !subjectiveExpanded;
                            subjectivePosition = 0.50;
                          });
                        },
                        controller: _subjectivecontroller,
                        context: context,
                        buttonIconPath: "assets/subjective-icon.png",
                        buttonText: "Subjective",
                        active: subjectiveExpanded,
                        initialPosition: subjectivePosition,
                        AnimatedContainer: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          duration: Duration(seconds: 1),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: subjectiveExpanded
                              ? MediaQuery.of(context).size.height * 0.30
                              : 0.0,
                          decoration: BoxDecoration(
                            color: MedScribe_Theme.white,
                            border: Border.all(
                              color: MedScribe_Theme.secondary_color,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              subjective,
                              style: GoogleFonts.inter(
                                color: Color(0xff777779),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MedScribe_Widgets.transcribe_buttons(
                        onTap: () {
                          setState(() {
                            objectiveExpanded = !objectiveExpanded;
                            objectivePosition = 0.50;
                          });
                        },
                        controller: _objectivecontroller,
                        context: context,
                        buttonIconPath: "assets/objective-icon.png",
                        buttonText: "Objective",
                        active: objectiveExpanded,
                        initialPosition: objectivePosition,
                        AnimatedContainer: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          duration: Duration(seconds: 1),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: objectiveExpanded
                              ? MediaQuery.of(context).size.height * 0.30
                              : 0.0,
                          decoration: BoxDecoration(
                            color: MedScribe_Theme.white,
                            border: Border.all(
                              color: MedScribe_Theme.secondary_color,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              objective,
                              style: GoogleFonts.inter(
                                color: Color(0xff777779),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MedScribe_Widgets.transcribe_buttons(
                        onTap: () {
                          setState(() {
                            assessmentExpanded = !assessmentExpanded;
                            assessmentPosition = 0.50;
                          });
                        },
                        controller: _assessmentcontroller,
                        context: context,
                        buttonIconPath: "assets/assessment-icon.png",
                        buttonText: "Assessment",
                        active: assessmentExpanded,
                        initialPosition: assessmentPosition,
                        AnimatedContainer: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          duration: Duration(seconds: 1),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: assessmentExpanded
                              ? MediaQuery.of(context).size.height * 0.30
                              : 0.0,
                          decoration: BoxDecoration(
                            color: MedScribe_Theme.white,
                            border: Border.all(
                              color: MedScribe_Theme.secondary_color,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              assessment,
                              style: GoogleFonts.inter(
                                color: Color(0xff777779),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.02,
                      ),
                      MedScribe_Widgets.transcribe_buttons(
                        onTap: () {
                          setState(() {
                            planExpanded = !planExpanded;
                            planPosition = 0.50;
                          });
                        },
                        controller: _plancontroller,
                        context: context,
                        buttonIconPath: "assets/plan-icon.png",
                        buttonText: "Plan",
                        active: planExpanded,
                        initialPosition: planPosition,
                        AnimatedContainer: AnimatedContainer(
                          padding: EdgeInsets.symmetric(
                            horizontal:
                                MediaQuery.of(context).size.width * 0.02,
                            vertical: MediaQuery.of(context).size.width * 0.02,
                          ),
                          duration: Duration(seconds: 1),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: planExpanded
                              ? MediaQuery.of(context).size.height * 0.30
                              : 0.0,
                          decoration: BoxDecoration(
                            color: MedScribe_Theme.white,
                            border: Border.all(
                              color: MedScribe_Theme.secondary_color,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              plan,
                              style: GoogleFonts.inter(
                                color: Color(0xff777779),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ))),
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
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.4,
                        margin: EdgeInsets.only(
                          left: MediaQuery.of(context).size.width * 0.03,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/patient_main_screen', parameters: {
                                  'initialPage': "0",
                                  'profileCode': patientCode,
                                  'authToken': authToken,
                                });
                              },
                              child: MedScribe_Widgets.navigation_item(
                                context: context,
                                active: true,
                                imagePath: "assets/menu-item1.png",
                                text: "Health\nHistory",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/patient_main_screen', parameters: {
                                  'initialPage': "1",
                                  'profileCode': patientCode,
                                  'authToken': authToken,
                                });
                              },
                              child: MedScribe_Widgets.navigation_item(
                                context: context,
                                active: false,
                                imagePath: "assets/menu-item2.png",
                                text: "Profile",
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
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/patient_main_screen', parameters: {
                                  'initialPage': "2",
                                  'profileCode': patientCode,
                                  'authToken': authToken,
                                });
                              },
                              child: MedScribe_Widgets.navigation_item(
                                context: context,
                                active: false,
                                imagePath: "assets/menu-item4.png",
                                text: "Support",
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed('/patient_main_screen', parameters: {
                                  'initialPage': "3",
                                  'profileCode': patientCode,
                                  'authToken': authToken,
                                });
                              },
                              child: MedScribe_Widgets.navigation_item(
                                context: context,
                                active: false,
                                imagePath: "assets/menu-item5.png",
                                text: "Settings",
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
                      Get.back();
                    },
                    child: Container(
                      padding: EdgeInsets.all(7.0),
                      width: MediaQuery.of(context).size.width * 0.18,
                      height: MediaQuery.of(context).size.height * 0.085,
                      decoration: BoxDecoration(
                        color: MedScribe_Theme.secondary_color,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Image.asset(
                        "assets/transcribe-backarrow.png",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
