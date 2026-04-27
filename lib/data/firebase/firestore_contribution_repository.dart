import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:give_track/core/constants/app_constants.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/data/firebase/firestore_mappers.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/domain/repositories/contribution_repository.dart';

class FirestoreContributionRepository implements ContributionRepository {
  FirestoreContributionRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.contributionsCollection);

  @override
  Future<Either<Failure, List<Contribution>>> getContributions() async {
    try {
      final snap = await _col.orderBy('timestamp', descending: true).get();
      final list =
          snap.docs
              .map((d) => contributionFromFirestore(d.id, d.data()))
              .toList();
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Contribution>>> getContributionsByProject(
    String projectId,
  ) async {
    try {
      final snap = await _col.where('projectId', isEqualTo: projectId).get();
      final list =
          snap.docs
              .map((d) => contributionFromFirestore(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Contribution>>> getContributionsByContributor(
    String contributorId,
  ) async {
    try {
      final snap =
          await _col.where('contributorId', isEqualTo: contributorId).get();
      final list =
          snap.docs
              .map((d) => contributionFromFirestore(d.id, d.data()))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contribution>> getContributionById(String id) async {
    try {
      final doc = await _col.doc(id).get();
      if (!doc.exists || doc.data() == null) {
        return const Left(NotFoundFailure('Contribution not found'));
      }
      return Right(contributionFromFirestore(doc.id, doc.data()!));
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Contribution>> recordContribution(
    Contribution contribution,
  ) async {
    try {
      await _col
          .doc(contribution.id)
          .set(contributionToFirestore(contribution));
      return Right(contribution);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteContribution(String id) async {
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
  Future<Either<Failure, List<Contribution>>> getRecentContributions({
    int limit = 20,
  }) async {
    try {
      final snap =
          await _col.orderBy('timestamp', descending: true).limit(limit).get();
      final list =
          snap.docs
              .map((d) => contributionFromFirestore(d.id, d.data()))
              .toList();
      return Right(list);
    } on FirebaseException catch (e) {
      return Left(e.toFailure());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Contribution>> watchContributions() {
    return _col
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs
                  .map((d) => contributionFromFirestore(d.id, d.data()))
                  .toList(),
        );
  }
}
