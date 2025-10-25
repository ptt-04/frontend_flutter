import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/product.dart' as models;
import '../services/api_service.dart';

class ProductProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<models.Product> _products = [];
  List<models.Category> _categories = [];
  bool _isLoading = false;
  String? _error;
  int? _selectedCategoryId;
  String? _searchQuery;

  List<models.Product> get products => _products;
  List<models.Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int? get selectedCategoryId => _selectedCategoryId;
  String? get searchQuery => _searchQuery;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadProducts({
    int? categoryId,
    String? search,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final products = await _apiService.getProducts(
        categoryId: categoryId,
        search: search,
      );
      _products = products;
      _selectedCategoryId = categoryId;
      _searchQuery = search;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCategories() async {
    try {
      _setLoading(true);
      _setError(null);

      final categoriesData = await _apiService.getCategories();
      _categories = categoriesData.map((data) => models.Category.fromJson(data)).toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<models.Product?> getProduct(int id) async {
    try {
      _setLoading(true);
      _setError(null);

      final product = await _apiService.getProduct(id);
      return product;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void filterByCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    loadProducts(categoryId: categoryId, search: _searchQuery);
  }

  void searchProducts(String? query) {
    _searchQuery = query;
    loadProducts(categoryId: _selectedCategoryId, search: query);
  }

  List<models.Product> getFeaturedProducts() {
    return _products.where((p) => p.hasDiscount).toList();
  }

  List<models.Product> getProductsByCategory(int categoryId) {
    return _products.where((p) => p.categoryId == categoryId).toList();
  }

  Future<bool> createProduct({
    required String name,
    required String description,
    required double price,
    int? categoryId,
    String? imageUrl,
    int stockQuantity = 0,
    List<String>? imageGallery,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final product = await _apiService.createProduct(
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrl: imageUrl,
        stockQuantity: stockQuantity,
        imageGallery: imageGallery,
      );
      
      _products.insert(0, product);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProduct({
    required int id,
    required String name,
    required String description,
    required double price,
    int? categoryId,
    String? imageUrl,
    int stockQuantity = 0,
    List<String>? imageGallery,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final product = await _apiService.updateProduct(
        id: id,
        name: name,
        description: description,
        price: price,
        categoryId: categoryId,
        imageUrl: imageUrl,
        stockQuantity: stockQuantity,
        imageGallery: imageGallery,
      );
      
      final index = _products.indexWhere((p) => p.id == id);
      if (index != -1) {
        _products[index] = product;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.deleteProduct(productId);
      
      // Reload products from server to ensure sync
      await loadProducts(
        categoryId: _selectedCategoryId,
        search: _searchQuery,
      );
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createCategory({
    required String name,
    required String description,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final categoryData = await _apiService.createCategory({
        'name': name,
        'description': description,
        'isActive': true,
      });
      
      final category = models.Category.fromJson(categoryData);
      _categories.add(category);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateCategory({
    required int id,
    required String name,
    required String description,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.updateCategory(id, {
        'name': name,
        'description': description,
        'isActive': true,
      });
      
      // Reload categories to get updated data
      await loadCategories();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCategory(int categoryId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.deleteCategory(categoryId);
      
      // Reload categories from server to ensure sync
      await loadCategories();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Image upload method
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      _setLoading(true);
      _setError(null);

      final imageUrl = await _apiService.uploadProductImage(imageFile);
      return imageUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Image upload by bytes (web support)
  Future<String?> uploadProductImageBytes(Uint8List bytes, String filename) async {
    try {
      _setLoading(true);
      _setError(null);

      final imageUrl = await _apiService.uploadProductImageBytes(bytes, filename);
      return imageUrl;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Multiple images upload (mobile/desktop)
  Future<List<String>> uploadProductImages(List<File> imageFiles) async {
    try {
      _setLoading(true);
      _setError(null);
      final urls = await _apiService.uploadProductImages(imageFiles);
      return urls;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Multiple images upload (web)
  Future<List<String>> uploadProductImagesBytes(List<Uint8List> files, List<String> filenames) async {
    try {
      _setLoading(true);
      _setError(null);
      final urls = await _apiService.uploadProductImagesBytes(files, filenames);
      return urls;
    } catch (e) {
      _setError(e.toString());
      return [];
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}





