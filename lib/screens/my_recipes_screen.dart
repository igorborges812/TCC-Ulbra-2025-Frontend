import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class MyRecipesScreen extends StatefulWidget {
  @override
  _MyRecipesScreenState createState() => _MyRecipesScreenState();
}

class _MyRecipesScreenState extends State<MyRecipesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> createdRecipes = [];
  List<dynamic> favoritedRecipes = [];
  final Color appColor = const Color(0xFFFE724C);

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

  Future<void> fetchMyRecipes() async {
    final token = await getToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/recipes/my_recipes/'),
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
      Uri.parse('http://10.0.2.2:8000/api/favorites/list/'),
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
      print('Erro ao buscar receitas favoritedas: ${response.body}');
    }
  }

  Widget buildRecipeCard(dynamic recipe) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/recipe_detail', arguments: recipe['id']);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: recipe['image'] != null
                  ? Image.network(
                      recipe['image'],
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.image, size: 50)),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                recipe['title'] ?? '',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
          // Receitas criadas
          Padding(
            padding: const EdgeInsets.all(16),
            child: createdRecipes.isEmpty
                ? const Center(child: Text('Nenhuma receita criada.'))
                : ListView.builder(
                    itemCount: createdRecipes.length,
                    itemBuilder: (context, index) {
                      return buildRecipeCard(createdRecipes[index]);
                    },
                  ),
          ),
          // Receitas favoritedas
          Padding(
            padding: const EdgeInsets.all(16),
            child: favoritedRecipes.isEmpty
                ? const Center(child: Text('Nenhuma receita favoritada.'))
                : ListView.builder(
                    itemCount: favoritedRecipes.length,
                    itemBuilder: (context, index) {
                      return buildRecipeCard(favoritedRecipes[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
