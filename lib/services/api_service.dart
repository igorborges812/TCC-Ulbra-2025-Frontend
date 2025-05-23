import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_data.dart';
import '../models/recipe_detail.dart';

class ApiService {
  final String baseUrl = 'http://10.0.2.2:8000';

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
        }
      }

      return categories;
    } else {
      throw Exception('Erro ao buscar categorias');
    }
  }

  Future<RecipeDetail?> fetchRecipeDetail(int id) async {
    final url = Uri.parse('$baseUrl/api/recipes/recipe/id/$id/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(utf8.decode(response.bodyBytes));
        return RecipeDetail.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
