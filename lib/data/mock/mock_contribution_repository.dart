import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/domain/repositories/contribution_repository.dart';

/// In-memory [ContributionRepository] for development and tests.
class MockContributionRepository implements ContributionRepository {
  final List<Contribution> _contributions = [
    Contribution(
      id: 'c1',
      contributorId: 'j1',
      contributorName: 'Alice Bernard',
      projectId: '1',
      projectName: 'Community Garden Initiative',
      description: 'Planted 15 tomato plants and weeded 3 garden beds',
      type: 'volunteering',
      value: 4,
      unit: 'hours',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      recordedBy: '1',
      recordedByName: 'Jean Dupont',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Contribution(
      id: 'c2',
      contributorId: 'j2',
      contributorName: 'Lucas Moreau',
      projectId: '1',
      projectName: 'Community Garden Initiative',
      description: 'Donated 5 bags of organic compost',
      type: 'donation',
      value: 25,
      unit: 'EUR',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      recordedBy: '1',
      recordedByName: 'Jean Dupont',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    Contribution(
      id: 'c3',
      contributorId: 'j3',
      contributorName: 'Emma Petit',
      projectId: '1',
      projectName: 'Community Garden Initiative',
      description: 'Helped with garden fence installation',
      type: 'volunteering',
      value: 3,
      unit: 'hours',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      recordedBy: '2',
      recordedByName: 'Marie Martin',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Contribution(
      id: 'c4',
      contributorId: 'j1',
      contributorName: 'Alice Bernard',
      projectId: '2',
      projectName: 'Youth Coding Workshop',
      description: 'Assisted with Python basics class',
      type: 'volunteering',
      value: 2,
      unit: 'hours',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      recordedBy: '2',
      recordedByName: 'Marie Martin',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Contribution(
      id: 'c5',
      contributorId: 'j4',
      contributorName: 'Hugo Lefevre',
      projectId: '3',
      projectName: 'Food Drive 2026',
      description: 'Collected 12kg of canned goods',
      type: 'donation',
      value: 12,
      unit: 'kg',
      timestamp: DateTime.now().subtract(const Duration(days: 3)),
      recordedBy: '1',
      recordedByName: 'Jean Dupont',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Contribution(
      id: 'c6',
      contributorId: 'j5',
      contributorName: 'Chloe Roux',
      projectId: '2',
      projectName: 'Youth Coding Workshop',
      description: 'Fundraised 50 EUR for equipment',
      type: 'fundraising',
      value: 50,
      unit: 'EUR',
      timestamp: DateTime.now().subtract(const Duration(days: 4)),
      recordedBy: '2',
      recordedByName: 'Marie Martin',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
    Contribution(
      id: 'c7',
      contributorId: 'j6',
      contributorName: 'Louis Girard',
      projectId: '1',
      projectName: 'Community Garden Initiative',
      description: 'Watered plants for the week',
      type: 'volunteering',
      value: 5,
      unit: 'hours',
      timestamp: DateTime.now().subtract(const Duration(days: 5)),
      recordedBy: '1',
      recordedByName: 'Jean Dupont',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Contribution(
      id: 'c8',
      contributorId: 'j7',
      contributorName: 'Ines Bonnet',
      projectId: '3',
      projectName: 'Food Drive 2026',
      description: 'Organized collection at local school',
      type: 'volunteering',
      value: 6,
      unit: 'hours',
      timestamp: DateTime.now().subtract(const Duration(days: 6)),
      recordedBy: '1',
      recordedByName: 'Jean Dupont',
      createdAt: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  @override
  Future<Either<Failure, List<Contribution>>> getContributions() async {
    await Future<void>.delayed(const Duration(milliseconds: 600));
    return Right(List<Contribution>.unmodifiable(_contributions));
  }

  @override
  Future<Either<Failure, List<Contribution>>> getContributionsByProject(
    String projectId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Right(
      _contributions.where((c) => c.projectId == projectId).toList(),
    );
  }

  @override
  Future<Either<Failure, List<Contribution>>> getContributionsByContributor(
    String contributorId,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Right(
      _contributions.where((c) => c.contributorId == contributorId).toList(),
    );
  }

  @override
  Future<Either<Failure, Contribution>> getContributionById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    try {
      return Right(_contributions.firstWhere((c) => c.id == id));
    } catch (_) {
      return const Left(NotFoundFailure('Contribution not found'));
    }
  }

  @override
  Future<Either<Failure, Contribution>> recordContribution(
    Contribution contribution,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _contributions.insert(0, contribution);
    return Right(contribution);
  }

  @override
  Future<Either<Failure, void>> deleteContribution(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _contributions.indexWhere((c) => c.id == id);
    if (i == -1) {
      return const Left(NotFoundFailure('Contribution not found'));
    }
    _contributions.removeAt(i);
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Contribution>>> getRecentContributions({
    int limit = 20,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return Right(_contributions.take(limit).toList());
  }

  @override
  Stream<List<Contribution>> watchContributions() async* {
    yield (await getContributions()).fold((_) => <Contribution>[], (r) => r);
  }
}
