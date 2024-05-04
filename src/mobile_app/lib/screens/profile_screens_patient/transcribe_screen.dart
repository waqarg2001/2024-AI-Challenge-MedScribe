import 'package:flutter/material.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

class TranscribeScreen extends StatefulWidget {
  const TranscribeScreen({super.key});

  @override
  State<TranscribeScreen> createState() => _TranscribeScreenState();
}

class _TranscribeScreenState extends State<TranscribeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool recording = false;
  double recordingPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
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
          MedScribe_Widgets.main_screen_appbar(
            context: context,
            itemImagePath: "assets/health_history.png",
            profileImagePath: "assets/profile_pic.png",
            titleText: "Transcriptions",
            patientAge: "25",
            patientName: "Alex Sohail",
            lastVisitDate: "12th May 2021",
            showProfile: true,
          ),
          Expanded(
              child: Container(
                  child: Column(
            children: [
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
                      ))),
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
                              child: MedScribe_Widgets.navigation_item(
                                context: context,
                                active: true,
                                imagePath: "assets/menu-item1.png",
                                text: "Health\nHistory",
                              ),
                            ),
                            GestureDetector(
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
                              child: MedScribe_Widgets.navigation_item(
                                context: context,
                                active: false,
                                imagePath: "assets/menu-item4.png",
                                text: "Support",
                              ),
                            ),
                            GestureDetector(
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
                    onTap: () {},
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
