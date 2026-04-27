import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:give_track/core/constants/app_constants.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/data/firebase/firestore_mappers.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/domain/repositories/project_repository.dart';

class FirestoreProjectRepository implements ProjectRepository {
  FirestoreProjectRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.projectsCollection);

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    try {
      final snap = await _col.orderBy('updatedAt', descending: true).get();
      final list =
          snap.docs.map((d) => projectFromFirestore(d.id, d.data())).toList();
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return const Left(NotFoundFailure('Project not found'));
      }
      return Right(projectFromFirestore(doc.id, doc.data()!));
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    try {
      final data = projectToFirestore(project);
      await _col.doc(project.id).set(data);
      return Right(project);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    try {
      final updated = project.copyWith(updatedAt: DateTime.now());
      await _col.doc(project.id).update(projectToFirestore(updated));
      return Right(updated);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProject(String id) async {
    try {
      await _col.doc(id).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> archiveProject(String id) async {
    try {
      await _col.doc(id).update({
        'status': AppConstants.statusArchived,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByStatus(
    String status,
  ) async {
    try {
      final snap = await _col.where('status', isEqualTo: status).get();
      final list =
          snap.docs.map((d) => projectFromFirestore(d.id, d.data())).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Project>> watchProjects() {
    return _col
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((d) => projectFromFirestore(d.id, d.data()))
                  .toList(),
        );
  }
}
