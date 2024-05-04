import 'package:flutter_dotenv/flutter_dotenv.dart';

class MedScribeBackenAPI {
  String? VERSION = dotenv.env['VERSION'];
  String? baseURL;

  MedScribeBackenAPI() {
    baseURL = 'http://34.92.82.192/api/$VERSION';
    // baseURL = 'https://94b4-39-51-53-49.ngrok-free.app/api/$VERSION';
  }
}
