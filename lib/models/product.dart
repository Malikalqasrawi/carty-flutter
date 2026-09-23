class Product {
  final int id;
  final int categoryId;
  final String name;
  final double price;
  final String unit;
  final String imageUrl;
  final String description;
  final bool isPopular;

  const Product({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.price,
    required this.unit,
    required this.imageUrl,
    this.description = '',
    this.isPopular = false,
  });

  /// Example: "2.99 JOD"
  String get priceText => '${price.toStringAsFixed(2)} JOD';

  /// Example: "2.99 JOD / kg"
  String get priceLabel => '$priceText / $unit';

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int,
      categoryId: map['category_id'] as int,
      name: map['name'] as String,
      // Postgres "numeric" can arrive as int or double, so read it as num.
      price: (map['price'] as num).toDouble(),
      unit: (map['unit'] ?? 'piece') as String,
      imageUrl: (map['image_url'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      isPopular: (map['is_popular'] ?? false) as bool,
    );
  }
}
