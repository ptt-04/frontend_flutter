enum Role {
  customer(1),
  barber(2),
  admin(3);

  const Role(this.value);
  final int value;

  static Role fromValue(int value) {
    return Role.values.firstWhere((role) => role.value == value);
  }

  String get displayName {
    switch (this) {
      case Role.customer:
        return 'Khách hàng';
      case Role.barber:
        return 'Thợ cắt tóc';
      case Role.admin:
        return 'Quản trị viên';
    }
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final String? profileImageUrl;
  final int loyaltyPoints;
  final DateTime createdAt;
  final Role role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    this.profileImageUrl,
    required this.loyaltyPoints,
    required this.createdAt,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNumber: json['phoneNumber'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      profileImageUrl: json['profileImageUrl'],
      loyaltyPoints: json['loyaltyPoints'],
      createdAt: DateTime.parse(json['createdAt']),
      role: Role.fromValue(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'profileImageUrl': profileImageUrl,
      'loyaltyPoints': loyaltyPoints,
      'createdAt': createdAt.toIso8601String(),
      'role': role.value,
    };
  }

  String get fullName => '$firstName $lastName';
  
  // Role checking methods
  bool get isAdmin => role == Role.admin;
  bool get isBarber => role == Role.barber;
  bool get isCustomer => role == Role.customer;
  
  bool get isAdminOrBarber => isAdmin || isBarber;
  bool get isAdminOrCustomer => isAdmin || isCustomer;
}

class AuthResponse {
  final String token;
  final DateTime expiresAt;
  final User user;

  AuthResponse({
    required this.token,
    required this.expiresAt,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'],
      expiresAt: DateTime.parse(json['expiresAt']),
      user: User.fromJson(json['user']),
    );
  }
}

