import 'package:flutter/material.dart';
import '../models/recipe_detail.dart';
import '../services/api_service.dart';
import '../providers/favorite_provider.dart';
import 'package:provider/provider.dart';

class RecipeDetailScreen extends StatefulWidget {
  final int recipeId;

  const RecipeDetailScreen({Key? key, required this.recipeId}) : super(key: key);

  @override
  _RecipeDetailScreenState createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  late Future<RecipeDetail?> _recipeDetail;

  @override
  void initState() {
    super.initState();
    _recipeDetail = ApiService().fetchRecipeDetail(widget.recipeId);
  }

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(widget.recipeId);

    return Scaffold(
      body: FutureBuilder<RecipeDetail?>(
        future: _recipeDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Erro ao carregar receita.'));
          }

          final recipe = snapshot.data!;
          final String imageUrl = recipe.image.isNotEmpty
              ? recipe.image
              : 'https://sizovghaygzecxbgvqvb.supabase.co/storage/v1/object/public/receitas/recipe_images/default.png';

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(imageUrl, recipe, isFavorite, favoriteProvider),
              _buildRecipeContent(recipe),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(
      String imageUrl, RecipeDetail recipe, bool isFavorite, FavoriteProvider favoriteProvider) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 250,
      backgroundColor: const Color(0xFFFE724C),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[200],
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recipe.title,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.author,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                      size: 28,
                    ),
                    onPressed: () {
                      favoriteProvider.toggleFavorite(widget.recipeId);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildRecipeContent(RecipeDetail recipe) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Ingredientes'),
            const SizedBox(height: 8),
            if (recipe.ingredients.isEmpty)
              const Text('Sem ingredientes cadastrados.')
            else
              ...recipe.ingredients.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    ingredient,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            _buildSectionTitle('Modo de Preparo'),
            const SizedBox(height: 8),
            if (recipe.steps.isEmpty)
              const Text('Sem instruções de preparo cadastradas.')
            else
              ...recipe.steps.asMap().entries.map(
                    (entry) => _buildStepCard(entry.key + 1, entry.value),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildStepCard(int stepNumber, String step) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PASSO $stepNumber',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFFE724C),
            ),
          ),
          const SizedBox(height: 4),
          Text(step),
        ],
      ),
    );
  }
}
