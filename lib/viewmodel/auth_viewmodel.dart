import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../model/user.dart';

class AuthViewModel {
  static final AuthViewModel _instance = AuthViewModel._internal();
  factory AuthViewModel() => _instance;
  static AuthViewModel get instance => _instance;
  AuthViewModel._internal() {
    _loadStoredData();
  }

  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _token != null && _currentUser != null;

  Future<void> _loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('user_data');
    if (token != null && userJson != null) {
      _token = token;
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    _token = token;
    _currentUser = user;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _token = null;
    _currentUser = null;
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login-user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);
        await _saveAuthData(token, user);
        return true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Erro ao fazer login');
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String birthDate,
    required String password,
  }) async {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');

    final body = {
      'name': name,
      'email': email,
      'phone': cleanPhone,
      'birth_date': birthDate,
      'password': password,
      'role': 'customer',
    };

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];
        final user = User.fromJson(data['user']);
        await _saveAuthData(token, user);
        return true;
      } else {
        String errorMsg;
        try {
          final error = jsonDecode(response.body);
          errorMsg = error['error'] ?? 'Erro ao criar conta';
        } catch (_) {
          errorMsg =
              'Servidor retornou resposta inválida. Status: ${response.statusCode}';
        }
        throw Exception(errorMsg);
      }
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}
