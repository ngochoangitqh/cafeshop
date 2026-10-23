class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String description;
  final String? imageUrl;
  final DateTime? createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description = '',
    this.imageUrl,
    this.createdAt,
  });

  factory Product.fromMap(String id, Map<String, dynamic> data) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? 'Cà phê',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? data['Image'] ?? data['image'],
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is DateTime
              ? data['createdAt']
              : DateTime.tryParse(data['createdAt'].toString()))
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'Image': imageUrl, // Đáp ứng cả yêu cầu trường 'Image'
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
