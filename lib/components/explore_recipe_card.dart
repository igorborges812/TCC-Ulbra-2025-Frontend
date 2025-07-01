import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/favorite_provider.dart';
import '../screens/recipe_detail_screen.dart';

class ExploreRecipeCard extends StatelessWidget {
  final int recipeId;
  final String imageUrl;
  final String title;
  final String author;

  const ExploreRecipeCard({
    Key? key,
    required this.recipeId,
    required this.imageUrl,
    required this.title,
    required this.author,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final bool isFavorite = favoriteProvider.isFavorite(recipeId);

    final String fullImageUrl = imageUrl.isNotEmpty
        ? (imageUrl.startsWith('http')
            ? imageUrl
            : 'https://sizovghaygzecxbgvqvb.supabase.co/storage/v1/object/public/receitas/$imageUrl')
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeDetailScreen(recipeId: recipeId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: SizedBox(
                height: 120,
                width: double.infinity,
                child: fullImageUrl.isNotEmpty
                    ? Image.network(
                        fullImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _defaultImage(),
                      )
                    : _defaultImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.isNotEmpty ? title : 'Sem título',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF272D2F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          author.isNotEmpty ? "por $author" : "Autor desconhecido",
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.share, size: 18),
                            onPressed: () {
                              Share.share(
                                'Veja essa receita no CookTogether: "$title"! 🍽️',
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: const Color(0xFFFE724C),
                              size: 18,
                            ),
                            onPressed: () {
                              favoriteProvider.toggleFavorite(recipeId);
                            },
                            splashRadius: 18,
                            constraints: const BoxConstraints(),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _defaultImage() {
    return Container(
      height: 120,
      width: double.infinity,
      color: Colors.grey[200],
      alignment: Alignment.center,
      child: Image.asset(
        'assets/images/default_recipe.png',
        fit: BoxFit.contain,
      ),
    );
  }
}
