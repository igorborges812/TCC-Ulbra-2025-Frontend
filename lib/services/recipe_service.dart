import 'package:dio/dio.dart';

class RecipeService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://cooktogether.duckdns.org'));

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await _dio.get('/recipes/seed/');
      return response.data;
    } catch (e) {
      print('Erro ao buscar receitas: $e');
      return [];
    }
  }
}