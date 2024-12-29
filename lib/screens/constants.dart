// constants.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb

const storage = FlutterSecureStorage();

class ApiConstants {
  static final String baseUrl = _getBaseUrl();

  static String _getBaseUrl() {
    if (kIsWeb) {
      return 'http://localhost:5001/api'; // for web
    } else {
      return 'http://192.168.0.121:5001/api'; //for mobile  http://192.168.10.86:5001/api
    }
  }
}
