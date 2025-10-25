class DashboardStats {
  final int totalUsers;
  final int totalProducts;
  final int todayBookings;
  final double monthlyRevenue;
  final int customersCount;
  final int barbersCount;
  final int adminsCount;
  final int pendingBookings;
  final int confirmedBookings;
  final int completedBookings;
  final int cancelledBookings;

  DashboardStats({
    required this.totalUsers,
    required this.totalProducts,
    required this.todayBookings,
    required this.monthlyRevenue,
    required this.customersCount,
    required this.barbersCount,
    required this.adminsCount,
    required this.pendingBookings,
    required this.confirmedBookings,
    required this.completedBookings,
    required this.cancelledBookings,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalUsers: json['totalUsers'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      todayBookings: json['todayBookings'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0).toDouble(),
      customersCount: json['customersCount'] ?? 0,
      barbersCount: json['barbersCount'] ?? 0,
      adminsCount: json['adminsCount'] ?? 0,
      pendingBookings: json['pendingBookings'] ?? 0,
      confirmedBookings: json['confirmedBookings'] ?? 0,
      completedBookings: json['completedBookings'] ?? 0,
      cancelledBookings: json['cancelledBookings'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalUsers': totalUsers,
      'totalProducts': totalProducts,
      'todayBookings': todayBookings,
      'monthlyRevenue': monthlyRevenue,
      'customersCount': customersCount,
      'barbersCount': barbersCount,
      'adminsCount': adminsCount,
      'pendingBookings': pendingBookings,
      'confirmedBookings': confirmedBookings,
      'completedBookings': completedBookings,
      'cancelledBookings': cancelledBookings,
    };
  }
}
