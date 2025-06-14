import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'));

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login/', data: {
        'email': email,
        'password': password,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['access']);
      return response.data['access'];
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<bool> register(String nickname, String email, String password) async {
    try {
      await _dio.post('/users/register/', data: {
        'email': email,
        'password': password,
        'nickname': nickname,
      });
      return true;
    } catch (e) {
      print('Erro ao registrar: $e');
      return false;
    }
  }
}
