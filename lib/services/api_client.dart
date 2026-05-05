import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  Future<dynamic> get(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.get(url, headers: await _getHeaders());
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, dynamic data) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.post(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, dynamic data) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.patch(
      url,
      headers: await _getHeaders(),
      body: jsonEncode(data),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final url = Uri.parse('${ApiConfig.baseUrl}$endpoint');
    final response = await http.delete(url, headers: await _getHeaders());
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return jsonDecode(response.body);
    } else {
      String errorMsg;
      try {
        final error = jsonDecode(response.body);
        errorMsg = error['error'] ?? 'Erro na requisição';
      } catch (_) {
        errorMsg = 'Erro ${response.statusCode}';
      }
      throw Exception(errorMsg);
    }
  }
}
