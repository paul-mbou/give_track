import 'package:dartz/dartz.dart';
import 'package:give_track/core/errors/failures.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/domain/repositories/project_repository.dart';

/// In-memory [ProjectRepository] for development and tests.
class MockProjectRepository implements ProjectRepository {
  final List<Project> _projects = [
    Project(
      id: '1',
      title: 'Community Garden Initiative',
      description:
          'Building and maintaining a community garden for local residents',
      motif: 'Environmental sustainability and community engagement',
      startDate: DateTime.now().subtract(const Duration(days: 30)),
      deadline: DateTime.now().add(const Duration(days: 60)),
      status: 'active',
      createdBy: '1',
      leaderIds: const ['1', '2'],
      contributorIds: const ['j1', 'j2', 'j3', 'j4', 'j5'],
      contributionIds: const ['c1', 'c2', 'c3', 'c4', 'c5'],
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Project(
      id: '2',
      title: 'Youth Coding Workshop',
      description: 'Teaching programming skills to underprivileged youth',
      motif: 'Digital literacy and education',
      startDate: DateTime.now().subtract(const Duration(days: 15)),
      deadline: DateTime.now().add(const Duration(days: 45)),
      status: 'active',
      createdBy: '2',
      leaderIds: const ['2'],
      contributorIds: const ['j6', 'j7', 'j8'],
      contributionIds: const ['c6', 'c7'],
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
    Project(
      id: '3',
      title: 'Food Drive 2026',
      description: 'Collecting food donations for local shelters',
      motif: 'Hunger relief and community support',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      deadline: DateTime.now().add(const Duration(days: 25)),
      status: 'active',
      createdBy: '1',
      leaderIds: const ['1'],
      contributorIds: const ['j1', 'j9', 'j10'],
      contributionIds: const ['c8'],
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now(),
    ),
    Project(
      id: '4',
      title: 'Park Cleanup 2025',
      description: 'Annual park cleanup event',
      motif: 'Environmental conservation',
      startDate: DateTime.now().subtract(const Duration(days: 200)),
      deadline: DateTime.now().subtract(const Duration(days: 180)),
      status: 'completed',
      createdBy: '1',
      leaderIds: const ['1', '2'],
      contributorIds: const ['j1', 'j2', 'j3', 'j4', 'j5', 'j6'],
      contributionIds: const ['c10', 'c11', 'c12', 'c13', 'c14', 'c15'],
      createdAt: DateTime.now().subtract(const Duration(days: 200)),
      updatedAt: DateTime.now().subtract(const Duration(days: 180)),
    ),
  ];

  @override
  Future<Either<Failure, List<Project>>> getProjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return Right(List<Project>.unmodifiable(_projects));
  }

  @override
  Future<Either<Failure, Project>> getProjectById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    try {
      final p = _projects.firstWhere((e) => e.id == id);
      return Right(p);
    } catch (_) {
      return const Left(NotFoundFailure('Project not found'));
    }
  }

  @override
  Future<Either<Failure, Project>> createProject(Project project) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    _projects.add(project);
    return Right(project);
  }

  @override
  Future<Either<Failure, Project>> updateProject(Project project) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    final i = _projects.indexWhere((p) => p.id == project.id);
    if (i == -1) {
      return const Left(NotFoundFailure('Project not found'));
    }
    _projects[i] = project;
    return Right(project);
  }

  @override
  Future<Either<Failure, void>> deleteProject(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _projects.indexWhere((p) => p.id == id);
    if (i == -1) {
      return const Left(NotFoundFailure('Project not found'));
    }
    _projects.removeAt(i);
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> archiveProject(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _projects.indexWhere((p) => p.id == id);
    if (i == -1) {
      return const Left(NotFoundFailure('Project not found'));
    }
    _projects[i] = _projects[i].copyWith(status: 'archived');
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<Project>>> getProjectsByStatus(
    String status,
  ) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    return Right(_projects.where((p) => p.status == status).toList());
  }

  @override
  Stream<List<Project>> watchProjects() async* {
    yield (await getProjects()).fold((_) => <Project>[], (r) => r);
  }
}
