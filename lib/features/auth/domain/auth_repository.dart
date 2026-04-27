import 'package:give_track/features/auth/domain/entities/user.dart';

/// Application auth boundary. Implemented by Firebase (or mocks in tests).
abstract interface class AuthRepository {
  Stream<User?> get authStateChanges;

  Future<User?> signInWithEmailAndPassword(String email, String password);

  Future<User?> signInWithGoogle();

  Future<void> signOut();
}
