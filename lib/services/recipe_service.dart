import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecipeService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://tcc-ulbra-2025-backend.onrender.com/api',
      headers: {'Accept': 'application/json'},
    ),
  );

  Future<List<dynamic>> fetchRecipes() async {
    try {
      final response = await _dio.get('/recipes/');
      return response.data;
    } catch (e) {
      print('❌ Erro ao buscar receitas: $e');
      return [];
    }
  }

  Future<void> createRecipe(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Token não encontrado. Usuário não está autenticado.');
      }

      final File? imageFile = data['image'];

      // Constrói o FormData com MultipartFile da imagem (se houver)
      final formData = FormData.fromMap({
        'title': data['title'],
        'ingredients': data['ingredients'],
        'text_area': data['text_area'], // certifique-se que o nome bate com o backend
        if (data['category'] != null) 'category': data['category'],
        if (data['new_category'] != null) 'new_category': data['new_category'],
        if (imageFile != null)
          'image': await MultipartFile.fromFile(
            imageFile.path,
            filename: basename(imageFile.path),
          ),
      });

      final response = await _dio.post(
        '/recipes/',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      print('✅ Receita criada com sucesso: ${response.data}');
    } on DioException catch (e) {
      print('❌ Erro ao criar receita [Dio]: ${e.response?.statusCode} - ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('❌ Erro ao criar receita: $e');
      rethrow;
    }
  }
}
