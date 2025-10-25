import 'package:flutter/foundation.dart';
import '../models/booking.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Booking> _bookings = [];
  List<Service> _services = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  List<Service> get services => _services;
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

  Future<void> loadUserBookings() async {
    try {
      _setLoading(true);
      _setError(null);

      final bookingsData = await _apiService.getMyBookings();
      _bookings = bookingsData.map((data) => Booking.fromJson(data)).toList();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadServices() async {
    try {
      _setLoading(true);
      _setError(null);
      _services.clear(); // Clear previous services

      print('🔄 Loading services from API...');
      final servicesData = await _apiService.getServices();
      print('📦 Raw services data: $servicesData');
      
      if (servicesData.isEmpty) {
        print('⚠️ No services data received');
        return;
      }
      
      _services = servicesData.map((data) {
        print('🔍 Parsing service: $data');
        try {
          return Service.fromJson(data);
        } catch (parseError) {
          print('❌ Error parsing service $data: $parseError');
          rethrow;
        }
      }).toList();
      
      print('✅ Successfully loaded ${_services.length} services');
    } catch (e) {
      print('❌ Error loading services: $e');
      _setError('Không thể tải danh sách dịch vụ: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createBooking({
    required int serviceId,
    int? barberId,
    required DateTime bookingDateTime,
    String? notes,
    int? loyaltyPointsUsed,
  }) async {
    try {
      _setLoading(true);
      _setError(null);

      final bookingData = await _apiService.createBooking(
        serviceId: serviceId,
        barberId: barberId,
        bookingDateTime: bookingDateTime,
        notes: notes,
        loyaltyPointsUsed: loyaltyPointsUsed,
      );
      final booking = Booking.fromJson(bookingData);
      _bookings.insert(0, booking);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> confirmBooking(int bookingId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.confirmBooking(bookingId);
      
      // Update local booking status
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = Booking(
          id: _bookings[index].id,
          userId: _bookings[index].userId,
          serviceId: _bookings[index].serviceId,
          bookingDateTime: _bookings[index].bookingDateTime,
          status: 'Confirmed',
          notes: _bookings[index].notes,
          totalPrice: _bookings[index].totalPrice,
          loyaltyPointsUsed: _bookings[index].loyaltyPointsUsed,
          loyaltyPointsEarned: _bookings[index].loyaltyPointsEarned,
          createdAt: _bookings[index].createdAt,
          service: _bookings[index].service,
        );
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

  Future<bool> completeBooking(int bookingId, {int? loyaltyPointsEarned}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.completeBooking(bookingId, loyaltyPointsEarned: loyaltyPointsEarned);
      
      // Update local booking status and loyalty points
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = Booking(
          id: _bookings[index].id,
          userId: _bookings[index].userId,
          serviceId: _bookings[index].serviceId,
          bookingDateTime: _bookings[index].bookingDateTime,
          status: 'Completed',
          notes: _bookings[index].notes,
          totalPrice: _bookings[index].totalPrice,
          loyaltyPointsUsed: _bookings[index].loyaltyPointsUsed,
          loyaltyPointsEarned: loyaltyPointsEarned ?? _bookings[index].loyaltyPointsEarned,
          createdAt: _bookings[index].createdAt,
          service: _bookings[index].service,
        );
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

  Future<bool> cancelBooking(int bookingId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.cancelBooking(bookingId);
      
      // Update local booking status
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        _bookings[index] = Booking(
          id: _bookings[index].id,
          userId: _bookings[index].userId,
          serviceId: _bookings[index].serviceId,
          bookingDateTime: _bookings[index].bookingDateTime,
          status: 'Cancelled',
          notes: _bookings[index].notes,
          totalPrice: _bookings[index].totalPrice,
          loyaltyPointsUsed: _bookings[index].loyaltyPointsUsed,
          loyaltyPointsEarned: _bookings[index].loyaltyPointsEarned,
          createdAt: _bookings[index].createdAt,
          service: _bookings[index].service,
        );
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

  List<Booking> getPendingBookings() {
    return _bookings.where((b) => b.status == 'Pending').toList();
  }

  List<Booking> getConfirmedBookings() {
    return _bookings.where((b) => b.status == 'Confirmed').toList();
  }

  List<Booking> getCompletedBookings() {
    return _bookings.where((b) => b.status == 'Completed').toList();
  }

  List<Booking> getCancelledBookings() {
    return _bookings.where((b) => b.status == 'Cancelled').toList();
  }

  Future<List<Map<String, dynamic>>> getBarbers() async {
    try {
      return await _apiService.getBarbers();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  void clearError() {
    _setError(null);
  }
}





