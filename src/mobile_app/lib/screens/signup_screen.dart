import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _nameText_controller = TextEditingController();
  TextEditingController _genderText_controller = TextEditingController();
  TextEditingController _dobText_controller = TextEditingController();
  TextEditingController _cnicText_controller = TextEditingController();
  TextEditingController _ph_no_Text_controller = TextEditingController();
  TextEditingController _emailText_controller = TextEditingController();

  Duration _animationDuration = Duration(milliseconds: 500);

  String? acc_type = Get.parameters['acc_type'];
  final _firestore = FirebaseFirestore.instance;

  bool _isagreed = false;
  bool _enablebutton = false;

  void create_account() async {
    print("Creating account");
    final phoneRegex = RegExp(r'^\+?\d+$');
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (_nameText_controller.text.isEmpty) {
      _showError('Please enter your name');
    } else if (_genderText_controller.text.isEmpty) {
      _showError('Please enter your gender');
    } else if (_dobText_controller.text.isEmpty) {
      _showError('Please enter your date of birth');
    } else if (_cnicText_controller.text.isEmpty) {
      _showError('Please enter your CNIC');
    } else if (_ph_no_Text_controller.text.isEmpty) {
      _showError('Please enter your phone number');
    } else if (!phoneRegex.hasMatch(_ph_no_Text_controller.text)) {
      _showError('Phone number should only contain digits and country code');
    } else if (_emailText_controller.text.isEmpty) {
      _showError('Please enter your email');
    } else if (!emailRegex.hasMatch(_emailText_controller.text)) {
      _showError('Please enter a valid email');
    } else if (!_isagreed) {
      _showError('Please agree to the terms and conditions');
    } else {
      // send data to the backend
      final profile_type = acc_type == "Doctor" ? "doctor" : "patient";
      print("${MedScribeBackenAPI().baseURL}/register/$profile_type");
      final response = await http.post(
        Uri.parse("${MedScribeBackenAPI().baseURL}/register/$profile_type"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          "cnic": _cnicText_controller.text,
          "phone": _ph_no_Text_controller.text,
          "email": _emailText_controller.text,
          "fingerprint": "false",
        }),
      );
      if (response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        var responseBody = jsonDecode(response.body);

        if (profile_type == "doctor") {
          var doctorCode = responseBody['result'][0]['doctor_code'];
          await prefs.setString('doctor_code', doctorCode);
          create_profile(doctorCode);
        } else {
          var patientCode = responseBody['result'][0]['patient_code'];
          create_profile(patientCode);
          await prefs.setString('patient_code', patientCode);
        }
      }
    }
  }

  void create_profile(profile_code) async {
    final prefs = await SharedPreferences.getInstance();
    final profile_type = acc_type == "Doctor" ? "doctor" : "patient";
    var body = profile_type == "patient"
        ? jsonEncode(<String, dynamic>{
            "patientCode": profile_code,
            "patientName": _nameText_controller.text,
            "fatherName": "null",
            "gender": _genderText_controller.text,
            "dateOfBirth": _dobText_controller.text,
            "bloodGroup": "",
            "maritalStatus": "null",
            "height": 0.0,
            "weight": 0.0,
            "bmi": 0.0,
            "bloodpressure": "null",
            "pulse": 0,
            "profile_pic": "null"
          })
        : jsonEncode(<String, dynamic>{
            "doctorCode": profile_code,
            "doctorName": _nameText_controller.text,
            "gender": _genderText_controller.text,
            "birthDate": _dobText_controller.text,
            "profile_pic": "null"
          });
    final response = await http.post(
      Uri.parse("${MedScribeBackenAPI().baseURL}/$profile_type"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: body,
    );
    if (response.statusCode == 201) {
      print("Profile created successfully ${response.body}");

      setState(() {
        _nameText_controller.clear();
        _genderText_controller.clear();
        _dobText_controller.clear();
        _cnicText_controller.clear();
        _ph_no_Text_controller.clear();
        _emailText_controller.clear();
        _isagreed = false;
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
      // Navigate to the medical info screen.
    } else {
      print("Error creating profile ${response.body}");
    }
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width * 0.10,
            vertical: MediaQuery.of(context).size.height * 0.05,
          ),
          child: Column(
            children: [
              Container(
                alignment: Alignment.center,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.15,
                child: Image.asset(
                  acc_type == "Doctor"
                      ? "assets/doctor_logo.png"
                      : "assets/patient_logo.png",
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Column(
                  children: [
                    Text(
                      "Get Started",
                      style: TextStyle(
                        color: MedScribe_Theme.black,
                        fontWeight: FontWeight.w800,
                        fontSize: 36,
                      ),
                    ),
                    Text(
                      "by creating a free account",
                      style: TextStyle(
                        color: Color(0xFF252525),
                        fontSize: 10.0,
                        fontWeight: FontWeight.w300,
                      ),
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  MedScribe_Widgets.text_field(
                      prefixIconWidth: 31.5,
                      keyboardType: TextInputType.text,
                      controller: _nameText_controller,
                      hintText: "Full Name",
                      prefixIconPath: "assets/Name.png"),
                  MedScribe_Widgets.underline(),
                  MedScribe_Widgets.text_field(
                    prefixIconWidth: 32.0,
                    keyboardType: TextInputType.text,
                    controller: _genderText_controller,
                    hintText: "Gender",
                    prefixIconPath: "assets/gender.png",
                  ),
                  MedScribe_Widgets.underline(),
                  MedScribe_Widgets.calendar_field(
                    text: _dobText_controller.text.isEmpty
                        ? "Date of Birth"
                        : _dobText_controller.text,
                    iconPath: "assets/Calendar.png",
                    onTap: () {
                      showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      ).then((value) {
                        if (value != null) {
                          setState(() {
                            _dobText_controller.text =
                                DateFormat('dd-MM-yyyy').format(value);
                          });
                        }
                      });
                    },
                    context: context,
                  ),
                  MedScribe_Widgets.underline(),
                  MedScribe_Widgets.text_field(
                      prefixIconWidth: 35.0,
                      keyboardType: TextInputType.number,
                      controller: _cnicText_controller,
                      hintText: "CNIC",
                      prefixIconPath: "assets/card.png"),
                  MedScribe_Widgets.underline(),
                  MedScribe_Widgets.text_field(
                      prefixIconWidth: 35.0,
                      keyboardType: TextInputType.phone,
                      controller: _ph_no_Text_controller,
                      hintText: "Phone Number",
                      prefixIconPath: "assets/Phone.png"),
                  MedScribe_Widgets.underline(),
                  MedScribe_Widgets.text_field(
                      prefixIconWidth: 35.5,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailText_controller,
                      hintText: "Email",
                      prefixIconPath: "assets/email.png"),
                  MedScribe_Widgets.underline(),
                  Container(
                    margin:
                        EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: _animationDuration,
                          child: GestureDetector(
                            key: Key(_isagreed.toString()),
                            onTap: () {
                              setState(() {
                                _isagreed = !_isagreed;
                                _enablebutton = !_enablebutton;
                              });
                            },
                            child: MedScribe_Widgets.check_button(
                                ischecked: _isagreed),
                          ),
                        ),
                        Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: MedScribe_Widgets.conditions_text(),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: _animationDuration,
                    child: GestureDetector(
                      key: Key(_isagreed.toString()),
                      onTap: () {
                        if (_enablebutton) {
                          create_account();
                        }
                      },
                      child: MedScribe_Widgets.button_widget(
                        width: MediaQuery.of(context).size.width * 0.75,
                        enable: _enablebutton,
                        text: "Next",
                        iconPath: "assets/forward_icon.png",
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    child: MedScribe_Widgets.login_signup_Swicther(
                        text1: "Already a member?", text2: "Log In"),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: MedScribe_Widgets.underline(),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5.0),
                          child: Text(
                            "OR",
                            style: TextStyle(
                              fontSize: 10.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.35,
                          child: MedScribe_Widgets.underline(),
                        ),
                      ],
                    ),
                  ),
                  MedScribe_Widgets.google_button(
                    backColor: Colors.white,
                    radius: 10.0,
                    shadow: true,
                    iconPath: "assets/google-icon.png",
                    height: 40,
                    width: MediaQuery.of(context).size.width,
                    text1: "Signup with Google",
                  )
                ],
              )
            ],
          ),
        ),
      )),
    );
  }
}
