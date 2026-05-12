import 'package:flutter/foundation.dart';

class ApiConfig {
  static final String baseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';
}
