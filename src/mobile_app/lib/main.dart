import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:medscribe_app/utils/themes.dart';
import 'firebase_options.dart';
import 'package:medscribe_app/routes/get_routes.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

import 'utils/notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
  );
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
  );
  await dotenv.load(fileName: ".env");

  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  await FirebaseAPI().initNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MedScribe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: MedScribe_Theme.secondary_color,
          secondary: MedScribe_Theme.secondary_color,
        ),
        useMaterial3: true,
      ),
      initialRoute: '/',
      getPages: AppRoutes.routes,
    );
  }
}
