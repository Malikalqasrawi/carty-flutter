class Product {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final String unit;
  final String imageUrl;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.unit,
    required this.imageUrl,
  });

  /// Example: "2.99 JOD / kg"
  String get priceLabel => '${price.toStringAsFixed(2)} JOD / $unit';

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      // Postgres "numeric" can arrive as int or double, so read it as num.
      price: (map['price'] as num).toDouble(),
      unit: (map['unit'] ?? 'piece') as String,
      imageUrl: (map['image_url'] ?? '') as String,
    );
  }
}
