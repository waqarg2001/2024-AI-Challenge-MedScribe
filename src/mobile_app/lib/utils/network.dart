import 'package:flutter_dotenv/flutter_dotenv.dart';

class MedScribeBackenAPI {
  String? VERSION = dotenv.env['VERSION'];
  String? baseURL;

  MedScribeBackenAPI() {
    baseURL = 'https://medscribe-container-app.proudgrass-a7a7df48.eastus.azurecontainerapps.io/api/$VERSION';
    // baseURL = 'https://4764-39-51-57-9.ngrok-free.app/api/$VERSION';
    
  }
}
