import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../models/category_data.dart';
import '../models/recipe_data.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // ✅ Corrigido aqui

  @override
  State<HomeScreen> createState() => _HomeScreenState(); // ✅ Corrigido aqui
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CategoryData>> categoriesFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    categoriesFuture = ApiService().fetchCategoriesWithRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  children: snapshot.data!
                      .map((category) => CategorySection(category: category))
                      .toList(),
                );
              }
            },
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            print('Selecionou item $index da navbar');
          });
        },
      ),
    );
  }
}

class CategorySection extends StatelessWidget {
  final CategoryData category;

  const CategorySection({super.key, required this.category}); // ✅ Boa prática

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF272D2F)),
            ),
            TextButton(
              onPressed: () {
                // TODO: Navegar para a tela da categoria
              },
              child: const Text('Ver mais'),
            ),
          ],
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: category.recipes.length,
            itemBuilder: (context, index) {
              final recipe = category.recipes[index];
              return _buildRecipeCard(recipe);
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildRecipeCard(RecipeData recipe) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: recipe.imageUrl != null
                  ? Image.network(
                      recipe.imageUrl!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        'assets/images/default_recipe.png',
                        height: 120,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      'assets/images/default_recipe.png',
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('por ${recipe.author}', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: Icon(
                      recipe.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // TODO: Implementar favoritar receita
                    },
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
