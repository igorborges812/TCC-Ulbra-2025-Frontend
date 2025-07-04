import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://tcc-ulbra-2025-backend.onrender.com/api',
      headers: {'Content-Type': 'application/json'},
    ),
  );

  final Dio _supabase = Dio(
    BaseOptions(
      baseUrl: 'https://sizovghaygzecxbgvqvb.supabase.co/auth/v1',
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNpem92Z2hheWd6ZWN4Ymd2cXZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDk2MDg2MTMsImV4cCI6MjA2NTE4NDYxM30.6etw0TwLyChIFDAIRWK0uhADrHNHn-qlYkFld9F5VVE',
        'Content-Type': 'application/json',
      },
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
      final response = await _supabase.post('/token?grant_type=password', data: {
        'email': email,
        'password': password,
      });

      final accessToken = response.data['access_token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', accessToken);

      _dio.options.headers['Authorization'] = 'Bearer $accessToken';

      return accessToken;
    } catch (e) {
      print('Erro no login Supabase REST: $e');
      return null;
    }
  }

  Future<bool> register(String nickname, String email, String password) async {
    try {
      await _supabase.post('/signup', data: {
        'email': email,
        'password': password,
        'data': {'nickname': nickname},
      });

      return true;
    } catch (e) {
      print('Erro ao registrar no Supabase REST: $e');
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _supabase.post('/recover', data: {'email': email});
      return true;
    } catch (e) {
      print('Erro ao enviar e-mail de recuperação: $e');
      return false;
    }
  }
}
