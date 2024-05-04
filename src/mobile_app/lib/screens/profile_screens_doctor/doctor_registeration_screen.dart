import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart' as dio;

class DocRegisteration extends StatefulWidget {
  const DocRegisteration({super.key});

  @override
  State<DocRegisteration> createState() => _DocRegisterationState();
}

class _DocRegisterationState extends State<DocRegisteration> {
  late final PageController _pageController;
  late final ValueNotifier<double> _progress;

  String? gender = "Male";
  String? city;

  final nameController = TextEditingController();
  final cnicController = TextEditingController();
  final emailController = TextEditingController();
  final hospitalNameController = TextEditingController();
  final regNumberController = TextEditingController();
  final phoneController = TextEditingController();

  final FixedExtentScrollController _scrollController =
      FixedExtentScrollController(initialItem: 1000);
  final FixedExtentScrollController _dayController =
      FixedExtentScrollController(initialItem: 1000);
  final FixedExtentScrollController _yearController =
      FixedExtentScrollController(initialItem: 2100 - 1980);

  int selectedMonth = 0;
  int selectedDay = 1;
  int selectedYear = 2001;
  DateTime now = DateTime.now();

  bool male = true, female = false;

  String button_text = "Continue";

  final ImagePicker _picker = ImagePicker();

  XFile? nic_image, profile_image;
  String? deviceToken;

  bool _isLoading = false;

  void getDeviceToken() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceToken = prefs.getString('fcmToken');
    });
  }

  @override
  void initState() {
    super.initState();
    getDeviceToken();
    _pageController = PageController();
    _progress = ValueNotifier<double>(0);
    _pageController.addListener(_updateProgress);
  }

  @override
  void dispose() {
    _pageController.removeListener(_updateProgress);
    _pageController.dispose();
    _progress.dispose();
    super.dispose();
  }

  void _updateProgress() {
    if (_pageController.page != null) {
      _progress.value = _pageController.page! / (11 - 1);
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

  void register_doctor() async {
    try {
      setState(() {
        _isLoading = true;
      });
      String phoneNumber = phoneController.text;

      if (phoneNumber.startsWith('0')) {
        phoneNumber = '+92' + phoneNumber.substring(1);
      } else if (phoneNumber.startsWith('92')) {
        phoneNumber = '+' + phoneNumber;
      } else if (!phoneNumber.startsWith('+92')) {
        phoneNumber = '+92' + phoneNumber;
      }
      dio.FormData formData = dio.FormData.fromMap({
        "cnic": cnicController.text.replaceAll('-', ''),
        "phone": phoneNumber,
        "email": emailController.text,
        "pmdc_number": regNumberController.text,
        "cnic_image": await dio.MultipartFile.fromFile(nic_image!.path),
      });
      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/register/doctor",
        data: formData,
      );

      print(response.data);

      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        var responseBody = response.data;
        var doctorCode = responseBody['result'][0]['doctor_code'].toString();
        var phNumber = responseBody['result'][0]['phone'].toString();
        await prefs.setString('doctor_code', doctorCode);
        create_profile(doctorCode, phNumber);
      }
    } catch (e) {
      print('Error: $e');
      if (e is dio.DioError) {
        print('Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
        print('Request: ${e.requestOptions}');
        Get.snackbar(
          "Error",
          "An error occurred while registering the dcotor",
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
        "doctorCode": profile_code,
        "doctorName": nameController.text,
        "gender": gender!,
        "birthDate": "$selectedYear-$selectedMonth-$selectedDay",
        "profile_picture":
            await dio.MultipartFile.fromFile(profile_image!.path),
        "city_of_practice": city!,
        "place_of_practice": hospitalNameController.text,
      });
      dio.Dio dioClient = dio.Dio();
      final response = await dioClient.post(
        "${MedScribeBackenAPI().baseURL}/doctor",
        data: formData,
      );
      print(response.data);

      if (response.statusCode == 201) {
        print("Profile created successfully ${response.data}");
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
        Get.toNamed('/otp_verify',
            parameters: {'phoneNum': phoneNumber, 'deviceToken': deviceToken!});
      }
    } catch (e) {
      print('Error: $e');
      if (e is dio.DioError) {
        print('Data: ${e.response?.data}');
        print('Headers: ${e.response?.headers}');
        print('Request: ${e.requestOptions}');
        Get.snackbar(
          "Error",
          "An error occurred while creating the doctor profile",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
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
                      )),
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
                                        title: "Hi Doc 👋\nWhat is your name?"),
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
                              vertical:
                                  MediaQuery.of(context).size.width * 0.05,
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
                                        MediaQuery.of(context).size.width *
                                            0.026,
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
                                      height:
                                          MediaQuery.of(context).size.width *
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
                                          ]
                                              .asMap()
                                              .entries
                                              .map<Widget>((entry) {
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
                                      height:
                                          MediaQuery.of(context).size.width *
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
                                                    getDaysInMonth(
                                                        selectedMonth,
                                                        selectedYear) +
                                                1;
                                          });
                                        },
                                        childDelegate:
                                            ListWheelChildLoopingListDelegate(
                                          children: List<int>.generate(
                                                  31, (i) => i + 1)
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
                                      height:
                                          MediaQuery.of(context).size.width *
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
                            )),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationTitleText(
                                        title:
                                            "Where do you currently practice? 🏥"),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  vertical:
                                      MediaQuery.of(context).size.width * 0.05,
                                  horizontal:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                child: MedScribe_Widgets
                                    .doctorRegisterationDropDown(
                                  hintText: "City",
                                  onChanged: (value) {
                                    setState(() {
                                      city = value;
                                    });
                                  },
                                  items: <String>[
                                    'Karachi',
                                    'Lahore',
                                    'Islamabad',
                                    'Peshawar',
                                    'Quetta',
                                    'Rawalpindi'
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
                          child: Column(children: [
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal:
                                    MediaQuery.of(context).size.width * 0.05,
                              ),
                              child: MedScribe_Widgets
                                  .doctorRegisterationTitleTextWithIcon(
                                      title: "The name of the hospital/clinic?",
                                      imagePath: "assets/hospital-emoji.png"),
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
                                hintText: "Name of the hospital/clinic",
                                controller: hospitalNameController,
                              ),
                            ),
                          ]),
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
                                  .doctorRegisterationTitleText(
                                title: "Your PMDC registration no? 📝",
                              ),
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
                                hintText: "PMDC registration number",
                                controller: regNumberController,
                              ),
                            ),
                          ]),
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
                      bottom: MediaQuery.of(context).size.width * 0.2,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        if (_pageController.page == 0 &&
                            nameController.text.isNotEmpty) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 1 &&
                            (male || female)) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 2 &&
                            ((now.year - selectedYear) >= 25)) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 3 &&
                            cnicController.text.isNotEmpty) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 4 &&
                            emailController.text.isNotEmpty) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 5 && city != null) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 6 &&
                            hospitalNameController.text.isNotEmpty) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 7 &&
                            regNumberController.text.isNotEmpty) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 8 &&
                            phoneController.text.isNotEmpty) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else if (_pageController.page == 9 &&
                            nic_image != null) {
                          _pageController.nextPage(
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );

                          setState(() {
                            button_text = "Complete";
                          });
                        } else if (_pageController.page == 10 &&
                            profile_image != null) {
                          register_doctor();
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
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            IgnorePointer(
              ignoring: false,
              child: Container(
                color: Colors.black.withOpacity(0.5),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
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
