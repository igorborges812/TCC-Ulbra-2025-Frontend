import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  final Set<int> _favoriteRecipeIds = {};

  Set<int> get favoriteRecipeIds => _favoriteRecipeIds;

  bool isFavorite(int recipeId) => _favoriteRecipeIds.contains(recipeId);

  void toggleFavorite(int recipeId) {
    if (_favoriteRecipeIds.contains(recipeId)) {
      _favoriteRecipeIds.remove(recipeId);
    } else {
      _favoriteRecipeIds.add(recipeId);
    }
    notifyListeners();
  }
}
