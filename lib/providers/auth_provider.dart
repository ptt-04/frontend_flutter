import 'package:flutter/foundation.dart';
import 'dart:io';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  // Role checking methods
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isBarber => _user?.isBarber ?? false;
  bool get isCustomer => _user?.isCustomer ?? false;
  
  bool get isAdminOrBarber => _user?.isAdminOrBarber ?? false;
  bool get isAdminOrCustomer => _user?.isAdminOrCustomer ?? false;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setUser(User? user) {
    _user = user;
    notifyListeners();
  }

  Future<bool> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final authResponse = await _apiService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      _setUser(authResponse.user);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
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
      _setLoading(true);
      _setError(null);

      final authResponse = await _apiService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      _setUser(authResponse.user);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.logout();
      _setUser(null);
      _setError(null);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> loadUserProfile() async {
    try {
      _setLoading(true);
      _setError(null);

      final user = await _apiService.getProfile();
      _setUser(user);
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = await _apiService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      _setUser(updatedUser);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> uploadProfileImage(File imageFile) async {
    try {
      _setLoading(true);
      _setError(null);

      final imageUrl = await _apiService.uploadProfileImage(imageFile);
      if (imageUrl != null && _user != null) {
        // Update user with new profile image URL
        final updatedUser = User(
          id: _user!.id,
          username: _user!.username,
          email: _user!.email,
          firstName: _user!.firstName,
          lastName: _user!.lastName,
          phoneNumber: _user!.phoneNumber ?? '',
          dateOfBirth: _user!.dateOfBirth,
          gender: _user!.gender,
          role: _user!.role,
          loyaltyPoints: _user!.loyaltyPoints,
          createdAt: _user!.createdAt,
          profileImageUrl: imageUrl,
        );
        _setUser(updatedUser);
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearError() {
    _setError(null);
  }
}

