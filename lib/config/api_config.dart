import 'package:flutter/foundation.dart';

class ApiConfig {
  static const String _environmentBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  static final String _defaultBaseUrl = kIsWeb
      ? 'http://localhost:3000'
      : 'http://10.0.2.2:3000';

  static final String baseUrl = _environmentBaseUrl.isNotEmpty
      ? _normalizeBaseUrl(_environmentBaseUrl)
      : _defaultBaseUrl;

  static String _normalizeBaseUrl(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
