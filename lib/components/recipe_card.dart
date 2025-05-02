import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart';

class RecipeCard extends StatelessWidget {
  final int recipeId;
  final String imageUrl;
  final String title;
  final String author;

  const RecipeCard({
    Key? key,
    required this.recipeId,
    required this.imageUrl,
    required this.title,
    required this.author,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final isFavorite = favoriteProvider.isFavorite(recipeId);

    // Verifica se a URL já está completa ou precisa de base
    final String fullImageUrl = imageUrl.startsWith('http')
        ? imageUrl
        : 'http://localhost:8000$imageUrl'; // altere aqui caso use outro host

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    fullImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _defaultImage(),
                  )
                : _defaultImage(),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF272D2F),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "por $author",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: const Color(0xFFFE724C),
                      ),
                      onPressed: () {
                        favoriteProvider.toggleFavorite(recipeId);
                      },
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _defaultImage() {
    return Image.asset(
      'assets/images/default_recipe.png',
      height: 120,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
