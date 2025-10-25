class Category {
  final int id;
  final String name;
  final String description;
  final String? imageUrl;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final int stockQuantity;
  final int? categoryId;
  final String? imageUrl;
  // Danh sách URL ảnh gallery (tối đa 5)
  final List<String> imageGallery;
  final String? brand;
  final String? size;
  final String? color;
  final DateTime createdAt;
  final Category? category;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.stockQuantity,
    this.categoryId,
    this.imageUrl,
    this.imageGallery = const [],
    this.brand,
    this.size,
    this.color,
    required this.createdAt,
    this.category,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: json['price'].toDouble(),
      discountPrice: json['discountPrice']?.toDouble(),
      stockQuantity: json['stockQuantity'],
      categoryId: json['categoryId'],
      imageUrl: json['imageUrl'],
      imageGallery: (json['imageGallery'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      brand: json['brand'],
      size: json['size'],
      color: json['color'],
      createdAt: DateTime.parse(json['createdAt']),
      category: json['category'] != null ? Category.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'stockQuantity': stockQuantity,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'imageGallery': imageGallery,
      'brand': brand,
      'size': size,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'category': category?.toJson(),
    };
  }

  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get discountPercentage => hasDiscount ? ((price - discountPrice!) / price * 100) : 0;
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });

  double get totalPrice => product.finalPrice * quantity;
}





