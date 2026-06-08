// lib/viewmodel/auth_viewmodel.dart (modificado)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/user.dart';
import '../services/api_client.dart';

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
      ApiClient().setToken(token);
    }
  }

  Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('user_data', jsonEncode(user.toJson()));
    _token = token;
    _currentUser = user;
    ApiClient().setToken(token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    _token = null;
    _currentUser = null;
    ApiClient().setToken('');
  }

  Future<bool> login(String email, String password) async {
    try {
      final response = await ApiClient().post('/auth/login-user', {
        'email': email,
        'password': password,
      });
      final token = response['token'];
      final user = User.fromJson(response['user']);
      await _saveAuthData(token, user);
      return true;
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
      final response = await ApiClient().post('/auth/register', body);
      final token = response['token'];
      final user = User.fromJson(response['user']);
      await _saveAuthData(token, user);
      return true;
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await ApiClient().post('/auth/forgot-password', {'email': email});
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await ApiClient().post('/auth/reset-password', {
        'email': email,
        'code': code,
        'newPassword': newPassword,
      });
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> deleteAccount() async {
    if (_currentUser == null) throw Exception('Usuário não logado');

    try {
      await ApiClient().delete('/users/${_currentUser!.id}');
      await logout();
    } catch (e) {
      String originalMsg = e.toString().replaceFirst('Exception: ', '');
      if (originalMsg.contains('future reservations') ||
          originalMsg.contains('You can\'t delete')) {
        throw Exception(
          'Não é possível excluir a conta pois você possui reservas futuras. Cancele-as primeiro.',
        );
      }
      rethrow;
    }
  }
}
