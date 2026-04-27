import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:give_track/core/constants/app_constants.dart';
import 'package:give_track/features/auth/domain/auth_repository.dart';
import 'package:give_track/features/auth/domain/entities/user.dart' as domain;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth + Firestore profile at [AppConstants.usersCollection].
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _auth = firebaseAuth ?? fb.FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance;

  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection(AppConstants.usersCollection).doc(uid);
  }

  @override
  Stream<domain.User?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((fbUser) async {
      if (fbUser == null) return null;
      return _profileFromFirebaseUser(fbUser);
    });
  }

  Future<domain.User> _profileFromFirebaseUser(fb.User fbUser) async {
    final snap = await _userRef(fbUser.uid).get();
    final data = snap.data();
    if (!snap.exists || data == null) {
      await _bootstrapUserDoc(fbUser);
      return _defaultProfile(fbUser);
    }
    return _mapDoc(fbUser, data);
  }

  Future<void> _bootstrapUserDoc(fb.User fbUser) async {
    await _userRef(fbUser.uid).set(<String, dynamic>{
      'email': fbUser.email,
      'displayName': fbUser.displayName ?? fbUser.email ?? 'User',
      'photoUrl': fbUser.photoURL,
      'role': AppConstants.roleLeader,
      'projectIds': <String>[],
      'createdAt': FieldValue.serverTimestamp(),
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  domain.User _defaultProfile(fb.User fbUser) {
    return domain.User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      displayName: fbUser.displayName ?? fbUser.email ?? 'User',
      photoUrl: fbUser.photoURL,
      role: AppConstants.roleLeader,
      projectIds: const [],
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  domain.User _mapDoc(fb.User fbUser, Map<String, dynamic> data) {
    final created = data['createdAt'];
    final lastLogin = data['lastLoginAt'];
    return domain.User(
      id: fbUser.uid,
      email: (data['email'] as String?) ?? fbUser.email ?? '',
      displayName:
          (data['displayName'] as String?) ??
          fbUser.displayName ??
          fbUser.email ??
          'User',
      photoUrl: (data['photoUrl'] as String?) ?? fbUser.photoURL,
      role: (data['role'] as String?) ?? AppConstants.roleLeader,
      projectIds: List<String>.from(data['projectIds'] as List? ?? []),
      createdAt: created is Timestamp ? created.toDate() : DateTime.now(),
      lastLoginAt: lastLogin is Timestamp ? lastLogin.toDate() : DateTime.now(),
    );
  }

  Future<void> _touchLastLogin(String uid) async {
    await _userRef(uid).set({
      'lastLoginAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<domain.User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final fbUser = cred.user;
    if (fbUser == null) return null;
    final user = await _profileFromFirebaseUser(fbUser);
    await _touchLastLogin(fbUser.uid);
    return user;
  }

  @override
  Future<domain.User?> signInWithGoogle() async {
    try {
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      final auth = account.authentication;
      final idToken = auth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw fb.FirebaseAuthException(
          code: 'missing-google-id-token',
          message:
              'Could not get a Google ID token. On Android, register your '
              'app’s SHA-1 in Firebase Console and set '
              'AppConstants.googleSignInServerClientId to your Web client ID '
              '(…apps.googleusercontent.com).',
        );
      }
      final credential = fb.GoogleAuthProvider.credential(idToken: idToken);
      final cred = await _auth.signInWithCredential(credential);
      final fbUser = cred.user;
      if (fbUser == null) return null;
      final user = await _profileFromFirebaseUser(fbUser);
      await _touchLastLogin(fbUser.uid);
      return user;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([_auth.signOut(), GoogleSignIn.instance.signOut()]);
  }
}
