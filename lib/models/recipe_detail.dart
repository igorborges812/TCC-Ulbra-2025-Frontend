class RecipeDetail {
  final int id;
  final String title;
  final String image;
  final String author;
  final List<String> ingredients;
  final List<String> steps;

  RecipeDetail({
    required this.id,
    required this.title,
    required this.image,
    required this.author,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    List<String> parsedIngredients = [];

    if (json['ingredients'] is List) {
      parsedIngredients = (json['ingredients'] as List).map((e) {
        if (e is Map<String, dynamic>) {
          final name = e['name'] ?? '';
          final quantity = e['quantity']?.toString() ?? '';
          final unit = e['unit'] ?? '';
          return '$quantity $unit - $name';
        } else {
          return e.toString();
        }
      }).toList();
    }

    return RecipeDetail(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Sem título',
      image: json['image'] ?? '',
      author: json['user'] ?? 'Autor desconhecido',
      ingredients: parsedIngredients,
      steps: (json['text_area'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
