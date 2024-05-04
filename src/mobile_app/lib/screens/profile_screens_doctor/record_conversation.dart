import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medscribe_app/utils/audio_recorder.dart';
import 'package:medscribe_app/utils/medscribe_loader.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'dart:io';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:dio/dio.dart' as dio;
import 'package:path_provider/path_provider.dart';

class RecordConversation extends StatefulWidget {
  const RecordConversation({super.key});

  @override
  State<RecordConversation> createState() => _RecordConversationState();
}

class _RecordConversationState extends State<RecordConversation>
    with TickerProviderStateMixin {
  final String? patientCode = Get.parameters['patientCode'];
  final String? doctorCode = Get.parameters['doctorCode'];

  // SOAP format default values
  String subjective = "Not detected in the audio";
  String objective = "Not detected in the audio";
  String assessment = "Not detected in the audio";
  String plan = "Not detected in the audio";
  String report = "";
  String transcription = "";
  String reportdiagnosis = "";
  String? _audioPath;
  String? notesId, reportId;

  PageController _pageController = PageController();

  String? transcript;
  bool _isTranscribing = false;

  bool recording = true,
      converting = false,
      soapGenerated = false,
      sending = false,
      subjectiveExpanded = true,
      objectiveExpanded = false,
      assessmentExpanded = false,
      planExpanded = false,
      imageAnalysis = false,
      imageAnalysisProgress = false,
      imageAnalysisReview = false,
      reportsExpanded = true;

  double subjectivePosition = 0.0,
      objectivePosition = 0.0,
      assessmentPosition = 0.0,
      planPosition = 0.0,
      reportsPosition = 0.0;

  late AnimationController _subjectivecontroller,
      _objectivecontroller,
      _assessmentcontroller,
      _plancontroller,
      _reportscontroller;

  final ImagePicker _picker = ImagePicker();

  XFile? report_image;

  @override
  void initState() {
    print('Patient Code: $patientCode');
    print('Doctor Code: $doctorCode');
    super.initState();
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
    _reportscontroller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
  }

  String getAppBarTitleText() {
    if (recording) {
      return 'Record Conversation';
    } else if (converting) {
      return 'Conversion in progress';
    } else if (sending) {
      return 'Conversion Completed';
    } else if (imageAnalysis) {
      return 'Upload Reports';
    } else if (imageAnalysisProgress) {
      return 'Analyzing Report(s)';
    } else if (imageAnalysisReview) {
      return 'Review Report(s)';
    }
    return 'Record Conversation';
  }

  String getAppBarTitleImagePath() {
    if (recording) {
      return 'assets/record_conversation.png';
    } else if (converting) {
      return 'assets/conversion_progress.png';
    } else if (sending) {
      return 'assets/conversion_progress.png';
    } else if (imageAnalysis) {
      return 'assets/upload-report.png';
    } else if (imageAnalysisProgress) {
      return 'assets/analyze-report.png';
    } else if (imageAnalysisReview) {
      return 'assets/review_notes.png';
    }
    return 'assets/record_conversation.png';
  }

  void generateSoapReport() async {
    try {
      Map<String, dynamic> json = jsonDecode(transcript!);
      String transcriptText = json['results'][0]['transcript'];
      print('Transcript Text: $transcriptText');

      var dioInstance = dio.Dio();
      var formData = dio.FormData.fromMap({
        "transcribed_text": transcriptText,
      });

      var response = await dioInstance
          .post("${MedScribeBackenAPI().baseURL}/soap", data: formData);

      Map<String, dynamic> jsonResponse = response.data;
      String report = jsonResponse['Response'];

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
        this.report = report;
        transcription = transcriptText;
      });

      print('Response: $response');
      setState(() {
        soapGenerated = true;
      });
    } catch (e) {
      print('Error: $e');
    }
  }

  void sendAudioWithTranscriptionToDB() async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        "patientCode": patientCode,
        "audio_file": await dio.MultipartFile.fromFile(_audioPath!),
        "transcription": transcription,
        "soap": report
      });
      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/clinicalNotes",
        data: formData,
      );
      var jsonResponse = response.data;
      setState(() {
        notesId = jsonResponse['result'][0]['notes_id'];
      });
      print('Response: $response');
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> upload_report_image(String capture_type) async {
    XFile? pickedImage;
    if (capture_type == 'camera') {
      pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
    } else if (capture_type == 'gallery') {
      pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    }

    if (pickedImage != null) {
      String extension = path.extension(pickedImage.path);

      Directory appDocDir = await getApplicationDocumentsDirectory();

      File newImage = File(
          '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}$extension');

      await File(pickedImage.path).copy(newImage.path);

      setState(() {
        report_image = XFile(newImage.path);
      });
    }
  }

  void sendReportImage() async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        "image": await dio.MultipartFile.fromFile(report_image!.path),
      });
      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/llava",
        data: formData,
      );
      print('Response: $response');

      var jsonResponse = response.data;
      setState(() {
        reportdiagnosis = jsonResponse['Disease Analysis'];
        imageAnalysis = false;
        imageAnalysisProgress = false;
        imageAnalysisReview = true;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    } catch (e) {
      print('Error: $e');
    }
  }

  void createRecordforReportAnalysis() async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        "patientCode": patientCode,
        "image": await dio.MultipartFile.fromFile(report_image!.path),
        "generated_analysis": reportdiagnosis,
      });
      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/imageAnalysis",
        data: formData,
      );
      var jsonResponse = response.data;
      setState(() {
        reportId = jsonResponse['result'][0]['image_id'];
      });
      print('Response: $response');
      await createVisitHistoryRecord();
      setState(() {
        _isTranscribing = false;
      });
      FocusScope.of(context).unfocus();
      Get.back();
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> createVisitHistoryRecord() async {
    var dio = Dio();
    try {
      var response = await dio.post(
        "${MedScribeBackenAPI().baseURL}/visitHistory",
        data: {
          "patient_code": patientCode,
          "doctor_code": doctorCode,
          "notes_id": notesId,
          "image_id": reportId,
          "visit_date": DateTime.now().toIso8601String()
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      print('Response: $response');
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: NeverScrollableScrollPhysics(),
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MedScribe_Widgets.doctor_main_screen_appbar(
                    context: context,
                    itemImagePath: getAppBarTitleImagePath(),
                    titleText: getAppBarTitleText(),
                    showProfile: false,
                  ),
                  Image.asset(
                    'assets/microphone.png',
                    height: 250,
                    width: 250,
                  ),
                  AudioRecorder(
                    action: (response, isTranscribing, filePath) {
                      setState(() {
                        _isTranscribing = isTranscribing;
                        _audioPath = filePath;

                        // Handle the response here
                        transcript = response.toString();
                        print('Response from AudioRecorder: $response');
                        if (!isTranscribing) {
                          converting = true;
                          recording = false;
                          sending = false;
                          generateSoapReport();
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.ease,
                          );
                        }
                      });
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MedScribe_Widgets.doctor_main_screen_appbar(
                    context: context,
                    itemImagePath: getAppBarTitleImagePath(),
                    titleText: getAppBarTitleText(),
                    showProfile: false,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.1,
                    ),
                    child: RichText(
                      text: TextSpan(
                          text:
                              "The conversation is being converted to clinical SOAP format. It will take approx 2-3 minutes. .",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF777779),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.05,
                      ),
                      child: !soapGenerated
                          ? Center(
                              child:
                                  Lottie.asset('assets/medscribeloader.json'),
                            )
                          : Container(),
                    ),
                  ),
                  if (soapGenerated)
                    MedScribe_Widgets.transcriptionButton(
                      context: context,
                      text: 'Verify SOAP',
                      onTap: () {
                        setState(() {
                          recording = false;
                          converting = false;
                          imageAnalysis = false;
                          imageAnalysisProgress = false;
                          imageAnalysisReview = false;
                          sending = true;
                        });
                        sendAudioWithTranscriptionToDB();
                        _pageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.ease,
                        );
                      },
                    ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MedScribe_Widgets.doctor_main_screen_appbar(
                    context: context,
                    itemImagePath: getAppBarTitleImagePath(),
                    titleText: getAppBarTitleText(),
                    showProfile: false,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: RichText(
                      text: TextSpan(
                          text: "Review notes as needed.",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF777779),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              MediaQuery.of(context).size.height * 0.025,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: ListView(
                            shrinkWrap: true,
                            children: [
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
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                  ),
                                  duration: Duration(seconds: 1),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: subjectiveExpanded
                                      ? MediaQuery.of(context).size.height *
                                          0.30
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
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
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
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                  ),
                                  duration: Duration(seconds: 1),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: objectiveExpanded
                                      ? MediaQuery.of(context).size.height *
                                          0.30
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
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
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
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                  ),
                                  duration: Duration(seconds: 1),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: assessmentExpanded
                                      ? MediaQuery.of(context).size.height *
                                          0.30
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
                                height:
                                    MediaQuery.of(context).size.height * 0.02,
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
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.02,
                                  ),
                                  duration: Duration(seconds: 1),
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height: planExpanded
                                      ? MediaQuery.of(context).size.height *
                                          0.30
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
                          ),
                        )),
                  ),
                  MedScribe_Widgets.transcriptionButton(
                    context: context,
                    text: 'Upload Reports',
                    onTap: () {
                      setState(() {
                        recording = false;
                        converting = false;
                        sending = false;
                        imageAnalysis = true;
                        imageAnalysisProgress = false;
                        imageAnalysisReview = false;
                      });
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MedScribe_Widgets.doctor_main_screen_appbar(
                    context: context,
                    itemImagePath: getAppBarTitleImagePath(),
                    titleText: getAppBarTitleText(),
                    showProfile: false,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: RichText(
                      text: TextSpan(
                          text:
                              "Upload patient’s diagnostic report(s) for AI insights to be added with the patient’s record.",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF777779),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              upload_report_image('gallery');
                            },
                            child: Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                height:
                                    MediaQuery.of(context).size.width * 0.45,
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFFAFAFA),
                                  borderRadius: BorderRadius.circular(32),
                                  border: Border.all(
                                    color: MedScribe_Theme.secondary_color,
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        "assets/photo_temp.png",
                                        scale: 2.0,
                                        color: Color(0xFF9E9E9E),
                                      ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.05,
                                      ),
                                      Text(
                                        "Select file",
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                      ),
                                    ])),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "OR",
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              upload_report_image('camera');
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(
                                  vertical: MediaQuery.of(context).size.height *
                                      0.02),
                              child: MedScribe_Widgets.google_button(
                                backColor: MedScribe_Theme.secondary_color,
                                iconPath: "assets/camera_icon.png",
                                width: MediaQuery.of(context).size.width * 0.60,
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                                text1: "Take Photo",
                                radius: 50,
                                shadow: false,
                                iconHeight: 35,
                                iconWidth: 35,
                                textColor: Colors.white,
                                iconColor: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.width * 0.20,
                            ),
                            child: MedScribe_Widgets.report_button(
                              width: MediaQuery.of(context).size.width * 0.80,
                              height: MediaQuery.of(context).size.width * 0.10,
                              text: "Continue",
                              buttonColor: MedScribe_Theme.secondary_color,
                              active: report_image != null ? true : false,
                              textColor: Colors.white,
                              onTap: () {
                                setState(() {
                                  recording = false;
                                  converting = false;
                                  sending = false;
                                  imageAnalysis = false;
                                  imageAnalysisProgress = true;
                                  imageAnalysisReview = false;
                                });
                                sendReportImage();
                                _pageController.nextPage(
                                  duration: Duration(milliseconds: 500),
                                  curve: Curves.ease,
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MedScribe_Widgets.doctor_main_screen_appbar(
                    context: context,
                    itemImagePath: getAppBarTitleImagePath(),
                    titleText: getAppBarTitleText(),
                    showProfile: false,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: RichText(
                      text: TextSpan(
                          text:
                              "The report(s) are being analyzed by AI. Insights will be shared soon.",
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF777779),
                          )),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Lottie.asset('assets/medscribeloader.json'),
                    ),
                  )
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MedScribe_Widgets.doctor_main_screen_appbar(
                    context: context,
                    itemImagePath: getAppBarTitleImagePath(),
                    titleText: getAppBarTitleText(),
                    showProfile: false,
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                      bottom: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: RichText(
                      text: TextSpan(
                        text: "Please click 'Save' to confirm your changes.",
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF777779),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * 0.05,
                      ),
                      child: ListView(children: [
                        MedScribe_Widgets.transcribe_buttons(
                          onTap: () {
                            setState(() {
                              reportsExpanded = !reportsExpanded;
                              reportsPosition = 0.50;
                            });
                          },
                          controller: _reportscontroller,
                          context: context,
                          buttonIconPath: "assets/subjective-icon.png",
                          buttonText: "Reports Diagnosis",
                          active: reportsExpanded,
                          initialPosition: reportsPosition,
                          AnimatedContainer: AnimatedContainer(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.02,
                              vertical:
                                  MediaQuery.of(context).size.width * 0.02,
                            ),
                            duration: Duration(seconds: 1),
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: reportsExpanded
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
                                reportdiagnosis,
                                style: GoogleFonts.inter(
                                  color: Color(0xff777779),
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                  MedScribe_Widgets.transcriptionButton(
                    context: context,
                    text: 'Save',
                    onTap: () {
                      setState(() {
                        _isTranscribing = true;
                      });
                      createRecordforReportAnalysis();
                    },
                  ),
                ],
              )
            ],
          ),
          if (_isTranscribing)
            IgnorePointer(
              child: Container(
                color: Color(0xFF000000).withOpacity(0.4),
                child: Center(
                  child: CircularProgressIndicator(
                    color: MedScribe_Theme.secondary_color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
