// lib/screens/category_detail_screen.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/recipe_data.dart';
import '../components/recipe_card.dart';
import 'recipe_detail_screen.dart';

class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const CategoryDetailScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<List<RecipeData>> _recipesFuture;

  @override
  void initState() {
    super.initState();
    _recipesFuture = fetchRecipesByCategory(widget.categoryId);
  }

  Future<List<RecipeData>> fetchRecipesByCategory(int categoryId) async {
    final url = Uri.parse('http://10.0.2.2:8000/api/recipes/category/$categoryId/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(utf8.decode(response.bodyBytes));
      return jsonData.map((item) => RecipeData.fromJson(item)).toList();
    } else {
      throw Exception('Erro ao carregar receitas da categoria');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFE724C), 
        title: Text(
          widget.categoryTitle,
          style: const TextStyle(
            color: Color(0xFF272D2F), 
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF272D2F), 
        ),
        elevation: 1,
      ),
      body: FutureBuilder<List<RecipeData>>(
        future: _recipesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhuma receita nessa categoria'));
          } else {
            final recipes = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: recipes.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
                      ),
                    );
                  },
                  child: RecipeCard(
                    recipeId: recipe.id,
                    imageUrl: recipe.imageUrl ?? '',
                    title: recipe.title,
                    author: recipe.author,
                    isFavorite: recipe.isFavorite,
                    onFavorite: () {},
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}