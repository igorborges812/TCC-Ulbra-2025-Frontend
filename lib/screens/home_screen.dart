import 'package:flutter/material.dart';
import '../components/bottom_nav_bar.dart';
import '../services/api_service.dart';
import '../models/category_data.dart';
import '../screens/category_detail_screen.dart';
import '../screens/recipe_detail_screen.dart';
import '../components/recipe_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<CategoryData>> categoriesFuture;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    categoriesFuture = ApiService().fetchCategoriesWithRecipes();
  }

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/create');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/my_recipes');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
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
