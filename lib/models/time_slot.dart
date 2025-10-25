class TimeSlot {
  final int id;
  final int barberId;
  final DateTime startTime;
  final DateTime endTime;
  final bool isAvailable;
  final String? notes;
  final DateTime createdAt;

  TimeSlot({
    required this.id,
    required this.barberId,
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
    this.notes,
    required this.createdAt,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      id: json['id'],
      barberId: json['barberId'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      isAvailable: json['isAvailable'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barberId': barberId,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isAvailable': isAvailable,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get timeRange {
    final start = '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
    final end = '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}';
    return '$start - $end';
  }

  String get dateString {
    return '${startTime.day}/${startTime.month}/${startTime.year}';
  }

  Duration get duration => endTime.difference(startTime);
}

