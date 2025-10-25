import 'package:flutter/foundation.dart';
import '../models/voucher.dart';
import '../services/api_service.dart';

class VoucherProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  List<Voucher> _availableVouchers = [];
  List<UserVoucher> _myVouchers = [];
  bool _isLoading = false;
  String? _error;

  List<Voucher> get availableVouchers => _availableVouchers;
  List<UserVoucher> get myVouchers => _myVouchers;
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

  Future<void> loadAvailableVouchers() async {
    try {
      _setLoading(true);
      _setError(null);

      final vouchers = await _apiService.getAvailableVouchers();
      _availableVouchers = vouchers;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyVouchers() async {
    try {
      _setLoading(true);
      _setError(null);

      final vouchers = await _apiService.getMyVouchers();
      _myVouchers = vouchers;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> assignVoucher(int voucherId) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.assignVoucher(voucherId);
      
      // Reload vouchers after assignment
      await loadAvailableVouchers();
      await loadMyVouchers();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> useVoucher(int voucherId, {int? orderId}) async {
    try {
      _setLoading(true);
      _setError(null);

      await _apiService.useVoucher(voucherId, orderId: orderId);
      
      // Reload my vouchers after use
      await loadMyVouchers();
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  List<UserVoucher> getAvailableUserVouchers() {
    return _myVouchers.where((v) => v.isAvailable).toList();
  }

  List<UserVoucher> getUsedVouchers() {
    return _myVouchers.where((v) => v.isUsed).toList();
  }

  Future<List<Map<String, dynamic>>> getMyVouchersMap() async {
    try {
      final vouchers = await _apiService.getMyVouchers();
      return vouchers.map((voucher) => {
        'id': voucher.id,
        'code': voucher.voucher.code,
        'discountAmount': voucher.voucher.discountAmount,
        'isAvailable': voucher.isAvailable,
      }).toList();
    } catch (e) {
      _setError(e.toString());
      return [];
    }
  }

  void clearError() {
    _setError(null);
  }
}

