import 'package:equatable/equatable.dart';

class Project extends Equatable {
  final String id;
  final String title;
  final String description;
  final String motif;
  final DateTime startDate;
  final DateTime? deadline;
  final String status;
  final String createdBy;
  final List<String> leaderIds;
  final List<String> contributorIds;
  final List<String> contributionIds;
  final Map<String, dynamic>? customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.description,
    required this.motif,
    required this.startDate,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.deadline,
    this.leaderIds = const [],
    this.contributorIds = const [],
    this.contributionIds = const [],
    this.customFields,
  });

  Project copyWith({
    String? id,
    String? title,
    String? description,
    String? motif,
    DateTime? startDate,
    DateTime? deadline,
    String? status,
    String? createdBy,
    List<String>? leaderIds,
    List<String>? contributorIds,
    List<String>? contributionIds,
    Map<String, dynamic>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      motif: motif ?? this.motif,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      leaderIds: leaderIds ?? this.leaderIds,
      contributorIds: contributorIds ?? this.contributorIds,
      contributionIds: contributionIds ?? this.contributionIds,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isActive => status == 'active';
  bool get isPaused => status == 'paused';
  bool get isCompleted => status == 'completed';
  bool get isArchived => status == 'archived';

  double get progress {
    return contributionIds.length / 10.0;
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    motif,
    startDate,
    deadline,
    status,
    createdBy,
    leaderIds,
    contributorIds,
    contributionIds,
    customFields,
    createdAt,
    updatedAt,
  ];
}
