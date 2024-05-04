import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/network.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  String? phoneNum = Get.parameters['phoneNum'];
  String? deviceToken = Get.parameters['deviceToken'];

  String? accType = Get.parameters['accType'];
  String? profileCode;

  final otpControllers = List.generate(6, (index) => TextEditingController());
  final otpFocusNodes = List.generate(6, (index) => FocusNode());
  bool _isVerified = true;
  bool _isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    generateOTP();
  }

  String getOTP() {
    String otp = '';
    otpControllers.forEach((controller) {
      otp += controller.text;
    });
    return otp;
  }

  void generateOTP() async {
    String profileType = accType == "Doctor" ? "doctor" : "patient";
    var response = await http.post(
      Uri.parse(
          '${MedScribeBackenAPI().baseURL}/notification/$profileType/sendOTP'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'deviceToken': deviceToken!,
        'phoneNumber': phoneNum!,
      }),
    );
    print(response.body);
    try {
      if (response.statusCode == 200) {
        var responseJson = jsonDecode(response.body);
        String? authToken = responseJson['response']['token'];
        print("Auth Token: $authToken");
        var prefs = await SharedPreferences.getInstance();
        prefs.setString('authToken', authToken!);
        setState(() {
          profileCode = responseJson['response']['profile_code'];
        });
        print("Profile Code: $profileCode");
      } else {
        print(response.body);
      }
    } catch (e) {
      print(e);
    }
  }

  void verifyOTP(String otp) async {
    setState(() {
      _isLoading = true;
    });
    var response = await http.post(
      Uri.parse('${MedScribeBackenAPI().baseURL}/notification/verifyOTP'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'deviceToken': deviceToken!,
        'otp': otp,
      }),
    );
    if (response.statusCode == 200) {
      setState(() {
        _isLoading = false;
        _isVerified = true;
      });
      Get.offAllNamed(
          accType == 'Patient' ? '/patient_main_screen' : '/doctor_main_screen',
          parameters: {
            'profileCode': profileCode!,
          });
    } else {
      setState(() {
        _isLoading = false;
        _isVerified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'OTP Verification',
          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8,
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Image.asset("assets/otp-verify.png"),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                      left: MediaQuery.of(context).size.width * 0.1,
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Enter OTP",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700,
                        fontSize: 25,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).size.height * 0.05,
                      left: MediaQuery.of(context).size.width * 0.1,
                    ),
                    alignment: Alignment.centerLeft,
                    child: RichText(
                        text: TextSpan(
                            style: GoogleFonts.inter(
                                color: Color(0xFF595959),
                                fontSize: 15,
                                fontWeight: FontWeight.w500),
                            text: "A 4 digit code has been sent to \n",
                            children: [
                          TextSpan(
                              text: "$phoneNum",
                              style: GoogleFonts.inter(
                                  color: MedScribe_Theme.secondary_color,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500)),
                        ])),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: otpControllers.asMap().entries.map((entry) {
                        int index = entry.key;
                        TextEditingController controller = entry.value;

                        return Container(
                          decoration: BoxDecoration(
                            color:
                                _isVerified ? Colors.white : Color(0xFFE5C0C0),
                            borderRadius: BorderRadius.circular(15.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 7,
                                offset:
                                    Offset(0, 3), // changes position of shadow
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.height * 0.06,
                          height: MediaQuery.of(context).size.height * 0.06,
                          child: TextField(
                            cursorColor: MedScribe_Theme.secondary_color,
                            textAlignVertical: TextAlignVertical.center,
                            controller: controller,
                            focusNode: otpFocusNodes[index],
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 16.0), // Add this line

                              counterText: "",
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15.0),
                                borderSide: BorderSide(
                                    color: MedScribe_Theme.secondary_color,
                                    width: 2.0),
                              ),
                              border: InputBorder.none,
                            ),
                            textAlign: TextAlign.center,
                            onChanged: (value) {
                              if (value.length == 1 &&
                                  index < otpControllers.length - 1) {
                                otpFocusNodes[index].unfocus();
                                FocusScope.of(context)
                                    .requestFocus(otpFocusNodes[index + 1]);
                              } else if (value.isEmpty && index > 0) {
                                otpFocusNodes[index].unfocus();
                                FocusScope.of(context)
                                    .requestFocus(otpFocusNodes[index - 1]);
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Container(
                  //     margin: EdgeInsets.only(
                  //       top: MediaQuery.of(context).size.height * 0.001,
                  //     ),
                  //     child: Text(
                  //       _isVerified
                  //           ? ""
                  //           : "Invalid or Incorrect OTP. Try Again",
                  //       style: GoogleFonts.inter(
                  //         color: Color(0xFFD70000),
                  //         fontSize: 12,
                  //         fontWeight: FontWeight.w600,
                  //       ),
                  //     )),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Verify OTP Function calls here
                        String otp = getOTP();
                        verifyOTP(otp);
                      },
                      child: MedScribe_Widgets.login_button(
                        active: false,
                        buttonColor: MedScribe_Theme.secondary_color,
                        height: MediaQuery.of(context).size.height * 0.07,
                        text: 'Verify',
                        textColor: Colors.white,
                        width: MediaQuery.of(context).size.width * 0.80,
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.02,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        // Resend the OTP Function calls here
                      },
                      child: MedScribe_Widgets.login_button(
                        active: true,
                        buttonColor: Colors.white,
                        height: MediaQuery.of(context).size.height * 0.07,
                        text: 'Resend OTP',
                        textColor: Colors.black,
                        width: MediaQuery.of(context).size.width * 0.80,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            IgnorePointer(
              child: Container(
                color: Color(0xFF00000066).withOpacity(0.4),
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.80,
                    height: MediaQuery.of(context).size.height * 0.40,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFFFFF),
                      borderRadius: BorderRadius.circular(17.0),
                    ),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("assets/checkmark.png"),
                          MedScribe_Widgets.login_button(
                            active: false,
                            buttonColor: MedScribe_Theme.secondary_color,
                            height: MediaQuery.of(context).size.height * 0.06,
                            text: 'Continue',
                            textColor: Colors.white,
                            width: MediaQuery.of(context).size.width * 0.60,
                          )
                        ]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
