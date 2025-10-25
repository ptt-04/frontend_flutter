import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class CartItem {
  final int id;
  final int productId;
  final String productName;
  final String productImageUrl;
  final double productPrice;
  final double? productDiscountPrice;
  final int quantity;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime updatedAt;

  CartItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.productPrice,
    this.productDiscountPrice,
    required this.quantity,
    required this.totalPrice,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImageUrl: json['productImageUrl'] ?? '',
      productPrice: (json['productPrice'] as num).toDouble(),
      productDiscountPrice: json['productDiscountPrice'] != null 
          ? (json['productDiscountPrice'] as num).toDouble() 
          : null,
      quantity: json['quantity'],
      totalPrice: (json['totalPrice'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  double get finalPrice => productDiscountPrice ?? productPrice;
}

class Cart {
  final int id;
  final int userId;
  final List<CartItem> cartItems;
  final double totalAmount;
  final int totalItems;
  final DateTime createdAt;
  final DateTime updatedAt;

  Cart({
    required this.id,
    required this.userId,
    required this.cartItems,
    required this.totalAmount,
    required this.totalItems,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['id'],
      userId: json['userId'],
      cartItems: (json['cartItems'] as List)
          .map((item) => CartItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      totalItems: json['totalItems'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class CartProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  Cart? _cart;
  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  Cart? get cart => _cart;
  List<CartItem> get items => _items;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  bool get isLoading => _isLoading;
  String? get error => _error;

  CartProvider() {
    loadCart();
  }

  Future<void> loadCart() async {
    try {
      _setLoading(true);
      _setError(null);

      final cartData = await _apiService.getCart();
      final List<dynamic> cartItemsData = cartData['cartItems'] ?? [];
      _items = cartItemsData.map((item) => CartItem.fromJson(item)).toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.addToCart(
        productId: productId,
        quantity: quantity,
      );
      // Reload cart after adding
      await loadCart();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.updateCartItem(
        cartItemId: cartItemId,
        quantity: quantity,
      );
      // Reload cart after updating
      await loadCart();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.removeFromCart(cartItemId);
      
      // Reload cart after removal
      await loadCart();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> clearCart() async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.clearCart();
      _items.clear();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<int> getCartItemCount() async {
    try {
      return await _apiService.getCartItemCount();
    } catch (e) {
      return 0;
    }
  }

  bool isInCart(int productId) {
    return items.any((item) => item.productId == productId);
  }

  int getQuantity(int productId) {
    final item = items.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(
        id: 0,
        productId: productId,
        productName: '',
        productImageUrl: '',
        productPrice: 0,
        quantity: 0,
        totalPrice: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return item.quantity;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }
}
