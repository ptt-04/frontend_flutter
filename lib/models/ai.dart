class HairStyleRequest {
  final int userId;
  final String faceShape; // Oval, Round, Square, Heart, Diamond
  final String hairType; // Straight, Wavy, Curly, Coily
  final String hairLength; // Short, Medium, Long
  final int age;
  final String gender;
  final String stylePreference; // Casual, Formal, Trendy, Classic

  HairStyleRequest({
    required this.userId,
    required this.faceShape,
    required this.hairType,
    required this.hairLength,
    required this.age,
    required this.gender,
    required this.stylePreference,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'faceShape': faceShape,
      'hairType': hairType,
      'hairLength': hairLength,
      'age': age,
      'gender': gender,
      'stylePreference': stylePreference,
    };
  }
}

class HairStyleSuggestion {
  final int id;
  final int userId;
  final String faceShape;
  final String hairType;
  final String hairLength;
  final String suggestedStyles;
  final String? description;
  final String? imageUrl;
  final DateTime createdAt;

  HairStyleSuggestion({
    required this.id,
    required this.userId,
    required this.faceShape,
    required this.hairType,
    required this.hairLength,
    required this.suggestedStyles,
    this.description,
    this.imageUrl,
    required this.createdAt,
  });

  factory HairStyleSuggestion.fromJson(Map<String, dynamic> json) {
    return HairStyleSuggestion(
      id: json['id'],
      userId: json['userId'],
      faceShape: json['faceShape'],
      hairType: json['hairType'],
      hairLength: json['hairLength'],
      suggestedStyles: json['suggestedStyles'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'faceShape': faceShape,
      'hairType': hairType,
      'hairLength': hairLength,
      'suggestedStyles': suggestedStyles,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AIChatMessage {
  final String message;
  final bool isUser;
  final String? imagePath;

  AIChatMessage({
    required this.message,
    required this.isUser,
    this.imagePath,
  });

  factory AIChatMessage.fromJson(Map<String, dynamic> json) {
    return AIChatMessage(
      message: json['message'] as String,
      isUser: json['isUser'] as bool,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'isUser': isUser,
      'imagePath': imagePath,
    };
  }
}

class ChatRequest {
  final String message;

  ChatRequest({
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
