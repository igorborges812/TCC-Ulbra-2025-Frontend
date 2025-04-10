// auth_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://github.com/CookTogetherTeam/backend-cook-together'));

  Future<bool> isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? token = prefs.getString('token');
  return token != null; // Retorna true se o token existir
}

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/login/', data: {'email': email, 'password': password});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['token']);
      return response.data['token'];
    } catch (e) {
      return null;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      await _dio.post('/auth/register/', data: {'email': email, 'password': password});
      return true;
    } catch (e) {
      return false;
    }
  }
}