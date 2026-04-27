import 'dart:async';

import 'package:give_track/features/auth/domain/auth_repository.dart';
import 'package:give_track/features/auth/domain/entities/user.dart';

/// In-memory auth for widget tests / offline UI work.
class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  final StreamController<User?> _authController =
      StreamController<User?>.broadcast();

  @override
  Stream<User?> get authStateChanges {
    return Stream<User?>.multi((listener) {
      listener.add(_currentUser);
      late final StreamSubscription<User?> subscription;
      subscription = _authController.stream.listen(
        listener.add,
        onError: listener.addError,
        onDone: listener.close,
      );
      listener.onCancel = subscription.cancel;
    });
  }

  void _notifyAuthListeners() {
    if (!_authController.isClosed) {
      _authController.add(_currentUser);
    }
  }

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: '1',
      email: email,
      displayName: 'Jean Dupont',
      role: 'leader',
      projectIds: const ['1', '2'],
      createdAt: DateTime.now().subtract(const Duration(days: 365)),
      lastLoginAt: DateTime.now(),
    );
    _notifyAuthListeners();
    return _currentUser;
  }

  @override
  Future<User?> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _currentUser = User(
      id: '2',
      email: 'leader@example.com',
      displayName: 'Marie Martin',
      role: 'admin',
      projectIds: const ['1', '2', '3'],
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      lastLoginAt: DateTime.now(),
    );
    _notifyAuthListeners();
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _notifyAuthListeners();
  }
}
