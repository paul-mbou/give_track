import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';
import 'package:give_track/features/contributions/domain/repositories/contribution_repository.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/domain/repositories/project_repository.dart';

Failure _todo(String name) =>
    ServerFailure('$name is not implemented for Appwrite yet.');

class AppwriteProjectRepository implements ProjectRepository {
  @override
  Future<Either<Failure, List<Project>>> getProjects() async =>
      Left(_todo('ProjectRepository.getProjects'));

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async =>
      Left(_todo('ProjectRepository.getProjectById'));

  @override
  Future<Either<Failure, Project>> createProject(Project project) async =>
      Left(_todo('ProjectRepository.createProject'));

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async =>
      Left(_todo('ProjectRepository.updateProject'));

  @override
  Future<Either<Failure, void>> deleteProject(String id) async =>
      Left(_todo('ProjectRepository.deleteProject'));

  @override
  Future<Either<Failure, void>> archiveProject(String id) async =>
      Left(_todo('ProjectRepository.archiveProject'));

  @override
  Future<Either<Failure, List<Project>>> getProjectsByStatus(
    String status,
  ) async => Left(_todo('ProjectRepository.getProjectsByStatus'));

  @override
  Stream<List<Project>> watchProjects() => Stream<List<Project>>.value([]);
}

class AppwriteContributionRepository implements ContributionRepository {
  @override
  Future<Either<Failure, List<Contribution>>> getContributions() async =>
      Left(_todo('ContributionRepository.getContributions'));

  @override
  Future<Either<Failure, List<Contribution>>> getContributionsByProject(
    String projectId,
  ) async => Left(_todo('ContributionRepository.getContributionsByProject'));

  @override
  Future<Either<Failure, List<Contribution>>> getContributionsByContributor(
    String contributorId,
  ) async =>
      Left(_todo('ContributionRepository.getContributionsByContributor'));

  @override
  Future<Either<Failure, Contribution>> getContributionById(String id) async =>
      Left(_todo('ContributionRepository.getContributionById'));

  @override
  Future<Either<Failure, Contribution>> recordContribution(
    Contribution contribution,
  ) async => Left(_todo('ContributionRepository.recordContribution'));

  @override
  Future<Either<Failure, void>> deleteContribution(String id) async =>
      Left(_todo('ContributionRepository.deleteContribution'));

  @override
  Future<Either<Failure, List<Contribution>>> getRecentContributions({
    int limit = 20,
  }) async => Left(_todo('ContributionRepository.getRecentContributions'));

  @override
  Stream<List<Contribution>> watchContributions() =>
      Stream<List<Contribution>>.value([]);
}

class AppwriteContributorRepository implements ContributorRepository {
  @override
  Future<Either<Failure, List<Contributor>>> getContributors() async =>
      Left(_todo('ContributorRepository.getContributors'));

  @override
  Future<Either<Failure, List<Contributor>>> getContributorsByProject(
    String projectId,
  ) async => Left(_todo('ContributorRepository.getContributorsByProject'));

  @override
  Future<Either<Failure, Contributor>> getContributorById(String id) async =>
      Left(_todo('ContributorRepository.getContributorById'));

  @override
  Future<Either<Failure, Contributor>> createContributor(
    Contributor contributor,
  ) async => Left(_todo('ContributorRepository.createContributor'));

  @override
  Future<Either<Failure, Contributor>> updateContributor(
    Contributor contributor,
  ) async => Left(_todo('ContributorRepository.updateContributor'));

  @override
  Future<Either<Failure, void>> deleteContributor(String id) async =>
      Left(_todo('ContributorRepository.deleteContributor'));

  @override
  Future<Either<Failure, List<Contributor>>> searchContributors(
    String query,
  ) async => Left(_todo('ContributorRepository.searchContributors'));
}
