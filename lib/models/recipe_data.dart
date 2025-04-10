class RecipeData {
  final int id;
  final String title;
  final String author;
  final String? imageUrl;
  final bool isFavorite;

  RecipeData({
    required this.id,
    required this.title,
    required this.author,
    this.imageUrl,
    required this.isFavorite,
  });

factory RecipeData.fromJson(Map<String, dynamic> json) {
  String? imageUrl = json['image'];
  if (imageUrl != null && !imageUrl.startsWith('http')) {
    imageUrl = 'http://10.0.2.2:8000$imageUrl'; // ou seu IP real se estiver testando no físico
  }

  return RecipeData(
    id: json['id'],
    title: (json['title'] ?? 'Sem título').toString(),
    author: (json['user'] ?? json['author'] ?? 'Autor desconhecido').toString(),
    imageUrl: imageUrl,
    isFavorite: json['is_favorite'] ?? false,
  );
}
}
