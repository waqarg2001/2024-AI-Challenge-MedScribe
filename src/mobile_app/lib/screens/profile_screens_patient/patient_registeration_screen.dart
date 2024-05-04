import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medscribe_app/screens/profile_screens_patient/weight_scale_widget.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;

class PatientRegisterationScreen extends StatefulWidget {
  const PatientRegisterationScreen({super.key});

  @override
  State<PatientRegisterationScreen> createState() =>
      _PatientRegisterationScreenState();
}

class _PatientRegisterationScreenState extends State<PatientRegisterationScreen>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final ValueNotifier<double> _progress;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController fathernameController = TextEditingController();
  final TextEditingController cnicController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pulseController = TextEditingController();
  final TextEditingController bmiController = TextEditingController();

  late AnimationController _controller;

  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 1000);
  final FixedExtentScrollController _dayController =
      FixedExtentScrollController(initialItem: 1000);
  final FixedExtentScrollController _yearController =
      FixedExtentScrollController(initialItem: 2100 - 1960);

  int selectedMonth = 0;
  int selectedDay = 1;
  int selectedYear = 2000;
  DateTime now = DateTime.now();

  String button_text = "Continue";

  String? gender = "Male", maritalStatus = "Single";
  bool male = true, female = false, single = true, married = false;

  var bloodGroup = {
    "A+": false,
    "A-": false,
    "B+": false,
    "B-": false,
    "AB+": true,
    "AB-": false,
    "O+": false,
    "O-": false,
  };

  bool A = false, B = false, AB = true, O = false;
  bool plus = true, minus = false;

  double _heightInCm = 0.0;
  double _weightInKg = 0.0;
  double _linearProgressHeight = 0.0;
  double _verticalOffset = 0;
  int feet = 5;
  double inches = 7;

  XFile? nic_image, profile_image;
  String? deviceToken;
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> upload_nic_image(String capture_type) async {
    XFile? pickedImage;
    setState(() {
      _isLoading = true;
    });
    if (capture_type == 'camera') {
      pickedImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (pickedImage != null) {
        setState(() {
          _isLoading = false;
          nic_image = pickedImage;
        });
        return;
      }
    } else if (capture_type == 'gallery') {
      pickedImage = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          _isLoading = false;
          nic_image = pickedImage;
        });
        return;
      }
    }
  }

  Future<void> upload_profile_image(String type) async {
    XFile? _profileImage;
    setState(() {
      _isLoading = true;
    });
    if (type == 'camera') {
      _profileImage = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 100,
      );
      if (_profileImage != null) {
        setState(() {
          _isLoading = false;
          profile_image = _profileImage;
        });
        return;
      }
    }

    if (type == 'gallery') {
      _profileImage = await _picker.pickImage(source: ImageSource.gallery);
      if (_profileImage != null) {
        setState(() {
          _isLoading = false;
          profile_image = _profileImage;
        });
        return;
      }
    }
  }

  void register_patient() async {
    try {
      setState(() {
        _isLoading = true;
      });
      String phoneNumber = phoneController.text.trim();

      if (phoneNumber.startsWith('0')) {
        phoneNumber = '+92' + phoneNumber.substring(1);
      } else if (!phoneNumber.startsWith('+92')) {
        phoneNumber = '+92' + phoneNumber;
      }
      phoneController.text = phoneNumber;
      dio.FormData formData = dio.FormData.fromMap({
        "cnic": cnicController.text.replaceAll('-', ''),
        "phone": phoneController.text,
        "email": emailController.text,
        "cnic_image": await dio.MultipartFile.fromFile(nic_image!.path),
      });

      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/register/patient",
        data: formData,
      );
      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        var responseBody = response.data;
        var patientCode = responseBody['result'][0]['patient_code'].toString();
        var phNumber = responseBody['result'][0]['phone'].toString();
        await prefs.setString('patient', patientCode);
        create_profile(patientCode, phNumber);
      } else {
        Get.snackbar(
          "Error",
          "An error occurred while registering the patient",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[500]!,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white, size: 30),
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
        );
      }
    } catch (e) {
      print('Error: $e');
      if (e is dio.DioError) {
        print('Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
        print('Request: ${e.requestOptions}');
        Get.snackbar(
          "Error",
          "An error occurred while registering the patient",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[500]!,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white, size: 30),
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void create_profile(profile_code, phNumber) async {
    try {
      dio.FormData formData = dio.FormData.fromMap({
        "patientCode": profile_code,
        "patientName": nameController.text,
        "fatherName": fathernameController.text,
        "gender": gender!,
        "dateOfBirth": "$selectedYear-$selectedMonth-$selectedDay",
        "bloodGroup":
            bloodGroup.entries.firstWhere((entry) => entry.value == true).key,
        "maritalStatus": maritalStatus!,
        "height": _heightInCm.toDouble().toStringAsFixed(1),
        "weight": _weightInKg,
        "bmi": bmiController.text != "" ? bmiController.text : 0.0,
        "bloodpressure": bpController.text,
        "pulse": double.tryParse(pulseController.text) ?? 0,
        "profile_pic": await dio.MultipartFile.fromFile(profile_image!.path),
      });
      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/patient",
        data: formData,
      );
      print(response.data);

      if (response.statusCode == 201) {
        var responseBody = response.data;
        var patientProfileCode =
            responseBody['result'][0]['patient_profile_code'].toString();

        print("Profile created successfully ${response.data}");
        setState(() {
          _isLoading = false;
        });
        Get.snackbar(
          "Success",
          "Your Profile has been created successfully",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          icon: Icon(
            Icons.check,
            color: Colors.white,
          ),
          duration: Duration(seconds: 2),
        );

        String phoneNumber = phNumber;

        if (phoneNumber.startsWith('0')) {
          phoneNumber = '+92' + phoneNumber.substring(1);
        } else if (phoneNumber.startsWith('92')) {
          phoneNumber = '+' + phoneNumber;
        } else if (!phoneNumber.startsWith('+92')) {
          phoneNumber = '+92' + phoneNumber;
        }

        // Request OTP Function calls here
        Get.toNamed('/otp_verify', parameters: {
          'phoneNum': phoneNumber,
          'deviceToken': deviceToken!,
          'accType': 'Patient',
        });
      }
    } catch (e) {
      print('Error: $e');
      if (e is dio.DioError) {
        print('Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
        print('Request: ${e.requestOptions}');
        Get.snackbar(
          "Error",
          "An error occurred while creating the patient profile",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red[500]!,
          colorText: Colors.white,
          icon: Icon(Icons.error, color: Colors.white, size: 30),
          margin: EdgeInsets.symmetric(
            vertical: MediaQuery.of(context).size.height * 0.02,
            horizontal: MediaQuery.of(context).size.width * 0.05,
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void getDeviceToken() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceToken = prefs.getString('fcmToken');
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceToken();
    _pageController = PageController();
    _progress = ValueNotifier<double>(0);
    _pageController.addListener(_updateProgress);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateProgress);
    _pageController.dispose();
    _progress.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (_pageController.page != null) {
      _progress.value = _pageController.page! / (15 - 1);
    } else {
      _progress.value = 0;
    }
  }

  int getDaysInMonth(int month, int year) {
    return month == 2
        ? (year % 4 == 0 ? 29 : 28)
        : (month < 8
            ? month % 2 == 1
                ? 31
                : 30
            : month % 2 == 0
                ? 31
                : 30);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.symmetric(
                      vertical: MediaQuery.of(context).size.height * 0.03,
                      horizontal: MediaQuery.of(context).size.height * 0.01,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (_pageController.page != 0) {
                          _pageController.previousPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                          setState(() {
                            button_text = "Continue";
                          });
                        } else {
                          Get.back();
                        }
                      },
                      child: Image.asset(
                        "assets/back_button.png",
                        scale: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.height * 0.02,
                        vertical: MediaQuery.of(context).size.height * 0.02),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (context, child) {
                        return LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 10,
                          backgroundColor: Color(0xFFEFECEC),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            MedScribe_Theme.secondary_color,
                          ),
                          borderRadius: BorderRadius.circular(100),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title: "Hi 👋\nWhat is your name?"),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTextField(
                                  hintText: "Full Name",
                                  controller: nameController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title: "What is your father's name?"),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTextField(
                                  hintText: "Father's Name",
                                  controller: fathernameController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title: "What is your gender?"),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.1,
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                child: GestureDetector(
                                  key: ValueKey(male),
                                  onTap: () {
                                    setState(() {
                                      male = true;
                                      female = false;
                                      gender = "Male";
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.width *
                                        0.40,
                                    decoration: BoxDecoration(
                                      color: male
                                          ? MedScribe_Theme.secondary_color
                                          : MedScribe_Theme.white,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: MedScribe_Theme.secondary_color,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Male",
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w600,
                                              color: male
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Expanded(
                                              child: Image.asset(
                                            "assets/male.png",
                                            scale: 2.0,
                                            color: male
                                                ? Colors.white
                                                : Colors.black,
                                          ))
                                        ]),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.1,
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                child: GestureDetector(
                                  key: ValueKey(female),
                                  onTap: () {
                                    setState(() {
                                      male = false;
                                      female = true;
                                      gender = "Female";
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.width *
                                        0.40,
                                    decoration: BoxDecoration(
                                      color: female
                                          ? MedScribe_Theme.secondary_color
                                          : MedScribe_Theme.white,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: MedScribe_Theme.secondary_color,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Female",
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w600,
                                              color: female
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Expanded(
                                              child: Image.asset(
                                            "assets/female.png",
                                            scale: 2.0,
                                            color: female
                                                ? Colors.white
                                                : Colors.black,
                                          ))
                                        ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              MedScribe_Widgets.doctorRegisterationTitleText(
                                  title: "When is your birthday ? 🎂"),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.026,
                                ),
                                child: Text(
                                  "You must be at least 25 years old to register.",
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFADA9A9),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                    height: MediaQuery.of(context).size.width *
                                        0.75,
                                    width: MediaQuery.of(context).size.width *
                                        0.28,
                                    child: ListWheelScrollView.useDelegate(
                                      controller: _scrollController,
                                      useMagnifier: true,
                                      magnification: 1.4,
                                      diameterRatio: 2.5,
                                      itemExtent: 48,
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          selectedMonth = index % 12;
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildLoopingListDelegate(
                                        children: <String>[
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr',
                                          'May',
                                          'Jun',
                                          'Jul',
                                          'Aug',
                                          'Sep',
                                          'Oct',
                                          'Nov',
                                          'Dec'
                                        ].asMap().entries.map<Widget>((entry) {
                                          int index = entry.key;
                                          String value = entry.value;
                                          return Text(
                                            value,
                                            style: GoogleFonts.inter(
                                              color: index == selectedMonth
                                                  ? Colors.black
                                                  : Color(
                                                      0xFFADA9A9), // Change the color based on the selected index
                                              fontSize: 30,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                    height: MediaQuery.of(context).size.width *
                                        0.75,
                                    width: MediaQuery.of(context).size.width *
                                        0.20,
                                    child: ListWheelScrollView.useDelegate(
                                      controller: _dayController,
                                      useMagnifier: true,
                                      magnification: 1.4,
                                      diameterRatio: 2.5,
                                      itemExtent: 50,
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          selectedDay = index %
                                                  getDaysInMonth(selectedMonth,
                                                      selectedYear) +
                                              1;
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildLoopingListDelegate(
                                        children:
                                            List<int>.generate(31, (i) => i + 1)
                                                .map<Widget>((int value) {
                                          return Text(
                                            value.toString(),
                                            style: GoogleFonts.inter(
                                              color: value == selectedDay
                                                  ? Colors.black
                                                  : Color(0xFFADA9A9),
                                              fontSize: 30,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                      top: MediaQuery.of(context).size.width *
                                          0.1,
                                    ),
                                    height: MediaQuery.of(context).size.width *
                                        0.75,
                                    width: MediaQuery.of(context).size.width *
                                        0.33,
                                    child: ListWheelScrollView.useDelegate(
                                      controller: _yearController,
                                      useMagnifier: true,
                                      magnification: 1.4,
                                      diameterRatio: 2.5,
                                      itemExtent: 50,
                                      onSelectedItemChanged: (index) {
                                        setState(() {
                                          selectedYear = 1980 + index;
                                        });
                                      },
                                      childDelegate:
                                          ListWheelChildLoopingListDelegate(
                                        children: List<int>.generate(
                                                2100 - 1980 + 1,
                                                (i) => 1980 + i)
                                            .map<Widget>((int value) {
                                          return Text(
                                            value.toString(),
                                            style: GoogleFonts.inter(
                                              color: value == selectedYear
                                                  ? Colors.black
                                                  : Color(0xFFADA9A9),
                                              fontSize: 30,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title: "Are you married?"),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.1,
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                child: GestureDetector(
                                  key: ValueKey(single),
                                  onTap: () {
                                    setState(() {
                                      single = true;
                                      married = false;
                                      maritalStatus = "Single";
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.width *
                                        0.40,
                                    decoration: BoxDecoration(
                                      color: single
                                          ? MedScribe_Theme.secondary_color
                                          : MedScribe_Theme.white,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: MedScribe_Theme.secondary_color,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Single",
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w600,
                                              color: single
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Expanded(
                                              child: Image.asset(
                                            "assets/single.png",
                                            scale: 2.0,
                                            color: single
                                                ? Colors.white
                                                : Colors.black,
                                          ))
                                        ]),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: MediaQuery.of(context).size.width * 0.1,
                              ),
                              AnimatedSwitcher(
                                duration: Duration(milliseconds: 500),
                                child: GestureDetector(
                                  key: ValueKey(married),
                                  onTap: () {
                                    setState(() {
                                      single = false;
                                      married = true;
                                      maritalStatus = "Married";
                                    });
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.6,
                                    height: MediaQuery.of(context).size.width *
                                        0.40,
                                    decoration: BoxDecoration(
                                      color: married
                                          ? MedScribe_Theme.secondary_color
                                          : MedScribe_Theme.white,
                                      borderRadius: BorderRadius.circular(32),
                                      border: Border.all(
                                        color: MedScribe_Theme.secondary_color,
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Married",
                                            style: GoogleFonts.inter(
                                              fontSize: 36,
                                              fontWeight: FontWeight.w600,
                                              color: married
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          Expanded(
                                              child: Image.asset(
                                            "assets/married.png",
                                            scale: 2.0,
                                            color: married
                                                ? Colors.white
                                                : Colors.black,
                                          ))
                                        ]),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title: "What is your CNIC?"),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTextField(
                                  hintText: "12345-6789012-1",
                                  controller: cnicController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleTextWithIcon(
                                        title: "Can we have your email please?",
                                        imagePath: "assets/email-emoji.png"),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTextField(
                                  hintText: "Email",
                                  controller: emailController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                  title: "What is your blood group? 🩸",
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: Text(
                                  "Select your blood group  from the groups and also determine whether it is positive or negative.",
                                  style: GoogleFonts.inter(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFADA9A9),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        MedScribe_Widgets.blood_group_tile(
                                          type: A,
                                          bloodGroup: "A",
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              A = true;
                                              B = false;
                                              AB = false;
                                              O = false;
                                            });
                                          },
                                        ),
                                        MedScribe_Widgets.blood_group_tile(
                                          type: AB,
                                          bloodGroup: "AB",
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              A = false;
                                              B = false;
                                              AB = true;
                                              O = false;
                                            });
                                          },
                                        ),
                                        MedScribe_Widgets.blood_group_tile(
                                          type: plus,
                                          bloodGroup: "+",
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              plus = true;
                                              minus = false;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        MedScribe_Widgets.blood_group_tile(
                                          type: B,
                                          bloodGroup: "B",
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              A = false;
                                              B = true;
                                              AB = false;
                                              O = false;
                                            });
                                          },
                                        ),
                                        MedScribe_Widgets.blood_group_tile(
                                          type: O,
                                          bloodGroup: "O",
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              A = false;
                                              B = false;
                                              AB = false;
                                              O = true;
                                            });
                                          },
                                        ),
                                        MedScribe_Widgets.blood_group_tile(
                                          type: minus,
                                          bloodGroup: "-",
                                          context: context,
                                          onTap: () {
                                            setState(() {
                                              plus = false;
                                              minus = true;
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              MedScribe_Widgets.doctorRegisterationTitleText(
                                title: "How tall are you?",
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: AnimatedBuilder(
                                  animation: _controller,
                                  builder: (context, child) {
                                    double totalFeet = _heightInCm / 30.48;
                                    int feet = totalFeet.floor();
                                    double decimalFeet = totalFeet - feet;
                                    double inches = decimalFeet * 12;
                                    return Text(
                                      "Height: $feet'${inches.round()}'' (${_heightInCm.toDouble().toStringAsFixed(0)} cm)",
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    top: MediaQuery.of(context).size.width *
                                        0.05,
                                    bottom: MediaQuery.of(context).size.width *
                                        0.05,
                                    left: MediaQuery.of(context).size.width *
                                        0.15,
                                    right:
                                        MediaQuery.of(context).size.width * 0.1,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Column(
                                        children: [
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Text(
                                            "7'0'' -",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.068),
                                          Text(
                                            "6'0'' -",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.075),
                                          Text(
                                            "5'0'' -",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.048),
                                          Text(
                                            "4'0'' -",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.067),
                                        ],
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onVerticalDragUpdate: (details) {
                                            setState(() {
                                              double newHeightInCm =
                                                  _heightInCm -
                                                      details.delta.dy;
                                              _heightInCm = newHeightInCm.clamp(
                                                  0.0, 213.0);

                                              // Calculate the height in feet and inches
                                              double totalFeet =
                                                  _heightInCm / 30.48;
                                              feet = totalFeet.floor();
                                              double decimalFeet =
                                                  totalFeet - feet;
                                              inches = decimalFeet * 12;

                                              double progressPercentage =
                                                  _heightInCm / 213;

                                              double segmentHeight =
                                                  MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.25;

                                              double linearProgressHeight =
                                                  progressPercentage *
                                                      segmentHeight *
                                                      4;

                                              _linearProgressHeight =
                                                  linearProgressHeight;
                                            });
                                          },
                                          child: Stack(
                                            children: [
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.4,
                                                decoration: BoxDecoration(
                                                  color: Color(0xFFEFECEC),
                                                  borderRadius:
                                                      BorderRadius.circular(25),
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 0,
                                                right: 0,
                                                left: 0,
                                                child: SizedBox(
                                                  height: _linearProgressHeight,
                                                  child: RotatedBox(
                                                    quarterTurns: 3,
                                                    child:
                                                        LinearProgressIndicator(
                                                      value: _heightInCm / 213,
                                                      minHeight: 25,
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      valueColor:
                                                          AlwaysStoppedAnimation<
                                                              Color>(
                                                        MedScribe_Theme
                                                            .secondary_color,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomLeft:
                                                            Radius.circular(25),
                                                        topLeft:
                                                            Radius.circular(25),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        children: [
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.01),
                                          Text(
                                            "- 213cm",
                                            style: GoogleFonts.inter(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.068),
                                          Text(
                                            "- 183cm",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.075),
                                          Text(
                                            "- 152cm",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                          MedScribe_Widgets.height_scale(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.048),
                                          Text(
                                            "- 122cm",
                                            style: GoogleFonts.inter(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFFADA9A9),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                  title: "How much do you weigh?",
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.width * 0.15,
                              ),
                              Expanded(
                                child: ScaleIndicator(
                                  onScrollChanged: (double result) {
                                    _weightInKg = result;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleTextWithCaption(
                                  title: "What is your latest BP reading?",
                                  caption: '(optional)',
                                ),
                              ),
                              MedScribe_Widgets.patientReadingWidgets(
                                context: context,
                                textHint: "120/90",
                                headerText: "mmHg",
                                controller: bpController,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleTextWithCaption(
                                  title: "What is your latest pulse rate?",
                                  caption: '(optional)',
                                ),
                              ),
                              MedScribe_Widgets.patientReadingWidgets(
                                context: context,
                                textHint: "90",
                                headerText: "BPM",
                                controller: pulseController,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                            horizontal:
                                MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            children: [
                              MedScribe_Widgets.doctorRegisterationTitleText(
                                  title: "What is your phone number? 📱"),
                              Text(
                                "Please enter a valid phone number. A 6-digit OTP will be sent to you for verification.",
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFADA9A9),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTextField(
                                  hintText: "Phone Number",
                                  controller: phoneController,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                              child: MedScribe_Widgets
                                  .doctorRegisterationTitleTextWithIcon(
                                title: "Upload a front photo of your NIC",
                                imagePath: "assets/cnic-emoji.png",
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                vertical:
                                    MediaQuery.of(context).size.width * 0.026,
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                              child: Text(
                                "Dont worry, your CNIC will only be used for verification purposes. It will stay safe and private.",
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFADA9A9),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                upload_nic_image('gallery');
                              },
                              child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  height:
                                      MediaQuery.of(context).size.width * 0.45,
                                  margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          "assets/photo_temp.png",
                                          scale: 2.0,
                                          color: Color(0xFF9E9E9E),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                upload_nic_image('camera');
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.height *
                                            0.02),
                                child: MedScribe_Widgets.google_button(
                                  backColor: MedScribe_Theme.secondary_color,
                                  iconPath: "assets/camera_icon.png",
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
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
                          ]),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(
                            vertical: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Column(
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title:
                                            "Upload a your profile picture 📸"),
                              ),
                              GestureDetector(
                                onTap: () {
                                  upload_profile_image('gallery');
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                    vertical:
                                        MediaQuery.of(context).size.width *
                                            0.026,
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.05,
                                  ),
                                  child: Image.asset(
                                    "assets/upload_photo.png",
                                    scale: 1.2,
                                  ),
                                ),
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
                                  upload_profile_image('camera');
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical:
                                          MediaQuery.of(context).size.height *
                                              0.02),
                                  child: MedScribe_Widgets.google_button(
                                    backColor: MedScribe_Theme.secondary_color,
                                    iconPath: "assets/camera_icon.png",
                                    width: MediaQuery.of(context).size.width *
                                        0.60,
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.width * 0.15,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (_pageController.page == 0 &&
                            nameController.text != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 1 &&
                            fathernameController.text != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 2 && gender != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 3 &&
                            ((now.year - selectedYear) >= 25)) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 4 &&
                            maritalStatus != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 5 &&
                            cnicController.text != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 6 &&
                            emailController.text != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 7) {
                          setState(() {
                            bloodGroup["A+"] = A && plus;
                            bloodGroup["A-"] = A && minus;
                            bloodGroup["B+"] = B && plus;
                            bloodGroup["B-"] = B && minus;
                            bloodGroup["AB+"] = AB && plus;
                            bloodGroup["AB-"] = AB && minus;
                            bloodGroup["O+"] = O && plus;
                            bloodGroup["O-"] = O && minus;
                          });
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 8 &&
                            _heightInCm != 0.0) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 9 &&
                            _weightInKg != 0.0) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 10) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 11) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 12 &&
                            phoneController.text != "") {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 13 &&
                            nic_image != null) {
                          setState(() {
                            button_text = "Complete";
                          });

                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 14 &&
                            profile_image != null) {
                          register_patient();
                        } else {
                          Get.snackbar(
                            "Info Missing",
                            "Please fill the fields to proceed",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.yellow[700]!,
                            colorText: Colors.white,
                            icon:
                                Icon(Icons.info, color: Colors.white, size: 30),
                            margin: EdgeInsets.symmetric(
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.05,
                            ),
                          );
                        }
                      },
                      child: MedScribe_Widgets.doctor_profile_button(
                        context: context,
                        width: MediaQuery.of(context).size.width * 0.8,
                        enable: false,
                        text: button_text,
                        iconPath: "assets/forward_icon.png",
                        height: MediaQuery.of(context).size.height * 0.06,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          if (_isLoading)
            IgnorePointer(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MedScribe_Theme.secondary_color,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
