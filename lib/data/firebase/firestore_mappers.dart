import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:give_track/core/constants/app_constants.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';

DateTime _readDate(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return DateTime.now();
}

DateTime? _readDateOpt(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v == null) return null;
  if (v is Timestamp) return v.toDate();
  if (v is DateTime) return v;
  return null;
}

double? _readDouble(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return null;
}

List<String> _readStringList(Map<String, dynamic> m, String key) {
  final v = m[key];
  if (v is! List) return [];
  return v.map((e) => e.toString()).toList();
}

Project projectFromFirestore(String id, Map<String, dynamic> m) {
  return Project(
    id: id,
    title: m['title'] as String? ?? '',
    description: m['description'] as String? ?? '',
    motif: m['motif'] as String? ?? '',
    startDate: _readDate(m, 'startDate'),
    deadline: _readDateOpt(m, 'deadline'),
    status: m['status'] as String? ?? AppConstants.statusActive,
    createdBy: m['createdBy'] as String? ?? '',
    leaderIds: _readStringList(m, 'leaderIds'),
    contributorIds: _readStringList(m, 'contributorIds'),
    contributionIds: _readStringList(m, 'contributionIds'),
    customFields: m['customFields'] as Map<String, dynamic>?,
    createdAt: _readDate(m, 'createdAt'),
    updatedAt: _readDate(m, 'updatedAt'),
  );
}

Map<String, dynamic> projectToFirestore(Project p) {
  return <String, dynamic>{
    'title': p.title,
    'description': p.description,
    'motif': p.motif,
    'startDate': Timestamp.fromDate(p.startDate),
    'deadline': p.deadline != null ? Timestamp.fromDate(p.deadline!) : null,
    'status': p.status,
    'createdBy': p.createdBy,
    'leaderIds': p.leaderIds,
    'contributorIds': p.contributorIds,
    'contributionIds': p.contributionIds,
    'customFields': p.customFields,
    'createdAt': Timestamp.fromDate(p.createdAt),
    'updatedAt': Timestamp.fromDate(p.updatedAt),
  };
}

Contribution contributionFromFirestore(String id, Map<String, dynamic> m) {
  return Contribution(
    id: id,
    contributorId: m['contributorId'] as String? ?? '',
    contributorName: m['contributorName'] as String? ?? '',
    projectId: m['projectId'] as String? ?? '',
    projectName: m['projectName'] as String? ?? '',
    description: m['description'] as String? ?? '',
    type: m['type'] as String? ?? AppConstants.typeOther,
    value: _readDouble(m, 'value'),
    unit: m['unit'] as String?,
    timestamp: _readDate(m, 'timestamp'),
    recordedBy: m['recordedBy'] as String? ?? '',
    recordedByName: m['recordedByName'] as String? ?? '',
    attachments:
        m['attachments'] != null ? _readStringList(m, 'attachments') : null,
    metadata: m['metadata'] as Map<String, dynamic>?,
    createdAt: _readDate(m, 'createdAt'),
  );
}

Map<String, dynamic> contributionToFirestore(Contribution c) {
  return <String, dynamic>{
    'contributorId': c.contributorId,
    'contributorName': c.contributorName,
    'projectId': c.projectId,
    'projectName': c.projectName,
    'description': c.description,
    'type': c.type,
    'value': c.value,
    'unit': c.unit,
    'timestamp': Timestamp.fromDate(c.timestamp),
    'recordedBy': c.recordedBy,
    'recordedByName': c.recordedByName,
    'attachments': c.attachments,
    'metadata': c.metadata,
    'createdAt': Timestamp.fromDate(c.createdAt),
  };
}

Contributor contributorFromFirestore(String id, Map<String, dynamic> m) {
  return Contributor(
    id: id,
    name: m['name'] as String? ?? '',
    age: (m['age'] as num?)?.toInt(),
    email: m['email'] as String?,
    phone: m['phone'] as String?,
    photoUrl: m['photoUrl'] as String?,
    projectIds: _readStringList(m, 'projectIds'),
    contributionIds: _readStringList(m, 'contributionIds'),
    createdAt: _readDateOpt(m, 'createdAt'),
  );
}

Map<String, dynamic> contributorToFirestore(Contributor c) {
  return <String, dynamic>{
    'name': c.name,
    'age': c.age,
    'email': c.email,
    'phone': c.phone,
    'photoUrl': c.photoUrl,
    'projectIds': c.projectIds,
    'contributionIds': c.contributionIds,
    if (c.createdAt != null) 'createdAt': Timestamp.fromDate(c.createdAt!),
  };
}

extension FirestoreQueryFailure on FirebaseException {
  Failure toFailure() {
    final msg = message ?? code;
    if (code == 'permission-denied') {
      return AuthFailure(msg);
    }
    if (code == 'unavailable' || code == 'deadline-exceeded') {
      return NetworkFailure(msg);
    }
    return ServerFailure(msg);
  }
}
