/// Remote data / BaaS used by [repositoryProviders].
///
/// Override at compile time:
/// `flutter run --dart-define=BACKEND=firebase`
enum BackendKind {
  /// In-memory mock data (default). Pairs with [MockAuthRepository].
  mock,

  /// Cloud Firestore + Firebase Auth for data (projects, contributions, etc.).
  firebase,

  /// Placeholder — implement [AppwriteProjectRepository] and siblings when
  /// you add the Appwrite SDK.
  appwrite,
}

/// Resolved from `--dart-define=BACKEND=`; falls back to [BackendKind.mock].
BackendKind resolveBackendKind() {
  const v = String.fromEnvironment('BACKEND', defaultValue: 'mock');
  for (final k in BackendKind.values) {
    if (k.name == v) return k;
  }
  return BackendKind.mock;
}
