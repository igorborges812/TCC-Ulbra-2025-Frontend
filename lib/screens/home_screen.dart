import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../components/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../models/category_data.dart';
import '../screens/category_detail_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../components/recipe_card.dart';
import '../components/explore_recipe_card.dart';
import '../providers/favorite_provider.dart';
import '../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CategoryData>> categoriesFuture;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _searchResults = [];
  List<String> _categorySuggestions = [];
  bool _isSearching = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    categoriesFuture = ApiService().fetchCategoriesWithRecipes();
    _loadCategorySuggestions();
    _searchController.addListener(() {
      final query = _searchController.text;
      if (query.isNotEmpty && !_isSearching) {
        setState(() {
          _isSearching = true;
          _currentIndex = 1;
        });
      } else if (query.isEmpty && _isSearching) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
          _currentIndex = 0;
        });
      }
    });
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/create');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/my_recipes');
    } else if (index == 4) {
      Navigator.pushNamed(context, '/profile'); // 🔁 vai para a tela de perfil
    } else {
      setState(() {
        _currentIndex = index;
        if (index == 0) {
          _searchController.clear();
          _isSearching = false;
        } else if (index == 1) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      });
    }
  }

  Future<void> _loadCategorySuggestions() async {
    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/recipes/category/'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      setState(() {
        _categorySuggestions = data.map<String>((cat) => cat['name'].toString()).toList();
      });
    }
  }

  Future<void> _searchRecipes(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
        _searchResults = [];
        _currentIndex = 0;
      });
      return;
    }

    setState(() => _isSearching = true);

    final token = await AuthService().getToken();

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/recipes/list/?search=$query'),
      headers: {
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List data = json.decode(utf8.decode(response.bodyBytes));
      setState(() => _searchResults = data);
    } else {
      setState(() => _searchResults = []);
    }
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _focusNode,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              hintText: 'Buscar por nome, ingrediente ou categoria...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              fillColor: Colors.white,
              filled: true,
            ),
            onChanged: _searchRecipes,
          ),
          const SizedBox(height: 8),
          if (_categorySuggestions.isNotEmpty)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categorySuggestions.length,
                itemBuilder: (context, index) {
                  final category = _categorySuggestions[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(category),
                      onPressed: () {
                        _searchController.text = category;
                        _searchRecipes(category);
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  );
                },
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return const Center(child: Text('Nenhuma receita ou categoria encontrada.'));
    }

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: _searchResults.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final recipe = _searchResults[index];
        return ExploreRecipeCard(
          recipeId: recipe['id'],
          imageUrl: recipe['image'] ?? '',
          title: recipe['title'] ?? '',
          author: recipe['user'] ?? '',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: _isSearching
                  ? _buildSearchResults()
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: FutureBuilder<List<CategoryData>>(
                        future: categoriesFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Erro ao carregar dados: ${snapshot.error}'));
                          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return const Center(child: Text('Nenhuma receita encontrada'));
                          } else {
                            return ListView(
                              physics: const SlowScrollPhysics(),
                              children: snapshot.data!
                                  .map((category) => CategorySection(category: category))
                                  .toList(),
                            );
                          }
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class SlowScrollPhysics extends ClampingScrollPhysics {
  const SlowScrollPhysics({ScrollPhysics? parent}) : super(parent: parent);

  @override
  SlowScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return SlowScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    return offset * 0.2;
  }
}

class CategorySection extends StatelessWidget {
  final CategoryData category;

  const CategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final limitedRecipes = category.recipes.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF272D2F),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailScreen(
                      categoryId: category.id,
                      categoryTitle: category.title,
                    ),
                  ),
                );
              },
              child: const Text('Ver mais'),
            ),
          ],
        ),
        GridView.builder(
          padding: const EdgeInsets.only(top: 8),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: limitedRecipes.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final recipe = limitedRecipes[index];
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
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
