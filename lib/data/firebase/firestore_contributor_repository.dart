import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:give_track/core/constants/app_constants.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/data/firebase/firestore_mappers.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';
import 'package:give_track/features/contributions/domain/repositories/contribution_repository.dart';

class FirestoreContributorRepository implements ContributorRepository {
  FirestoreContributorRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.contributorsCollection);

  @override
  Future<Either<Failure, List<Contributor>>> getContributors() async {
    try {
      final snap = await _col.orderBy('name').get();
      final list =
          snap.docs
              .map((d) => contributorFromFirestore(d.id, d.data()))
              .toList();
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Contributor>>> getContributorsByProject(
    String projectId,
  ) async {
    try {
      final snap =
          await _col.where('projectIds', arrayContains: projectId).get();
      final list =
          snap.docs
              .map((d) => contributorFromFirestore(d.id, d.data()))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contributor>> getContributorById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return const Left(NotFoundFailure('Contributor not found'));
      }
      return Right(contributorFromFirestore(doc.id, doc.data()!));
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contributor>> createContributor(
    Contributor contributor,
  ) async {
    try {
      await _col.doc(contributor.id).set(contributorToFirestore(contributor));
      return Right(contributor);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contributor>> updateContributor(
    Contributor contributor,
  ) async {
    try {
      await _col
          .doc(contributor.id)
          .update(contributorToFirestore(contributor));
      return Right(contributor);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContributor(String id) async {
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
  Future<Either<Failure, List<Contributor>>> searchContributors(
    String query,
  ) async {
    final all = await getContributors();
    return all.fold(Left.new, (list) {
      if (query.isEmpty) return Right(list);
      final q = query.toLowerCase();
      return Right(
        list.where((c) => c.name.toLowerCase().contains(q)).toList(),
      );
    });
  }
}
