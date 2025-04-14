import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api'));

  Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await _dio.post('/users/login/', data: {
        'email': email,
        'password': password,
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response.data['access']);
      return response.data['access'];
    } catch (e) {
      print('Erro no login: $e');
      return null;
    }
  }

  Future<bool> register(String email, String password, String nickname) async {
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
