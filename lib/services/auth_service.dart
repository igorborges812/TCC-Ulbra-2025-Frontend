import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://tcc-ulbra-2025-backend.onrender.com/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

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

      final accessToken = response.data['access'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', accessToken);

      // Atualiza o header global do Dio com o token para chamadas futuras
      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      return accessToken;
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
