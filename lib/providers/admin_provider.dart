import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/dashboard_stats.dart';
import '../models/voucher.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class AdminProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<User> _users = [];
  List<Voucher> _vouchers = [];
  List<UserVoucher> _userVouchers = [];
  List<Booking> _bookings = [];
  DashboardStats? _dashboardStats;
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  List<Voucher> get vouchers => _vouchers;
  List<UserVoucher> get userVouchers => _userVouchers;
  List<Booking> get bookings => _bookings;
  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> loadUsers() async {
    try {
      _setLoading(true);
      _setError(null);

      final users = await _apiService.getUsers();
      _users = users;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadDashboardStats() async {
    try {
      _setLoading(true);
      _setError(null);

      final statsData = await _apiService.getDashboardStats();
      _dashboardStats = DashboardStats.fromJson(statsData);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBarber({
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

      final barber = await _apiService.createBarber(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );

      if (barber != null) {
        _users.add(barber);
        notifyListeners();
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

  Future<bool> updateUserRole(int userId, Role role) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _apiService.updateUserRole(userId, role);
      
      if (success) {
        final index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = User(
            id: _users[index].id,
            username: _users[index].username,
            email: _users[index].email,
            firstName: _users[index].firstName,
            lastName: _users[index].lastName,
            phoneNumber: _users[index].phoneNumber,
            dateOfBirth: _users[index].dateOfBirth,
            gender: _users[index].gender,
            profileImageUrl: _users[index].profileImageUrl,
            loyaltyPoints: _users[index].loyaltyPoints,
            createdAt: _users[index].createdAt,
            role: role,
          );
          notifyListeners();
        }
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

  Future<bool> updateUser({
    required int userId,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    required DateTime dateOfBirth,
    required String gender,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedUser = await _apiService.updateUser(
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        dateOfBirth: dateOfBirth,
        gender: gender,
      );
      
      if (updatedUser != null) {
        final index = _users.indexWhere((user) => user.id == userId);
        if (index != -1) {
          _users[index] = updatedUser;
          notifyListeners();
        }
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

  Future<bool> deleteUser(int userId) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _apiService.deleteUser(userId);
      
      if (success) {
        _users.removeWhere((user) => user.id == userId);
        notifyListeners();
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

  List<User> getCustomers() {
    return _users.where((user) => user.isCustomer).toList();
  }

  List<User> getBarbers() {
    return _users.where((user) => user.isBarber).toList();
  }

  List<User> getAdmins() {
    return _users.where((user) => user.isAdmin).toList();
  }

  // Voucher management methods
  Future<void> loadVouchers() async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Loading vouchers...');
      final vouchers = await _apiService.getAllVouchers();
      print('✅ Loaded ${vouchers.length} vouchers: ${vouchers.map((v) => v.name).toList()}');
      _vouchers = vouchers;
    } catch (e) {
      print('❌ Error loading vouchers: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadUserVouchers() async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Loading user vouchers...');
      final userVouchers = await _apiService.getAllUserVouchers();
      print('✅ Loaded ${userVouchers.length} user vouchers');
      _userVouchers = userVouchers;
    } catch (e) {
      print('❌ Error loading user vouchers: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createVoucher(CreateVoucherDto voucherDto) async {
    try {
      _setLoading(true);
      _setError(null);

      final voucher = await _apiService.createVoucher(voucherDto);
      if (voucher != null) {
        // Reload vouchers from server to ensure sync
        await loadVouchers();
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

  Future<bool> updateVoucher(int id, CreateVoucherDto voucherDto) async {
    try {
      _setLoading(true);
      _setError(null);

      final updatedVoucher = await _apiService.updateVoucher(id, voucherDto);
      if (updatedVoucher != null) {
        // Reload vouchers from server to ensure sync
        await loadVouchers();
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

  Future<bool> deleteVoucher(int id) async {
    try {
      _setLoading(true);
      _setError(null);

      final success = await _apiService.deleteVoucher(id);
      if (success) {
        // Reload vouchers from server to ensure sync
        await loadVouchers();
      }
      return success;
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

  // Booking management methods
  Future<void> loadAllBookings() async {
    try {
      _setLoading(true);
      _setError(null);

      print('🔄 Loading all bookings...');
      final bookingsData = await _apiService.getAllBookings();
      print('📦 Raw bookings data: $bookingsData');
      
      _bookings = bookingsData.map((data) => Booking.fromJson(data)).toList();
      print('✅ Loaded ${_bookings.length} bookings');
    } catch (e) {
      print('❌ Error loading bookings: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  List<Booking> getBookingsByStatus(String status) {
    return _bookings.where((booking) => booking.status == status).toList();
  }

  List<Booking> getPendingBookings() {
    return getBookingsByStatus('Pending');
  }

  List<Booking> getConfirmedBookings() {
    return getBookingsByStatus('Confirmed');
  }

  List<Booking> getCompletedBookings() {
    return getBookingsByStatus('Completed');
  }

  List<Booking> getCancelledBookings() {
    return getBookingsByStatus('Cancelled');
  }

  Future<bool> confirmBooking(int bookingId) async {
    try {
      await _apiService.confirmBooking(bookingId);
      // Reload bookings to get updated data
      await loadAllBookings();
      return true;
    } catch (e) {
      print('❌ Error confirming booking: $e');
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> completeBooking(int bookingId, {int? loyaltyPointsEarned}) async {
    try {
      await _apiService.completeBooking(bookingId, loyaltyPointsEarned: loyaltyPointsEarned);
      // Reload bookings to get updated data
      await loadAllBookings();
      return true;
    } catch (e) {
      print('❌ Error completing booking: $e');
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      await _apiService.adminCancelBooking(bookingId);
      // Reload bookings to get updated data
      await loadAllBookings();
      return true;
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      _setError(e.toString());
      return false;
    }
  }
}

