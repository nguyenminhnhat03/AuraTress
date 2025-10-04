import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import '../models/user.dart';
import '../models/appointment.dart';

class DatabaseService {
  static Database? _database;
  static final DatabaseService _instance = DatabaseService._internal();
  
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'auratress.db');
    
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  Future<void> _createDatabase(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        full_name TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL DEFAULT 'customer',
        created_at TEXT NOT NULL
      )
    ''');

    // Appointments table
    await db.execute('''
      CREATE TABLE appointment (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        salon_id TEXT NOT NULL,
        salon_name TEXT NOT NULL,
        service TEXT NOT NULL,
        appointment_date TEXT NOT NULL,
        time_slot TEXT,
        status TEXT NOT NULL DEFAULT 'confirmed',
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Transactions table
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        appointment_id TEXT NOT NULL,
        user_id TEXT NOT NULL,
        salon_id TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL DEFAULT 0,
        details TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Insert demo accounts
    await _insertDemoAccounts(db);
  }

  Future<void> _insertDemoAccounts(Database db) async {
    final now = DateTime.now().toIso8601String();
    
    // Demo admin account (salon owner)
    await db.insert('users', {
      'id': 'admin_demo_001',
      'username': 'admin',
      'email': 'admin@auratress.com',
      'password_hash': _hashPassword('admin123'),
      'full_name': 'Admin User',
      'phone': '0901234567',
      'role': 'admin',
      'created_at': now,
    });

    // Demo customer account
    await db.insert('users', {
      'id': 'customer_demo_001', 
      'username': 'customer',
      'email': 'customer@gmail.com',
      'password_hash': _hashPassword('customer123'),
      'full_name': 'Nguyễn Văn A',
      'phone': '0987654321',
      'role': 'customer',
      'created_at': now,
    });

    // Demo appointments for customer
    await db.insert('appointment', {
      'id': 'appointment_001',
      'user_id': 'customer_demo_001',
      'salon_id': 'salon_lehieu_006',
      'salon_name': 'Le Hieu Salon',
      'service': 'AI Color Consultation',
      'appointment_date': DateTime.now().add(const Duration(days: 5)).toIso8601String(),
      'time_slot': '2:00 PM',
      'status': 'confirmed',
      'created_at': now,
    });

    await db.insert('appointment', {
      'id': 'appointment_002',
      'user_id': 'customer_demo_001',
      'salon_id': 'salon_traky_004',
      'salon_name': 'Traky Hair Salon',
      'service': 'Premium Cut & Style',
      'appointment_date': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      'time_slot': '10:30 AM',
      'status': 'completed',
      'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    });
  }

  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS transactions (
          id TEXT PRIMARY KEY,
          appointment_id TEXT NOT NULL,
          user_id TEXT NOT NULL,
          salon_id TEXT NOT NULL,
          type TEXT NOT NULL,
          amount REAL NOT NULL DEFAULT 0,
          details TEXT,
          created_at TEXT NOT NULL
        )
      ''');
    }
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode('${password}auratress_salt');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // User authentication methods
  Future<User?> loginUser(String username, String password) async {
    final db = await database;
    final hashedPassword = _hashPassword(password);
    
    final results = await db.query(
      'users',
      where: '(username = ? OR email = ?) AND password_hash = ?',
      whereArgs: [username, username, hashedPassword],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  Future<User?> registerUser({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'customer',
  }) async {
    final db = await database;
    
    // Check if username or email already exists
    final existing = await db.query(
      'users',
      where: 'username = ? OR email = ?',
      whereArgs: [username, email],
    );

    if (existing.isNotEmpty) {
      throw Exception('Username or email already exists');
    }

    final userId = 'user_${DateTime.now().millisecondsSinceEpoch}';
    final hashedPassword = _hashPassword(password);
    
    await db.insert('users', {
      'id': userId,
      'username': username,
      'email': email,
      'password_hash': hashedPassword,
      'full_name': fullName,
      'phone': phone ?? '',
      'role': role,
      'created_at': DateTime.now().toIso8601String(),
    });

    return await getUserById(userId);
  }

  Future<User?> getUserById(String userId) async {
    final db = await database;
    final results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (results.isNotEmpty) {
      return User.fromMap(results.first);
    }
    return null;
  }

  // Appointment methods
  Future<String> createAppointment({
    required String userId,
    required String salonId,
    required String salonName,
    required String service,
    required DateTime appointmentDate,
    String? timeSlot,
  }) async {
    final db = await database;

    // Prevent double booking at the same salon/time (non-cancelled)
    final conflict = await db.query(
      'appointments',
      where: 'salon_id = ? AND appointment_date = ? AND status != ?',
      whereArgs: [salonId, appointmentDate.toIso8601String(), 'cancelled'],
      limit: 1,
    );
    if (conflict.isNotEmpty) {
      throw Exception('Khung giờ đã được đặt tại salon này. Vui lòng chọn thời gian khác.');
    }

    final appointmentId = 'appointment_${DateTime.now().millisecondsSinceEpoch}';
    
    await db.insert('appointments', {
      'id': appointmentId,
      'user_id': userId,
      'salon_id': salonId,
      'salon_name': salonName,
      'service': service,
      'appointment_date': appointmentDate.toIso8601String(),
      'time_slot': timeSlot ?? '',
      'status': 'confirmed',
      'created_at': DateTime.now().toIso8601String(),
    });

    // Record booking transaction
    await db.insert('transactions', {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'appointment_id': appointmentId,
      'user_id': userId,
      'salon_id': salonId,
      'type': 'booking',
      'amount': 0.0,
      'details': 'Booked service: $service at $salonName (${timeSlot ?? ''})',
      'created_at': DateTime.now().toIso8601String(),
    });

    return appointmentId;
  }

  Future<List<Appointment>> getUserAppointments(String userId) async {
    final db = await database;
    final results = await db.query(
      'appointments',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'appointment_date DESC',
    );

    return results.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<List<Appointment>> getSalonAppointments(String salonId) async {
    final db = await database;
    final results = await db.query(
      'appointments',
      where: 'salon_id = ?',
      whereArgs: [salonId],
      orderBy: 'appointment_date DESC',
    );

    return results.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<List<Appointment>> getAllAppointments() async {
    final db = await database;
    final results = await db.query(
      'appointments',
      orderBy: 'appointment_date DESC',
    );

    return results.map((map) => Appointment.fromMap(map)).toList();
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    final db = await database;
    await db.update(
      'appointments',
      {'status': status},
      where: 'id = ?',
      whereArgs: [appointmentId],
    );
  }

  Future<void> cancelAppointment(String appointmentId) async {
    final db = await database;
    // Get appointment details
    final res = await db.query('appointments', where: 'id = ?', whereArgs: [appointmentId]);
    if (res.isEmpty) return;
    final appt = res.first;
    await db.update('appointments', {'status': 'cancelled'}, where: 'id = ?', whereArgs: [appointmentId]);
    await db.insert('transactions', {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'appointment_id': appointmentId,
      'user_id': appt['user_id'],
      'salon_id': appt['salon_id'],
      'type': 'cancellation',
      'amount': 0.0,
      'details': 'Cancelled appointment ${appt['service']}',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateAppointmentSchedule(String appointmentId, DateTime newDate, String? newTimeSlot) async {
    final db = await database;
    final res = await db.query('appointments', where: 'id = ?', whereArgs: [appointmentId]);
    if (res.isEmpty) return;
    final appt = res.first;
    await db.update('appointments', {
      'appointment_date': newDate.toIso8601String(),
      'time_slot': newTimeSlot ?? appt['time_slot'],
    }, where: 'id = ?', whereArgs: [appointmentId]);
    await db.insert('transactions', {
      'id': 'txn_${DateTime.now().millisecondsSinceEpoch}',
      'appointment_id': appointmentId,
      'user_id': appt['user_id'],
      'salon_id': appt['salon_id'],
      'type': 'update',
      'amount': 0.0,
      'details': 'Rescheduled appointment to ${newDate.toIso8601String()} (${newTimeSlot ?? appt['time_slot']})',
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, dynamic>>> getUserTransactions(String userId) async {
    final db = await database;
    return await db.query('transactions', where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getSalonTransactions(String salonId) async {
    final db = await database;
    return await db.query('transactions', where: 'salon_id = ?', whereArgs: [salonId], orderBy: 'created_at DESC');
  }

  Future<List<User>> getAllUsers() async {
    final db = await database;
    final results = await db.query('users', orderBy: 'created_at DESC');
    return results.map((map) => User.fromMap(map)).toList();
  }

  // Simple mapping: which salon an admin manages (demo)
  String? getSalonIdForAdmin(String userId) {
    // In a real app, this would be stored in DB. For demo, default to Le Hieu.
    if (userId == 'admin_demo_001') return 'salon_lehieu_006';
    return 'salon_lehieu_006';
  }

  // Clear database (for testing)
  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('appointments');
    await db.delete('users');
    await _insertDemoAccounts(db);
  }
}