import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role;
  final List<String> projectIds;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  const User({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.photoUrl,
    this.projectIds = const [],
    this.lastLoginAt,
  });

  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    List<String>? projectIds,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      projectIds: projectIds ?? this.projectIds,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  bool get isAdmin => role == 'admin';
  bool get isLeader => role == 'leader' || role == 'admin';

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    role,
    projectIds,
    createdAt,
    lastLoginAt,
  ];
}
