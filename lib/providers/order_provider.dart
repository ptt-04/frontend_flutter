import 'package:flutter/foundation.dart';

class OrderProvider extends ChangeNotifier {
  List<dynamic> _orders = [];
  List<dynamic> _branches = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get orders => _orders;
  List<dynamic> get branches => _branches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock data
      _orders = [
        {
          'id': 1,
          'status': 'Hoàn thành',
          'createdAt': DateTime.now().subtract(const Duration(days: 2)),
          'items': [
            {'productName': 'Dầu gội đầu', 'quantity': 2},
            {'productName': 'Sáp vuốt tóc', 'quantity': 1},
          ],
          'paymentMethod': 'VNPay',
          'deliveryMethod': 'Giao hàng tận nơi',
          'totalAmount': 250000,
        },
        {
          'id': 2,
          'status': 'Đang giao',
          'createdAt': DateTime.now().subtract(const Duration(days: 1)),
          'items': [
            {'productName': 'Kem cạo râu', 'quantity': 1},
          ],
          'paymentMethod': 'Tiền mặt',
          'deliveryMethod': 'Nhận tại cửa hàng',
          'totalAmount': 150000,
        },
        {
          'id': 3,
          'status': 'Chờ xác nhận',
          'createdAt': DateTime.now().subtract(const Duration(hours: 3)),
          'items': [
            {'productName': 'Toner da mặt', 'quantity': 1},
            {'productName': 'Serum dưỡng tóc', 'quantity': 1},
          ],
          'paymentMethod': 'VNPay',
          'deliveryMethod': 'Giao hàng tận nơi',
          'totalAmount': 320000,
        },
      ];
    } catch (e) {
      _error = 'Không thể tải danh sách đơn hàng: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Update order status
      final orderIndex = _orders.indexWhere((order) => order['id'] == orderId);
      if (orderIndex != -1) {
        _orders[orderIndex]['status'] = 'Đã hủy';
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể hủy đơn hàng: $e';
      notifyListeners();
    }
  }

  Future<void> loadBranches() async {
    try {
      // Mock branches data
      _branches = [
        {'id': 1, 'name': 'Chi nhánh Quận 1', 'address': '123 Nguyễn Huệ, Q1, TP.HCM'},
        {'id': 2, 'name': 'Chi nhánh Quận 3', 'address': '456 Lê Văn Sỹ, Q3, TP.HCM'},
        {'id': 3, 'name': 'Chi nhánh Quận 7', 'address': '789 Nguyễn Thị Thập, Q7, TP.HCM'},
      ];
      notifyListeners();
    } catch (e) {
      _error = 'Không thể tải danh sách chi nhánh: $e';
      notifyListeners();
    }
  }

  Future<dynamic> createOrder(dynamic request) async {
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock order creation
      final newOrder = {
        'id': DateTime.now().millisecondsSinceEpoch,
        'status': 'Chờ xác nhận',
        'createdAt': DateTime.now(),
        'items': request['items'] ?? [],
        'paymentMethod': request['paymentMethod'] ?? 'Tiền mặt',
        'deliveryMethod': request['deliveryMethod'] ?? 'Nhận tại cửa hàng',
        'totalAmount': request['totalAmount'] ?? 0,
      };
      
      _orders.insert(0, newOrder);
      notifyListeners();
      
      return newOrder;
    } catch (e) {
      _error = 'Không thể tạo đơn hàng: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<dynamic> createVNPayPayment(dynamic request) async {
    try {
      // Simulate VNPay payment creation
      await Future.delayed(const Duration(seconds: 1));
      
      return {
        'paymentUrl': 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=1000000&vnp_Command=pay&vnp_CreateDate=20241201120000&vnp_CurrCode=VND&vnp_IpAddr=127.0.0.1&vnp_Locale=vn&vnp_OrderInfo=Thanh+toan+don+hang&vnp_OrderType=other&vnp_ReturnUrl=https://example.com/return&vnp_TmnCode=DEMO&vnp_TxnRef=1234567890&vnp_Version=2.1.0&vnp_SecureHash=hash',
        'orderId': request['orderId'],
      };
    } catch (e) {
      _error = 'Không thể tạo thanh toán VNPay: $e';
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}