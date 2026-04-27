import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';
import 'package:give_track/features/contributions/domain/repositories/contribution_repository.dart';

/// In-memory [ContributorRepository] for development and tests.
class MockContributorRepository implements ContributorRepository {
  final List<Contributor> _contributors = [
    const Contributor(
      id: 'j1',
      name: 'Alice Bernard',
      age: 17,
      email: 'alice@example.com',
      contributionIds: ['c1', 'c4'],
      projectIds: ['1', '2'],
    ),
    const Contributor(
      id: 'j2',
      name: 'Lucas Moreau',
      age: 16,
      email: 'lucas@example.com',
      contributionIds: ['c2'],
      projectIds: ['1'],
    ),
    const Contributor(
      id: 'j3',
      name: 'Emma Petit',
      age: 18,
      email: 'emma@example.com',
      contributionIds: ['c3'],
      projectIds: ['1'],
    ),
    const Contributor(
      id: 'j4',
      name: 'Hugo Lefevre',
      age: 15,
      email: 'hugo@example.com',
      contributionIds: ['c5'],
      projectIds: ['3'],
    ),
    const Contributor(
      id: 'j5',
      name: 'Chloe Roux',
      age: 17,
      email: 'chloe@example.com',
      contributionIds: ['c6'],
      projectIds: ['2'],
    ),
    const Contributor(
      id: 'j6',
      name: 'Louis Girard',
      age: 16,
      email: 'louis@example.com',
      contributionIds: ['c7'],
      projectIds: ['1'],
    ),
    const Contributor(
      id: 'j7',
      name: 'Ines Bonnet',
      age: 18,
      email: 'ines@example.com',
      contributionIds: ['c8'],
      projectIds: ['3'],
    ),
    const Contributor(
      id: 'j8',
      name: 'Thomas Richard',
      age: 15,
      contributionIds: [],
      projectIds: ['2'],
    ),
    const Contributor(
      id: 'j9',
      name: 'Camille Dubois',
      age: 17,
      contributionIds: [],
      projectIds: ['3'],
    ),
    const Contributor(
      id: 'j10',
      name: 'Nathan Martin',
      age: 16,
      contributionIds: [],
      projectIds: ['3'],
    ),
  ];

  @override
  Future<Either<Failure, List<Contributor>>> getContributors() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return Right(List<Contributor>.unmodifiable(_contributors));
  }

  @override
  Future<Either<Failure, List<Contributor>>> getContributorsByProject(
    String projectId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Right(
      _contributors.where((c) => c.projectIds.contains(projectId)).toList(),
    );
  }

  @override
  Future<Either<Failure, Contributor>> getContributorById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return Right(_contributors.firstWhere((c) => c.id == id));
    } catch (_) {
      return const Left(NotFoundFailure('Contributor not found'));
    }
  }

  @override
  Future<Either<Failure, Contributor>> createContributor(
    Contributor contributor,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    _contributors.add(contributor);
    return Right(contributor);
  }

  @override
  Future<Either<Failure, Contributor>> updateContributor(
    Contributor contributor,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final i = _contributors.indexWhere((c) => c.id == contributor.id);
    if (i == -1) {
      return const Left(NotFoundFailure('Contributor not found'));
    }
    _contributors[i] = contributor;
    return Right(contributor);
  }

  @override
  Future<Either<Failure, void>> deleteContributor(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _contributors.indexWhere((c) => c.id == id);
    if (i == -1) {
      return const Left(NotFoundFailure('Contributor not found'));
    }
    _contributors.removeAt(i);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Contributor>>> searchContributors(
    String query,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) {
      return Right(List<Contributor>.unmodifiable(_contributors));
    }
    final q = query.toLowerCase();
    return Right(
      _contributors.where((c) => c.name.toLowerCase().contains(q)).toList(),
    );
  }
}
