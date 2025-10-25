class Voucher {
  final int id;
  final String code;
  final String name;
  final String description;
  final double discountAmount;
  final String discountType; // "Percentage" or "Fixed"
  final double minimumOrderAmount;
  final int maxUsageCount;
  final int usedCount;
  final DateTime validFrom;
  final DateTime validTo;
  final DateTime createdAt;

  Voucher({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.discountAmount,
    required this.discountType,
    required this.minimumOrderAmount,
    required this.maxUsageCount,
    required this.usedCount,
    required this.validFrom,
    required this.validTo,
    required this.createdAt,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      description: json['description'],
      discountAmount: (json['discountAmount'] as num).toDouble(),
      discountType: json['discountType'],
      minimumOrderAmount: (json['minimumOrderAmount'] as num).toDouble(),
      maxUsageCount: json['maxUsageCount'],
      usedCount: json['usedCount'],
      validFrom: DateTime.parse(json['validFrom']),
      validTo: DateTime.parse(json['validTo']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'discountAmount': discountAmount,
      'discountType': discountType,
      'minimumOrderAmount': minimumOrderAmount,
      'maxUsageCount': maxUsageCount,
      'usedCount': usedCount,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isValid {
    final now = DateTime.now();
    return now.isAfter(validFrom) && now.isBefore(validTo) && usedCount < maxUsageCount;
  }

  bool get isPercentage => discountType.toLowerCase() == 'percentage';
  bool get isFixed => discountType.toLowerCase() == 'fixed';

  double calculateDiscount(double orderAmount) {
    if (orderAmount < minimumOrderAmount) return 0;
    
    if (isPercentage) {
      return orderAmount * (discountAmount / 100);
    } else {
      return discountAmount;
    }
  }
}

class UserVoucher {
  final int id;
  final int userId;
  final int voucherId;
  final DateTime? usedAt;
  final int? orderId;
  final DateTime createdAt;
  final Voucher voucher;

  UserVoucher({
    required this.id,
    required this.userId,
    required this.voucherId,
    this.usedAt,
    this.orderId,
    required this.createdAt,
    required this.voucher,
  });

  factory UserVoucher.fromJson(Map<String, dynamic> json) {
    return UserVoucher(
      id: json['id'],
      userId: json['userId'],
      voucherId: json['voucherId'],
      usedAt: json['usedAt'] != null ? DateTime.parse(json['usedAt']) : null,
      orderId: json['orderId'],
      createdAt: DateTime.parse(json['createdAt']),
      voucher: json['voucher'] != null ? Voucher.fromJson(json['voucher']) : Voucher(
        id: json['voucherId'],
        code: 'N/A',
        name: 'N/A',
        description: 'N/A',
        discountAmount: 0,
        discountType: 'Percentage',
        minimumOrderAmount: 0,
        maxUsageCount: 0,
        usedCount: 0,
        validFrom: DateTime.now(),
        validTo: DateTime.now(),
        createdAt: DateTime.now(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'voucherId': voucherId,
      'usedAt': usedAt?.toIso8601String(),
      'orderId': orderId,
      'createdAt': createdAt.toIso8601String(),
      'voucher': voucher.toJson(),
    };
  }

  bool get isUsed => usedAt != null;
  bool get isAvailable => !isUsed && voucher.isValid;
}

class CreateVoucherDto {
  final String code;
  final String name;
  final String description;
  final double discountAmount;
  final String discountType;
  final double minimumOrderAmount;
  final int maxUsageCount;
  final DateTime validFrom;
  final DateTime validTo;

  CreateVoucherDto({
    required this.code,
    required this.name,
    required this.description,
    required this.discountAmount,
    required this.discountType,
    required this.minimumOrderAmount,
    required this.maxUsageCount,
    required this.validFrom,
    required this.validTo,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'description': description,
      'discountAmount': discountAmount,
      'discountType': discountType,
      'minimumOrderAmount': minimumOrderAmount,
      'maxUsageCount': maxUsageCount,
      'validFrom': validFrom.toIso8601String(),
      'validTo': validTo.toIso8601String(),
    };
  }
}

