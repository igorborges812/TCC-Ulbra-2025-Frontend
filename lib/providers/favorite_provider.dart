import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<int> _favoriteRecipeIds = {};
  final FavoriteService _favoriteService = FavoriteService();

  // 🔥 Getter para acessar IDs das receitas favoritas
  Set<int> get favoriteRecipeIds => _favoriteRecipeIds;

  // 🔥 Verifica se uma receita está favoritada
  bool isFavorite(int recipeId) => _favoriteRecipeIds.contains(recipeId);

  // 🚀 Carrega os favoritos do backend ao iniciar o app
  Future<void> loadFavoritesFromBackend() async {
    try {
      final favorites = await _favoriteService.fetchFavorites();
      _favoriteRecipeIds
        ..clear()
        ..addAll(favorites);
      notifyListeners();
      print('✅ Favoritos carregados: $_favoriteRecipeIds');
    } catch (e) {
      print('❌ Erro ao carregar favoritos: $e');
    }
  }

  // ❤️ Adiciona uma receita aos favoritos
  Future<void> addFavorite(int recipeId) async {
    try {
      await _favoriteService.addFavorite(recipeId);
      _favoriteRecipeIds.add(recipeId);
      notifyListeners();
      print('❤️ Receita $recipeId adicionada aos favoritos');
    } catch (e) {
      print('❌ Erro ao adicionar favorito: $e');
    }
  }

  // 💔 Remove uma receita dos favoritos
  Future<void> removeFavorite(int recipeId) async {
    try {
      await _favoriteService.removeFavorite(recipeId);
      _favoriteRecipeIds.remove(recipeId);
      notifyListeners();
      print('💔 Receita $recipeId removida dos favoritos');
    } catch (e) {
      print('❌ Erro ao remover favorito: $e');
    }
  }

  // 🔄 Alterna o estado de favorito (toggle)
  Future<void> toggleFavorite(int recipeId) async {
    if (isFavorite(recipeId)) {
      await removeFavorite(recipeId);
    } else {
      await addFavorite(recipeId);
    }
  }
}
