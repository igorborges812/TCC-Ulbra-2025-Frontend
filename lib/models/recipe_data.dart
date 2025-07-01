class RecipeData {
  final int id;
  final String title;
  final String author;
  final String? image;
  final bool isFavorite;

  RecipeData({
    required this.id,
    required this.title,
    required this.author,
    this.image,
    required this.isFavorite,
  });

  factory RecipeData.fromJson(Map<String, dynamic> json) {
    return RecipeData(
      id: json['id'],
      title: (json['title'] ?? 'Sem título').toString(),
      author: (json['user'] ?? json['author'] ?? 'Autor desconhecido').toString(),
      image: json['image'], // ✅ agora busca direto o campo "image"
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
