import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/user.dart';
import '../models/product.dart';
import '../models/voucher.dart';
import '../config/api_config.dart';

class ApiService {
  // Sử dụng config để lấy base URL
  static String get baseUrl => ApiConfig.baseUrl;
  late Dio _dio;

  ApiService() {
    print('🌐 Initializing ApiService with baseUrl: $baseUrl');
    
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _clearToken();
        }
        handler.next(error);
      },
    ));
  }

  // Single image upload (mobile/desktop)
  Future<String?> uploadProductImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/product/upload-image',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['imageUrl'] is String) {
        return data['imageUrl'] as String;
      }
      if (data is String) return data;
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Single image upload (bytes, Web)
  Future<String?> uploadProductImageBytes(Uint8List bytes, String filename) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });

      final response = await _dio.post(
        '/product/upload-image',
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['imageUrl'] is String) {
        return data['imageUrl'] as String;
      }
      if (data is String) return data;
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Auth endpoints
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      });

      final authResponse = AuthResponse.fromJson(response.data);
      await _saveToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> login({
    required String usernameOrEmail,
    required String password,
    }) async {
      try {
        print('🔐 Attempting login to: $baseUrl/auth/login');
        print('📧 Username/Email: $usernameOrEmail');
        
        final response = await _dio.post('/auth/login', data: {
          'usernameOrEmail': usernameOrEmail,
          'password': password,
        });

        print('✅ Login successful: ${response.statusCode}');
        print('📄 Response data: ${response.data}');

        final authResponse = AuthResponse.fromJson(response.data);
        await _saveToken(authResponse.token);
        return authResponse;
      } on DioException catch (e) {
        print('❌ Login failed: ${e.type} - ${e.message}');
        if (e.response != null) {
          print('📊 Response status: ${e.response!.statusCode}');
          print('📄 Response data: ${e.response!.data}');
        }
        throw _handleError(e);
      }
  }

  Future<User> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    await _clearToken();
  }

  // Product endpoints
  Future<List<Product>> getProducts({
    int? categoryId,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get('/product', queryParameters: queryParams);
      return (response.data as List)
          .map((json) => Product.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> getProduct(int id) async {
    try {
      final response = await _dio.get('/product/$id');
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    int? categoryId,
    String? imageUrl,
    int stockQuantity = 0,
    List<String>? imageGallery,
  }) async {
    try {
      final payload = {
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrl': imageUrl,
        'stockQuantity': stockQuantity,
      };
      if (imageGallery != null) {
        payload['imageGallery'] = imageGallery;
      }
      final response = await _dio.post('/product', data: payload);
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Product> updateProduct({
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
      final payload = {
        'name': name,
        'description': description,
        'price': price,
        'categoryId': categoryId,
        'imageUrl': imageUrl,
        'stockQuantity': stockQuantity,
      };
      if (imageGallery != null) {
        payload['imageGallery'] = imageGallery;
      }
      final response = await _dio.put('/product/$id', data: payload);
      return Product.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteProduct(int productId) async {
    try {
      await _dio.delete('/product/$productId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Voucher endpoints
  Future<List<Voucher>> getAvailableVouchers() async {
    try {
      final response = await _dio.get('/voucher/available');
      return (response.data as List)
          .map((json) => Voucher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<UserVoucher>> getMyVouchers() async {
    try {
      final response = await _dio.get('/voucher/my-vouchers');
      return (response.data as List)
          .map((json) => UserVoucher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> assignVoucher(int voucherId) async {
    try {
      await _dio.post('/voucher/$voucherId/assign');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> useVoucher(int voucherId, {int? orderId}) async {
    try {
      await _dio.post('/voucher/$voucherId/use', data: orderId);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<String> analyzeImage(String imageBase64) async {
    try {
      final response = await _dio.post('/ai/analyze-image', data: {
        'imageBase64': imageBase64,
      });
      return response.data['response'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> editHairStyle(String imageBase64, String styleDescription) async {
    try {
      final response = await _dio.post('/ai/edit-hair-style', data: {
        'imageBase64': imageBase64,
        'styleDescription': styleDescription,
      });
      return response.data['response'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String> findProductsByDescription(String description) async {
    try {
      final response = await _dio.post('/ai/find-products', data: {
        'description': description,
      });
      return response.data['response'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Image upload endpoint (multiple)
  Future<List<String>> uploadProductImages(List<File> imageFiles) async {
    try {
      final formData = FormData();
      for (final imageFile in imageFiles) {
        formData.files.add(
          MapEntry(
            'files',
            await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/product/upload-images',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Backend returns { imageUrls: [...] }
      final data = response.data;
      if (data is Map<String, dynamic> && data['imageUrls'] is List) {
        return (data['imageUrls'] as List).map((e) => e.toString()).toList();
      }
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Image upload by bytes (useful for Web) - multiple
  Future<List<String>> uploadProductImagesBytes(List<Uint8List> files, List<String> filenames) async {
    try {
      final formData = FormData();
      for (int i = 0; i < files.length; i++) {
        formData.files.add(
          MapEntry(
            'files',
            MultipartFile.fromBytes(
              files[i],
              filename: filenames[i],
            ),
          ),
        );
      }

      final response = await _dio.post(
        '/product/upload-images',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      final data = response.data;
      if (data is Map<String, dynamic> && data['imageUrls'] is List) {
        return (data['imageUrls'] as List).map((e) => e.toString()).toList();
      }
      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Voucher management endpoints
  Future<List<Voucher>> getAllVouchers() async {
    try {
      print('🌐 API: Getting all vouchers from /voucher/admin/all');
      final response = await _dio.get('/voucher/admin/all');
      print('🌐 API Response: ${response.statusCode} - ${response.data}');
      return (response.data as List)
          .map((json) => Voucher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      print('🌐 API Error: ${e.response?.statusCode} - ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<Voucher?> getVoucherById(int id) async {
    try {
      final response = await _dio.get('/voucher/admin/$id');
      return Voucher.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Voucher?> createVoucher(CreateVoucherDto voucherDto) async {
    try {
      final response = await _dio.post('/voucher', data: voucherDto.toJson());
      return Voucher.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Voucher?> updateVoucher(int id, CreateVoucherDto voucherDto) async {
    try {
      final response = await _dio.put('/voucher/admin/$id', data: voucherDto.toJson());
      return Voucher.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteVoucher(int id) async {
    try {
      await _dio.delete('/voucher/admin/$id');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<UserVoucher>> getAllUserVouchers() async {
    try {
      final response = await _dio.get('/voucher/admin/user-vouchers');
      return (response.data as List)
          .map((json) => UserVoucher.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Profile management endpoints
  Future<User> updateProfile({
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      final response = await _dio.put('/auth/profile', data: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      });
      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.put('/auth/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<String?> uploadProfileImage(File imageFile) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.path.split('/').last,
        ),
      });

      final response = await _dio.post(
        '/auth/upload-profile-image',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 200) {
        return response.data['imageUrl'];
      }
      return null;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Admin endpoints
  Future<List<User>> getUsers() async {
    try {
      final response = await _dio.get('/admin/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User?> createBarber({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      final response = await _dio.post('/admin/create-barber', data: {
        'username': username,
        'email': email,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      });

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> updateUserRole(int userId, Role role) async {
    try {
      await _dio.put('/admin/users/$userId/role', data: {
        'role': role.value,
      });
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<User?> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      final response = await _dio.put('/admin/users/$userId', data: {
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'dateOfBirth': dateOfBirth.toIso8601String(),
        'gender': gender,
      });

      return User.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<bool> deleteUser(int userId) async {
    try {
      await _dio.delete('/admin/users/$userId');
      return true;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Dashboard endpoints
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      final response = await _dio.get('/admin/dashboard/stats');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Cart API methods
  Future<Map<String, dynamic>> getCart() async {
    try {
      final response = await _dio.get('/cart');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.post('/cart/add', data: {
        'productId': productId,
        'quantity': quantity,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateCartItem({
    required int cartItemId,
    required int quantity,
  }) async {
    try {
      final response = await _dio.put('/cart/$cartItemId', data: {
        'quantity': quantity,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeFromCart(int cartItemId) async {
    try {
      await _dio.delete('/cart/$cartItemId');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> clearCart() async {
    try {
      await _dio.delete('/cart/clear');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<int> getCartItemCount() async {
    try {
      final response = await _dio.get('/cart/count');
      return response.data['count'] ?? 0;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Service Management API methods
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      print('🔄 Loading services from API...');
      final response = await _dio.get('/service');
      print('✅ Services loaded successfully: ${response.data}');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('❌ Error loading services: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      throw _handleError(e);
    }
  }

  Future<void> createService(Map<String, dynamic> serviceData) async {
    try {
      print('🔄 Creating service: $serviceData');
      final response = await _dio.post('/service', data: serviceData);
      print('✅ Service created successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Error creating service: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<void> updateService(Map<String, dynamic> serviceData) async {
    try {
      print('🔄 Updating service: $serviceData');
      final response = await _dio.put('/service/${serviceData['id']}', data: serviceData);
      print('✅ Service updated successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Error updating service: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<void> deleteService(int serviceId) async {
    try {
      print('🔄 Deleting service: $serviceId');
      final response = await _dio.delete('/service/$serviceId');
      print('✅ Service deleted successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Error deleting service: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  // Booking API methods
  Future<List<Map<String, dynamic>>> getMyBookings() async {
    try {
      final response = await _dio.get('/booking/my-bookings');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllBookings() async {
    try {
      final response = await _dio.get('/booking/admin/all');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createBooking({
    required int serviceId,
    int? barberId,
    required DateTime bookingDateTime,
    String? notes,
    int? loyaltyPointsUsed,
  }) async {
    try {
      final response = await _dio.post('/booking', data: {
        'serviceId': serviceId,
        'barberId': barberId,
        'bookingDateTime': bookingDateTime.toIso8601String(),
        'notes': notes,
        'loyaltyPointsUsed': loyaltyPointsUsed,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    try {
      final response = await _dio.put('/booking/$bookingId/status', data: status);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> cancelBooking(int bookingId) async {
    try {
      await _dio.put('/booking/$bookingId/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> adminCancelBooking(int bookingId) async {
    try {
      await _dio.put('/booking/$bookingId/admin/cancel');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> confirmBooking(int bookingId) async {
    try {
      await _dio.put('/booking/$bookingId/confirm');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> completeBooking(int bookingId, {int? loyaltyPointsEarned}) async {
    try {
      final data = <String, dynamic>{};
      if (loyaltyPointsEarned != null) {
        data['loyaltyPointsEarned'] = loyaltyPointsEarned;
      }
      await _dio.put('/booking/$bookingId/complete', data: data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }


  Future<List<Map<String, dynamic>>> getBarbers() async {
    try {
      final response = await _dio.get('/booking/barbers');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Order API methods
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await _dio.post('/order', data: orderData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getOrder(int orderId) async {
    try {
      final response = await _dio.get('/order/$orderId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getMyOrders() async {
    try {
      final response = await _dio.get('/order/my-orders');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    try {
      final response = await _dio.get('/order/all');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(int orderId, String status) async {
    try {
      final response = await _dio.put('/order/$orderId/status', data: {'status': status});
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getBranches() async {
    try {
      final response = await _dio.get('/order/branches');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getBranch(int branchId) async {
    try {
      final response = await _dio.get('/order/branches/$branchId');
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createVNPayPayment(Map<String, dynamic> paymentData) async {
    try {
      final response = await _dio.post('/order/vnpay/create-payment', data: paymentData);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Category API methods
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      print('🔄 Fetching categories...');
      final response = await _dio.get('/category');
      print('✅ Categories fetched successfully: ${response.data}');
      return List<Map<String, dynamic>>.from(response.data);
    } on DioException catch (e) {
      print('❌ Error fetching categories: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getCategory(int categoryId) async {
    try {
      print('🔄 Fetching category: $categoryId');
      final response = await _dio.get('/category/$categoryId');
      print('✅ Category fetched successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Error fetching category: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> createCategory(Map<String, dynamic> categoryData) async {
    try {
      print('🔄 Creating category: $categoryData');
      final response = await _dio.post('/category', data: categoryData);
      print('✅ Category created successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Error creating category: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<void> updateCategory(int categoryId, Map<String, dynamic> categoryData) async {
    try {
      print('🔄 Updating category: $categoryId with data: $categoryData');
      final response = await _dio.put('/category/$categoryId', data: categoryData);
      print('✅ Category updated successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Error updating category: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> deleteCategory(int categoryId) async {
    try {
      print('🔄 Deleting category: $categoryId');
      final response = await _dio.delete('/category/$categoryId');
      print('✅ Category deleted successfully: ${response.data}');
      return response.data;
    } on DioException catch (e) {
      print('❌ Error deleting category: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  Future<void> toggleCategoryStatus(int categoryId) async {
    try {
      print('🔄 Toggling category status: $categoryId');
      final response = await _dio.put('/category/$categoryId/toggle-status');
      print('✅ Category status toggled successfully: ${response.data}');
    } on DioException catch (e) {
      print('❌ Error toggling category status: ${e.message}');
      print('❌ Error details: ${e.response?.data}');
      print('❌ Status code: ${e.response?.statusCode}');
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map<String, dynamic> && data.containsKey('message')) {
        return data['message'];
      }
    }
    return 'Đã xảy ra lỗi. Vui lòng thử lại sau.';
  }
}





