class User {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String fullName;
  final String role;
  final DateTime createdAt;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'customer',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      fullName: map['full_name'] ?? '',
      role: map['role'] ?? 'customer',
      createdAt: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'phone': phone,
    'fullName': fullName,
    'role': role,
    'createdAt': createdAt.toIso8601String(),
  };

  Map<String, dynamic> toMap() => {
    'id': id,
    'username': username,
    'email': email,
    'phone': phone,
    'full_name': fullName,
    'role': role,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isAdmin => role == 'admin';
  bool get isCustomer => role == 'customer';

  // For backward compatibility
  int get level => 1; // Default level
  Map<String, dynamic> get appointments => {}; // Empty for now
}

// Extension for copyWith
extension UserCopyWith on User {
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? phone,
    String? fullName,
    String? role,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
