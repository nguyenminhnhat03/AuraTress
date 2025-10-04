import 'package:intl/intl.dart';

class Appointment {
  final String id;
  final String userId;
  final String salonId;
  final String salonName;
  final String service;
  final DateTime date;
  final String timeSlot;
  final String status;
  final DateTime createdAt;

  const Appointment({
    required this.id,
    required this.userId,
    required this.salonId,
    required this.salonName,
    required this.service,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
  });

  String get formattedDate => DateFormat('dd/MM/yyyy').format(date);

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      salonId: json['salonId'] ?? '',
      salonName: json['salonName'] ?? '',
      service: json['service'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      timeSlot: json['timeSlot'] ?? '',
      status: json['status'] ?? 'confirmed',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      salonId: map['salon_id'] ?? '',
      salonName: map['salon_name'] ?? '',
      service: map['service'] ?? '',
      date: DateTime.parse(map['appointment_date'] ?? DateTime.now().toIso8601String()),
      timeSlot: map['time_slot'] ?? '',
      status: map['status'] ?? 'confirmed',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'salonId': salonId,
    'salonName': salonName,
    'service': service,
    'date': date.toIso8601String(),
    'timeSlot': timeSlot,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'salon_id': salonId,
    'salon_name': salonName,
    'service': service,
    'appointment_date': date.toIso8601String(),
    'time_slot': timeSlot,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isUpcoming => date.isAfter(DateTime.now());
  bool get isPast => date.isBefore(DateTime.now());
  bool get isToday => 
    date.year == DateTime.now().year &&
    date.month == DateTime.now().month &&
    date.day == DateTime.now().day;
}