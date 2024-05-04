// routes.dart

import 'package:get/get.dart';
import 'package:medscribe_app/screens/acctype_screen.dart';
import 'package:medscribe_app/screens/onboarding_screens.dart';
import 'package:medscribe_app/screens/login_screen.dart';
import 'package:medscribe_app/screens/camera_screen/medscribe_camera_screen.dart';
import 'package:medscribe_app/screens/otp_verification_screen.dart';
import 'package:medscribe_app/screens/photo_screen.dart';
import 'package:medscribe_app/screens/profile_screens_doctor/doctor_main_screen.dart';
import 'package:medscribe_app/screens/profile_screens_doctor/doctor_registeration_screen.dart';
import 'package:medscribe_app/screens/profile_screens_doctor/record_conversation.dart';
import 'package:medscribe_app/screens/profile_screens_patient/patient_main_screen.dart';
import 'package:medscribe_app/screens/profile_screens_patient/patient_registeration_screen.dart';
import 'package:medscribe_app/screens/profile_screens_patient/transcribe_screen.dart';
import 'package:medscribe_app/screens/signup_screen.dart';
import 'package:medscribe_app/screens/splash_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/',
      page: () => SplashScreen(),
    ),
    GetPage(
      name: '/home',
      page: () => HomeScreen(),
    ),
    GetPage(
      name: '/login',
      page: () => LoginPage(),
    ),
    GetPage(
      name: '/register',
      page: () => SignupPage(),
    ),
    GetPage(
      name: '/otp_verify',
      page: () => OTPScreen(),
    ),
    GetPage(
      name: '/acc_type',
      page: () => AccountType(),
    ),
    GetPage(
      name: '/photo_screen',
      page: () => PhotoScreen(),
    ),
    GetPage(
      name: '/patient_main_screen',
      page: () => PatientMainScreen(),
    ),
    GetPage(
      name: '/transcribe_screen',
      page: () => TranscribeScreen(),
    ),
    GetPage(
      name: '/doc_registeration',
      page: () => DocRegisteration(),
    ),
    GetPage(
        name: '/patient_registeration',
        page: () => PatientRegisterationScreen()),
    GetPage(
      name: '/face_camera',
      page: () => MedScribeCameraScreen(),
    ),

    GetPage(
      name: '/doctor_main_screen',
      page: () => DoctorMainScreen(),
    ),
    // GetPage(name: '/face_detection', page: () => FaceDetection()),

    GetPage(
      name: '/record_conversation_screen',
      page: () => RecordConversation(),
    ),
  ];
}
