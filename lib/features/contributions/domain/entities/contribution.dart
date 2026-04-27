import 'package:equatable/equatable.dart';

class Contribution extends Equatable {
  final String id;
  final String contributorId;
  final String contributorName;
  final String projectId;
  final String projectName;
  final String description;
  final String type;
  final double? value;
  final String? unit;
  final DateTime timestamp;
  final String recordedBy;
  final String recordedByName;
  final List<String>? attachments;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const Contribution({
    required this.id,
    required this.contributorId,
    required this.contributorName,
    required this.projectId,
    required this.projectName,
    required this.description,
    required this.type,
    required this.timestamp,
    required this.recordedBy,
    required this.recordedByName,
    required this.createdAt,
    this.value,
    this.unit,
    this.attachments,
    this.metadata,
  });

  Contribution copyWith({
    String? id,
    String? contributorId,
    String? contributorName,
    String? projectId,
    String? projectName,
    String? description,
    String? type,
    double? value,
    String? unit,
    DateTime? timestamp,
    String? recordedBy,
    String? recordedByName,
    List<String>? attachments,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return Contribution(
      id: id ?? this.id,
      contributorId: contributorId ?? this.contributorId,
      contributorName: contributorName ?? this.contributorName,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      description: description ?? this.description,
      type: type ?? this.type,
      value: value ?? this.value,
      unit: unit ?? this.unit,
      timestamp: timestamp ?? this.timestamp,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedByName: recordedByName ?? this.recordedByName,
      attachments: attachments ?? this.attachments,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    contributorId,
    contributorName,
    projectId,
    projectName,
    description,
    type,
    value,
    unit,
    timestamp,
    recordedBy,
    recordedByName,
    attachments,
    metadata,
    createdAt,
  ];
}
