import 'package:flutter/material.dart';
import '../models/category_data.dart';
import '../models/recipe_data.dart';

class CategoryDetailScreen extends StatelessWidget {
  final CategoryData category;

  const CategoryDetailScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        title: Text(
          category.title,
          style: const TextStyle(
            color: Color(0xFF272D2F),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFFE724C),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF272D2F)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: category.recipes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final recipe = category.recipes[index];
            return _buildRecipeItem(recipe);
          },
        ),
      ),
    );
  }

  Widget _buildRecipeItem(RecipeData recipe) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: recipe.imageUrl != null
              ? Image.network(
                  recipe.imageUrl!,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/default_recipe.png',
                    width: 70,
                    height: 70,
                    fit: BoxFit.cover,
                  ),
                )
              : Image.asset(
                  'assets/images/default_recipe.png',
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                ),
        ),
        title: Text(
          recipe.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF272D2F),
          ),
        ),
        subtitle: Text(
          'por ${recipe.author}',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
          color: const Color(0xFFFE724C),
        ),
        onTap: () {
        },
      ),
    );
  }
}
