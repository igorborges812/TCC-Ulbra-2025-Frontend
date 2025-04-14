import 'recipe_data.dart';

class CategoryData {
  final int id;
  final String title;
  final List<RecipeData> recipes;

  CategoryData({
    required this.id,
    required this.title,
    required this.recipes,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['id'],
      title: json['title'] ?? json['name'], 
      recipes: (json['recipes'] as List)
          .map((item) => RecipeData.fromJson(item))
          .toList(),
    );
  }
}
