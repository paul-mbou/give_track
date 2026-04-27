import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';

abstract class ContributionRepository {
  Future<Either<Failure, List<Contribution>>> getContributions();
  Future<Either<Failure, List<Contribution>>> getContributionsByProject(
    String projectId,
  );
  Future<Either<Failure, List<Contribution>>> getContributionsByContributor(
    String contributorId,
  );
  Future<Either<Failure, Contribution>> getContributionById(String id);
  Future<Either<Failure, Contribution>> recordContribution(
    Contribution contribution,
  );
  Future<Either<Failure, void>> deleteContribution(String id);
  Future<Either<Failure, List<Contribution>>> getRecentContributions({
    int limit = 20,
  });
  Stream<List<Contribution>> watchContributions();
}

abstract class ContributorRepository {
  Future<Either<Failure, List<Contributor>>> getContributors();
  Future<Either<Failure, List<Contributor>>> getContributorsByProject(
    String projectId,
  );
  Future<Either<Failure, Contributor>> getContributorById(String id);
  Future<Either<Failure, Contributor>> createContributor(
    Contributor contributor,
  );
  Future<Either<Failure, Contributor>> updateContributor(
    Contributor contributor,
  );
  Future<Either<Failure, void>> deleteContributor(String id);
  Future<Either<Failure, List<Contributor>>> searchContributors(String query);
}
