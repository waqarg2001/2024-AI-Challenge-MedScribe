import 'package:biometric_fingerprint/biometric_fingerprint.dart';
import 'package:biometric_fingerprint/biometric_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'package:medscribe_app/utils/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool phoneselected = false, bioselected = true;
  TextEditingController cnic_controller = TextEditingController();
  TextEditingController phone_controller = TextEditingController();

  bool authentication = false;
  String _key = "";
  String _platformVersion = 'Unknown';
  String fingerprintIcon = "assets/faceid_icon.jpg";
  Color _fingerprintcolor = Colors.white;
  String? deviceToken;

  final _biometricFingerprintPlugin = BiometricFingerprint();

  final String? acc_type = Get.parameters['acc_type'];

  Future<void> initPlatformState() async {
    String platformVersion;

    try {
      platformVersion =
          await _biometricFingerprintPlugin.getPlatformVersion() ??
              'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  void finger_print_authentication() async {
    BiometricResult result =
        await _biometricFingerprintPlugin.initAuthentication(
      biometricKey:
          'medscribe_key_aneeq_masood_waqar_zindabad_asim_muneer_meri_jind_meri_jaan',
      message:
          'This message is a secret generated for medscribe fingerprint authentication. Asim Muneer Meri Jind Meri Jaan',
      title: 'Confirm Using Your Fingerprint',
      subtitle: 'You can use your fingerprint to confirm login to the account.',
      description: '',
      negativeButtonText: 'CANCEL',
      confirmationRequired: true,
    );
    print(result.data);
    if (kDebugMode) {
      print(result.isSuccess);
    } // success
    if (kDebugMode) {
      print(result.isCanceled);
    } // cancel
    if (kDebugMode) {
      print(result.isFailed);
    } // failed

    if (result.isSuccess && result.hasData) {
      final key = result.data!;
      setState(() {
        authentication = true;
        _key = key;
        fingerprintIcon = "assets/faceid_icon.jpg";
        _fingerprintcolor = Colors.black;
      });
      Get.snackbar(
        "Success",
        "Fingerprint Authentication Successful",
        snackPosition: SnackPosition.values[0],
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Future.delayed(Duration(seconds: 2), () {
        // Get.toNamed('/main_screen');
      });
      return;
    }

    if (result.isFailed) {
      Get.snackbar(
        "Error",
        "Fingerprint Authentication Failed",
        snackPosition: SnackPosition.values[0],
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      setState(() {
        _key = result.errorMsg;
        authentication = false;
        fingerprintIcon = "assets/fingerprint-error.png";
        _fingerprintcolor = Color(0xFFD70000);
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDeviceToken();
  }

  void getDeviceToken() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      deviceToken = prefs.getString('fcmToken');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: const EdgeInsets.all(15.0),
      width: double.infinity,
      height: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(top: 30.0, left: 20.0),
              alignment: Alignment.centerLeft,
              child: RichText(
                  text: TextSpan(
                text: 'Login Account \n',
                style: GoogleFonts.inter(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                children: [
                  TextSpan(
                    text: 'Hello, welcome back to your account. ',
                    style: GoogleFonts.inter(
                      color: Color(0xFF595959),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )),
            ),
            Container(
              margin: EdgeInsets.only(
                top: MediaQuery.of(context).size.height * 0.07,
                bottom: MediaQuery.of(context).size.height * 0.10,
              ),
              width: MediaQuery.of(context).size.width * 0.85,
              height: MediaQuery.of(context).size.height * 0.07,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                color: Color(0xFFEDEDED),
              ),
              child: Row(
                children: [
                  MedScribe_Widgets.login_Switcher(
                    context: context,
                    text: 'Biometric',
                    selected: bioselected,
                    fontSize: 14,
                    onTap: () {
                      setState(() {
                        phoneselected = !phoneselected;
                        bioselected = !bioselected;
                      });
                    },
                  ),
                  MedScribe_Widgets.login_Switcher(
                    context: context,
                    text: 'Phone Number',
                    selected: phoneselected,
                    fontSize: 14,
                    onTap: () {
                      setState(() {
                        phoneselected = !phoneselected;
                        bioselected = !bioselected;
                      });
                    },
                  ),
                ],
              ),
            ),
            bioselected
                ? Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: Column(
                      children: [
                        MedScribe_Widgets.text_field(
                          prefixIconWidth: 35,
                          keyboardType: TextInputType.text,
                          controller: cnic_controller,
                          hintText: "CNIC",
                          prefixIconPath: "assets/card.png",
                        ),
                        MedScribe_Widgets.underline(),
                        Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.05,
                            bottom: MediaQuery.of(context).size.height * 0.25,
                          ),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                MedScribe_Widgets.login_button(
                                  active: false,
                                  buttonColor: MedScribe_Theme.secondary_color,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  text: 'Login',
                                  textColor: Colors.white,
                                  width:
                                      MediaQuery.of(context).size.width * 0.60,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // FingerPrint Function calls here
                                    finger_print_authentication();
                                  },
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.15,
                                    height: MediaQuery.of(context).size.height *
                                        0.07,
                                    child: Image.asset(
                                      fingerprintIcon,

                                    ),
                                  ),
                                ),
                              ]),
                        ),
                        MedScribe_Widgets.or_text_widget(context: context),
                        Container(
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.05,
                          ),
                          child: Row(children: [
                            Text(
                              "Not Registered yet? ",
                              style: GoogleFonts.inter(
                                color: Color(0xFF979797),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Register Page
                                acc_type == 'Patient'
                                    ? Get.toNamed('/patient_registeration')
                                    : Get.toNamed('/doc_registeration');
                              },
                              child: Text(
                                "Create an Account",
                                style: GoogleFonts.inter(
                                  color: MedScribe_Theme.secondary_color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  )
                : Container(
                    margin: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.05,
                      right: MediaQuery.of(context).size.width * 0.05,
                    ),
                    child: Column(
                      children: [
                        MedScribe_Widgets.text_field(
                          prefixIconWidth: 35,
                          keyboardType: TextInputType.phone,
                          controller: phone_controller,
                          hintText: "Phone Number",
                          prefixIconPath: "assets/pak_flag.png",
                        ),
                        MedScribe_Widgets.underline(),
                        Container(
                          margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.08,
                          ),
                          child: GestureDetector(
                            onTap: () {
                              String phoneNumber = phone_controller.text;

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
                                'accType': acc_type ?? '',
                              });
                            },
                            child: MedScribe_Widgets.login_button(
                              active: false,
                              buttonColor: MedScribe_Theme.secondary_color,
                              height: MediaQuery.of(context).size.height * 0.07,
                              text: 'Request OTP',
                              textColor: Colors.white,
                              width: MediaQuery.of(context).size.width * 0.95,
                            ),
                          ),
                        ),
                        Container(
                            margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.05,
                              bottom: MediaQuery.of(context).size.height * 0.05,
                            ),
                            child: MedScribe_Widgets.or_text_widget(
                                context: context)),
                        MedScribe_Widgets.google_button(
                          height: MediaQuery.of(context).size.height * 0.07,
                          width: MediaQuery.of(context).size.width * 0.95,
                          text1: "Login with Google",
                          backColor: Colors.white,
                          radius: 10.0,
                          shadow: true,
                          iconPath: "assets/google-icon.png",
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: MediaQuery.of(context).size.width * 0.05,
                            right: MediaQuery.of(context).size.width * 0.05,
                            top: MediaQuery.of(context).size.height * 0.05,
                          ),
                          child: Row(children: [
                            Text(
                              "Not Registered yet? ",
                              style: GoogleFonts.inter(
                                color: Color(0xFF979797),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // Navigate to Register Page
                                Get.toNamed('/register');
                              },
                              child: Text(
                                "Create an Account",
                                style: GoogleFonts.inter(
                                  color: MedScribe_Theme.secondary_color,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    ),
                  )
          ],
        ),
      ),
    ));
  }
}
