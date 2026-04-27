class AppConstants {
  static const String appName = 'Give Track';
  static const String appVersion = '1.0.0';

  /// OAuth 2.0 **Web client** ID (`…apps.googleusercontent.com`) from Firebase
  /// Console → Project settings → Your apps → Web app. Helps Android return a
  /// valid ID token for Firebase. Leave empty if not needed (e.g. iOS-only).
  static const String googleSignInServerClientId = '';

  // Firebase collections (prepared for backend integration)
  static const String usersCollection = 'users';
  static const String projectsCollection = 'projects';
  static const String contributionsCollection = 'contributions';
  static const String contributorsCollection = 'contributors';
  static const String auditLogsCollection = 'audit_logs';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleLeader = 'leader';
  static const String roleSubLeader = 'sub_leader';
  static const String roleViewer = 'viewer';

  // Project statuses
  static const String statusActive = 'active';
  static const String statusPaused = 'paused';
  static const String statusCompleted = 'completed';
  static const String statusArchived = 'archived';

  // Contribution types
  static const String typeVolunteering = 'volunteering';
  static const String typeFundraising = 'fundraising';
  static const String typeDonation = 'donation';
  static const String typeOther = 'other';

  // Pagination
  static const int defaultPageSize = 20;

  // Cache keys
  static const String cacheUserKey = 'cached_user';
  static const String cacheProjectsKey = 'cached_projects';
  static const String cacheContributionsKey = 'cached_contributions';
}
