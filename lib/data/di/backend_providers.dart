import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/core/config/backend_kind.dart';
import 'package:give_track/data/appwrite/appwrite_data_stubs.dart';
import 'package:give_track/data/firebase/firestore_contribution_repository.dart';
import 'package:give_track/data/firebase/firestore_contributor_repository.dart';
import 'package:give_track/data/firebase/firestore_project_repository.dart';
import 'package:give_track/data/mock/mock_contribution_repository.dart';
import 'package:give_track/data/mock/mock_contributor_repository.dart';
import 'package:give_track/data/mock/mock_project_repository.dart';
import 'package:give_track/features/auth/data/appwrite_auth_repository_stub.dart';
import 'package:give_track/features/auth/data/firebase_auth_repository.dart';
import 'package:give_track/features/auth/data/mock_auth_repository.dart';
import 'package:give_track/features/auth/domain/auth_repository.dart';
import 'package:give_track/features/contributions/domain/repositories/contribution_repository.dart';
import 'package:give_track/features/projects/domain/repositories/project_repository.dart';

/// Active BaaS (mock, Firebase, or Appwrite stub). Set at compile time:
/// `--dart-define=BACKEND=firebase` or `appwrite` (default: `mock`).
final backendKindProvider = Provider<BackendKind>((_) => resolveBackendKind());

/// Auth backend tracks [backendKindProvider]; use Firebase Auth in production
/// or mock for local UI tests without credentials.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  switch (ref.watch(backendKindProvider)) {
    case BackendKind.mock:
      return MockAuthRepository();
    case BackendKind.firebase:
      return FirebaseAuthRepository();
    case BackendKind.appwrite:
      return AppwriteAuthRepositoryStub();
  }
});

final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  switch (ref.watch(backendKindProvider)) {
    case BackendKind.mock:
      return MockProjectRepository();
    case BackendKind.firebase:
      return FirestoreProjectRepository(FirebaseFirestore.instance);
    case BackendKind.appwrite:
      return AppwriteProjectRepository();
  }
});

final contributionRepositoryProvider = Provider<ContributionRepository>((ref) {
  switch (ref.watch(backendKindProvider)) {
    case BackendKind.mock:
      return MockContributionRepository();
    case BackendKind.firebase:
      return FirestoreContributionRepository(FirebaseFirestore.instance);
    case BackendKind.appwrite:
      return AppwriteContributionRepository();
  }
});

final contributorRepositoryProvider = Provider<ContributorRepository>((ref) {
  switch (ref.watch(backendKindProvider)) {
    case BackendKind.mock:
      return MockContributorRepository();
    case BackendKind.firebase:
      return FirestoreContributorRepository(FirebaseFirestore.instance);
    case BackendKind.appwrite:
      return AppwriteContributorRepository();
  }
});
