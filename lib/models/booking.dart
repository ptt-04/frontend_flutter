class Service {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationMinutes;
  final String? imageUrl;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationMinutes,
    this.imageUrl,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] is int) ? json['price'].toDouble() : json['price'].toDouble(),
      durationMinutes: json['durationMinutes'],
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'durationMinutes': durationMinutes,
      'imageUrl': imageUrl,
    };
  }
}

class Booking {
  final int id;
  final int userId;
  final int serviceId;
  final int? barberId; // Thêm barberId
  final int? branchId; // Thêm branchId
  final DateTime bookingDateTime;
  final String status;
  final String? notes;
  final double totalPrice;
  final int? loyaltyPointsUsed;
  final int? loyaltyPointsEarned;
  final DateTime createdAt;
  final Service service;

  Booking({
    required this.id,
    required this.userId,
    required this.serviceId,
    this.barberId,
    this.branchId,
    required this.bookingDateTime,
    required this.status,
    this.notes,
    required this.totalPrice,
    this.loyaltyPointsUsed,
    this.loyaltyPointsEarned,
    required this.createdAt,
    required this.service,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['userId'],
      serviceId: json['serviceId'],
      barberId: json['barberId'],
      branchId: json['branchId'],
      bookingDateTime: DateTime.parse(json['bookingDateTime']),
      status: json['status'],
      notes: json['notes'],
      totalPrice: json['totalPrice'].toDouble(),
      loyaltyPointsUsed: json['loyaltyPointsUsed'],
      loyaltyPointsEarned: json['loyaltyPointsEarned'],
      createdAt: DateTime.parse(json['createdAt']),
      service: Service.fromJson(json['service']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'serviceId': serviceId,
      'barberId': barberId,
      'branchId': branchId,
      'bookingDateTime': bookingDateTime.toIso8601String(),
      'status': status,
      'notes': notes,
      'totalPrice': totalPrice,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'createdAt': createdAt.toIso8601String(),
      'service': service.toJson(),
    };
  }
}

class CreateBookingRequest {
  final int serviceId;
  final DateTime bookingDateTime;
  final String? notes;
  final int? loyaltyPointsUsed;

  CreateBookingRequest({
    required this.serviceId,
    required this.bookingDateTime,
    this.notes,
    this.loyaltyPointsUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'bookingDateTime': bookingDateTime.toIso8601String(),
      'notes': notes,
      'loyaltyPointsUsed': loyaltyPointsUsed,
    };
  }
}





