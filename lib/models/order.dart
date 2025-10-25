class OrderItem {
  final int productId;
  final int quantity;

  OrderItem({
    required this.productId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
    };
  }
}

class CreateOrderRequest {
  final List<OrderItem> orderItems;
  final String paymentMethod;
  final String deliveryMethod;
  final int? branchId;
  final String? deliveryAddress;
  final String? deliveryPhone;
  final String? notes;
  final int? voucherId;
  final int? loyaltyPointsUsed;

  CreateOrderRequest({
    required this.orderItems,
    required this.paymentMethod,
    required this.deliveryMethod,
    this.branchId,
    this.deliveryAddress,
    this.deliveryPhone,
    this.notes,
    this.voucherId,
    this.loyaltyPointsUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderItems': orderItems.map((item) => item.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'deliveryMethod': deliveryMethod,
      'branchId': branchId,
      'deliveryAddress': deliveryAddress,
      'deliveryPhone': deliveryPhone,
      'notes': notes,
      'voucherId': voucherId,
      'loyaltyPointsUsed': loyaltyPointsUsed,
    };
  }
}

class OrderItemDetail {
  final int id;
  final int productId;
  final String productName;
  final String productImageUrl;
  final int quantity;
  final double unitPrice;
  final double? discountAmount;
  final double totalPrice;

  OrderItemDetail({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.quantity,
    required this.unitPrice,
    this.discountAmount,
    required this.totalPrice,
  });

  factory OrderItemDetail.fromJson(Map<String, dynamic> json) {
    return OrderItemDetail(
      id: json['id'],
      productId: json['productId'],
      productName: json['productName'],
      productImageUrl: json['productImageUrl'] ?? '',
      quantity: json['quantity'],
      unitPrice: json['unitPrice'].toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      totalPrice: json['totalPrice'].toDouble(),
    );
  }
}

class Order {
  final int id;
  final int userId;
  final String status;
  final double totalAmount;
  final double? discountAmount;
  final int? loyaltyPointsUsed;
  final int? loyaltyPointsEarned;
  final String paymentMethod;
  final String deliveryMethod;
  final int? branchId;
  final String? deliveryAddress;
  final String? deliveryPhone;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<OrderItemDetail> orderItems;

  Order({
    required this.id,
    required this.userId,
    required this.status,
    required this.totalAmount,
    this.discountAmount,
    this.loyaltyPointsUsed,
    this.loyaltyPointsEarned,
    required this.paymentMethod,
    required this.deliveryMethod,
    this.branchId,
    this.deliveryAddress,
    this.deliveryPhone,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    required this.orderItems,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['userId'],
      status: json['status'],
      totalAmount: json['totalAmount'].toDouble(),
      discountAmount: json['discountAmount']?.toDouble(),
      loyaltyPointsUsed: json['loyaltyPointsUsed'],
      loyaltyPointsEarned: json['loyaltyPointsEarned'],
      paymentMethod: json['paymentMethod'],
      deliveryMethod: json['deliveryMethod'],
      branchId: json['branchId'],
      deliveryAddress: json['deliveryAddress'],
      deliveryPhone: json['deliveryPhone'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      orderItems: (json['orderItems'] as List)
          .map((item) => OrderItemDetail.fromJson(item))
          .toList(),
    );
  }
}

class Branch {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  Branch({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      description: json['description'],
      isActive: json['isActive'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class VNPayPaymentRequest {
  final int orderId;
  final double amount;
  final String? returnUrl;

  VNPayPaymentRequest({
    required this.orderId,
    required this.amount,
    this.returnUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'amount': amount,
      'returnUrl': returnUrl,
    };
  }
}

class VNPayPaymentResponse {
  final String paymentUrl;
  final String orderId;
  final String transactionId;

  VNPayPaymentResponse({
    required this.paymentUrl,
    required this.orderId,
    required this.transactionId,
  });

  factory VNPayPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VNPayPaymentResponse(
      paymentUrl: json['paymentUrl'],
      orderId: json['orderId'],
      transactionId: json['transactionId'],
    );
  }
}
