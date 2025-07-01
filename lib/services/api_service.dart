import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/category_data.dart';
import '../models/recipe_detail.dart';

class ApiService {
  final String baseUrl = 'https://tcc-ulbra-2025-backend.onrender.com';

  Future<List<CategoryData>> fetchCategoriesWithRecipes() async {
    final categoriesUrl = Uri.parse('$baseUrl/api/recipes/category/');
    final categoriesResponse = await http.get(categoriesUrl);

    if (categoriesResponse.statusCode == 200) {
      final List<dynamic> categoriesJson =
          json.decode(utf8.decode(categoriesResponse.bodyBytes));
      List<CategoryData> categories = [];

      for (var categoryJson in categoriesJson) {
        final int categoryId = categoryJson['id'];
        final String categoryTitle = categoryJson['name'];

        final recipesUrl = Uri.parse('$baseUrl/api/recipes/category/$categoryId/');
        final recipesResponse = await http.get(recipesUrl);

        if (recipesResponse.statusCode == 200) {
          final List<dynamic> recipesJson =
              json.decode(utf8.decode(recipesResponse.bodyBytes));

          final limitedRecipes = recipesJson.take(2).toList();

          categories.add(CategoryData.fromJson({
            'id': categoryId,
            'title': categoryTitle,
            'recipes': limitedRecipes,
          }));
        } else {
          print('⚠️ Erro ao carregar receitas da categoria $categoryId');
        }
      }

      return categories;
    } else {
      throw Exception('❌ Erro ao buscar categorias: ${categoriesResponse.statusCode}');
    }
  }

  Future<RecipeDetail?> fetchRecipeDetail(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse('$baseUrl/api/recipes/recipe/id/$id/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('🔍 Buscando receita ID $id → Status: ${response.statusCode}');
      print('📦 Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return RecipeDetail.fromJson(jsonData);
      } else {
        print('❌ Falha ao carregar receita ID $id - Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Erro inesperado ao carregar receita ID $id: $e');
      return null;
    }
  }
}
