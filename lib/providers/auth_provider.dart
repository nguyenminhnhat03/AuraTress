import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../models/user.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final databaseServiceProvider = Provider<DatabaseService>((ref) => DatabaseService());

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(() => AuthNotifier());

class AuthNotifier extends AsyncNotifier<User?> {
  late final AuthService authService;
  late final DatabaseService databaseService;
  StreamSubscription<User?>? _subscription;

  @override
  FutureOr<User?> build() {
    authService = ref.watch(authServiceProvider);
    databaseService = ref.watch(databaseServiceProvider);
    
    _subscription = authService.authStateChanges.listen(
      (user) => state = AsyncValue.data(user),
      onError: (error, stack) => state = AsyncValue.error(error.toString(), stack),
    );
    
    return null;
  }

  Future<void> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String role = 'customer',
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await databaseService.registerUser(
        username: username,
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
      );
      if (user != null) {
        await authService.setCurrentUser(user);
        state = AsyncValue.data(user);
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();
    try {
      final user = await databaseService.loginUser(username, password);
      if (user != null) {
        await authService.setCurrentUser(user);
        state = AsyncValue.data(user);
      } else {
        throw Exception('Invalid username or password');
      }
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> logout() async {
    await authService.logout();
  }

  void updateLevel(int delta) {
    final user = state.value;
    if (user != null) {
      // Since level is now a getter that returns 1, we don't update it
      // This method is kept for backward compatibility
    }
  }

  void disposeSubscription() {
    _subscription?.cancel();
  }
}
