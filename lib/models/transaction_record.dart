class TransactionRecord {
  final String id;
  final String appointmentId;
  final String userId;
  final String salonId;
  final String type; // booking, cancellation, update
  final double amount;
  final String details;
  final DateTime createdAt;

  const TransactionRecord({
    required this.id,
    required this.appointmentId,
    required this.userId,
    required this.salonId,
    required this.type,
    required this.amount,
    required this.details,
    required this.createdAt,
  });

  factory TransactionRecord.fromMap(Map<String, dynamic> map) {
    return TransactionRecord(
      id: map['id'] ?? '',
      appointmentId: map['appointment_id'] ?? '',
      userId: map['user_id'] ?? '',
      salonId: map['salon_id'] ?? '',
      type: map['type'] ?? 'booking',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      details: map['details'] ?? '',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'appointment_id': appointmentId,
    'user_id': userId,
    'salon_id': salonId,
    'type': type,
    'amount': amount,
    'details': details,
    'created_at': createdAt.toIso8601String(),
  };
}
