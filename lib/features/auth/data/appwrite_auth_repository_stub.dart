import 'package:give_track/features/auth/domain/auth_repository.dart';
import 'package:give_track/features/auth/domain/entities/user.dart';

/// Placeholder until Appwrite account APIs are wired to [User].
class AppwriteAuthRepositoryStub implements AuthRepository {
  @override
  Stream<User?> get authStateChanges => Stream<User?>.value(null);

  @override
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    throw UnsupportedError(
      'Appwrite auth is not implemented. Use BackendKind.mock or '
      'BackendKind.firebase, or implement AppwriteAuthRepositoryStub.',
    );
  }

  @override
  Future<User?> signInWithGoogle() async {
    throw UnsupportedError('Appwrite Google sign-in is not implemented.');
  }

  @override
  Future<void> signOut() async {}
}
