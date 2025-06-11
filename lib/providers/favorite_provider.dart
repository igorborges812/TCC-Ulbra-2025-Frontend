import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<int> _favoriteRecipeIds = {};
  final FavoriteService _favoriteService = FavoriteService();

  
  Set<int> get favoriteRecipeIds => _favoriteRecipeIds;


  bool isFavorite(int recipeId) => _favoriteRecipeIds.contains(recipeId);

 
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

 
  Future<void> toggleFavorite(int recipeId) async {
    if (isFavorite(recipeId)) {
      await removeFavorite(recipeId);
    } else {
      await addFavorite(recipeId);
    }
  }
}
