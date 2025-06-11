import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class FavoriteService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/favorites'));

  // 🔐 Pega o token salvo localmente
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Adiciona um favorito no backend
  Future<void> addFavorite(int recipeId) async {
    final token = await getToken();
    if (token == null) {
      print('❌ Token não encontrado');
      return;
    }

    try {
      await _dio.post(
        '/add/',
        data: {'recipe_id': recipeId},
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      print('✅ Receita $recipeId adicionada aos favoritos');
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        print('⚠️ Receita já está nos favoritos');
      } else {
        print('❌ Erro ao adicionar favorito: ${e.response?.data}');
      }
    } catch (e) {
      print('❌ Erro inesperado ao adicionar favorito: $e');
    }
  }

  // ✅ Remove um favorito no backend
  Future<void> removeFavorite(int recipeId) async {
    final token = await getToken();
    if (token == null) {
      print('❌ Token não encontrado');
      return;
    }

    try {
      await _dio.delete(
        '/remove/$recipeId/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );
      print('✅ Receita $recipeId removida dos favoritos');
    } on DioException catch (e) {
      print('❌ Erro ao remover favorito: ${e.response?.data}');
    } catch (e) {
      print('❌ Erro inesperado ao remover favorito: $e');
    }
  }

  // ✅ Busca todos os favoritos do usuário e retorna os IDs das receitas
  Future<List<int>> fetchFavorites() async {
    final token = await getToken();
    if (token == null) {
      print('❌ Token não encontrado');
      return [];
    }

    try {
      final response = await _dio.get(
        '/list/',
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;

        // 🔥 Aqui acessamos corretamente o campo 'recipe_id'
        final ids = data.map<int>((item) {
          if (item is Map<String, dynamic> && item.containsKey('recipe_id')) {
            return item['recipe_id'] as int;
          } else {
            throw Exception('Formato inesperado no item de favoritos: $item');
          }
        }).toList();

        print('🗂️ Favoritos carregados: $ids');
        return ids;
      } else {
        print('❌ Erro ao buscar favoritos: ${response.data}');
        return [];
      }
    } on DioException catch (e) {
      print('❌ Erro na requisição de favoritos: ${e.response?.data}');
      return [];
    } catch (e) {
      print('❌ Erro inesperado na requisição de favoritos: $e');
      return [];
    }
  }
}
