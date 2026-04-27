import 'package:equatable/equatable.dart';

class Contributor extends Equatable {
  final String id;
  final String name;
  final int? age;
  final String? email;
  final String? phone;
  final String? photoUrl;
  final List<String> projectIds;
  final List<String> contributionIds;
  final DateTime? createdAt;

  const Contributor({
    required this.id,
    required this.name,
    this.age,
    this.email,
    this.phone,
    this.photoUrl,
    this.projectIds = const [],
    this.contributionIds = const [],
    this.createdAt,
  });

  Contributor copyWith({
    String? id,
    String? name,
    int? age,
    String? email,
    String? phone,
    String? photoUrl,
    List<String>? projectIds,
    List<String>? contributionIds,
    DateTime? createdAt,
  }) {
    return Contributor(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      projectIds: projectIds ?? this.projectIds,
      contributionIds: contributionIds ?? this.contributionIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get totalContributions => contributionIds.length;

  @override
  List<Object?> get props => [
    id,
    name,
    age,
    email,
    phone,
    photoUrl,
    projectIds,
    contributionIds,
    createdAt,
  ];
}
