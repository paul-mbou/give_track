import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Maps Firebase Auth / Google Sign-In errors to short, user-facing text.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return _firebaseAuthMessage(error);
  }
  if (error is GoogleSignInException) {
    return _googleSignInMessage(error);
  }
  return error.toString();
}

String _firebaseAuthMessage(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return 'That email address is not valid.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found for that email.';
    case 'wrong-password':
      return 'Incorrect password.';
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'Email or password is incorrect.';
    case 'too-many-requests':
      return 'Too many attempts. Try again later.';
    case 'network-request-failed':
      return 'Network error. Check your connection.';
    case 'missing-google-id-token':
      return e.message ?? 'Google sign-in did not return an ID token.';
    default:
      return e.message ?? 'Sign-in failed (${e.code}).';
  }
}

String _googleSignInMessage(GoogleSignInException e) {
  switch (e.code) {
    case GoogleSignInExceptionCode.canceled:
      return 'Sign-in was canceled.';
    case GoogleSignInExceptionCode.interrupted:
      return 'Sign-in was interrupted.';
    case GoogleSignInExceptionCode.uiUnavailable:
      return 'Sign-in is not available right now.';
    case GoogleSignInExceptionCode.clientConfigurationError:
      return 'Google Sign-In is not configured for this app.';
    default:
      return e.description ?? 'Google sign-in failed.';
  }
}
