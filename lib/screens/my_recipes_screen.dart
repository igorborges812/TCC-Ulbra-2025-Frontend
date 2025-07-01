import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import '../screens/recipe_detail_screen.dart';

class MyRecipesScreen extends StatefulWidget {
  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> createdRecipes = [];
  List<dynamic> favoritedRecipes = [];
  final Color appColor = const Color(0xFFFE724C);

  final String baseUrl = 'https://tcc-ulbra-2025-backend.onrender.com';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchMyRecipes();
    fetchFavoriteRecipes();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  String formatImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';
    if (url.startsWith('http')) return url;
    return '$baseUrl$url';
  }

  Future<void> fetchMyRecipes() async {
    final token = await getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/api/recipes/my_recipes/'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      setState(() {
        createdRecipes = json.decode(decodedBody);
      });
    } else {
      print('Erro ao buscar receitas criadas: ${response.body}');
    }
  }

  Future<void> fetchFavoriteRecipes() async {
    final token = await getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('$baseUrl/api/favorites/list/'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      setState(() {
        favoritedRecipes = json.decode(decodedBody);
      });
    } else {
      print('Erro ao buscar receitas favoritadas: ${response.body}');
    }
  }

  Widget buildRecipeCard(dynamic recipeData, BuildContext context, {bool isFavoriteTab = false}) {
    final recipe = isFavoriteTab ? recipeData['recipe_id'] : recipeData;
    final int id = recipe['id'];
    final String title = recipe['title'] ?? '';
    final String image = recipe['image'] ?? '';
    final String author = recipe['user'] ?? 'Autor desconhecido';

    final favoriteProvider = Provider.of<FavoriteProvider>(context);
    final bool isFavorite = favoriteProvider.isFavorite(id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecipeDetailScreen(recipeId: id)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: image.isNotEmpty
                  ? Image.network(
                      formatImageUrl(image),
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 120,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'por $author',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isFavoriteTab)
                        IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: const Color(0xFFFE724C),
                            size: 18,
                          ),
                          onPressed: () async {
                            await favoriteProvider.toggleFavorite(id);
                            setState(() {
                              favoritedRecipes.removeWhere(
                                  (item) => item['recipe_id']['id'] == id);
                            });
                          },
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: appColor,
        title: const Text('Minhas Receitas'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Criadas'),
            Tab(text: 'Favoritas'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: createdRecipes.isEmpty
                ? const Center(child: Text('Nenhuma receita criada.'))
                : GridView.builder(
                    itemCount: createdRecipes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      return buildRecipeCard(createdRecipes[index], context);
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: favoritedRecipes.isEmpty
                ? const Center(child: Text('Nenhuma receita favoritada.'))
                : GridView.builder(
                    itemCount: favoritedRecipes.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemBuilder: (context, index) {
                      return buildRecipeCard(favoritedRecipes[index], context, isFavoriteTab: true);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
