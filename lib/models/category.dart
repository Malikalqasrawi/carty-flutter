class ProductCategory {
  final int id;
  final String name;
  final String imageUrl;

  const ProductCategory({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory ProductCategory.fromMap(Map<String, dynamic> map) {
    return ProductCategory(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: (map['image_url'] ?? '') as String,
    );
  }
}
