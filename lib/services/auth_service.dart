import 'dart:async';
import '../models/user.dart';

class AuthService {
  // Simple auth state management for database integration
  final StreamController<User?> _controller = StreamController<User?>.broadcast();
  User? _currentUser;

  Stream<User?> get authStateChanges => _controller.stream;
  User? get currentUser => _currentUser;

  Future<void> setCurrentUser(User user) async {
    _currentUser = user;
    _controller.add(user);
  }

  Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  Future<void> logout() async {
    _controller.add(null);
  }

  void dispose() {
    _controller.close();
  }
}