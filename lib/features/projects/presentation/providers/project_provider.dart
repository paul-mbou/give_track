import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/core/utils/either_utils.dart';
import 'package:give_track/data/di/backend_providers.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';

final projectsProvider = FutureProvider<List<Project>>((ref) async {
  final repo = ref.watch(projectRepositoryProvider);
  return (await repo.getProjects()).unpack();
});

final projectsByStatusProvider = FutureProvider.family<List<Project>, String>((
  ref,
  status,
) async {
  final repo = ref.watch(projectRepositoryProvider);
  return (await repo.getProjectsByStatus(status)).unpack();
});

final projectDetailProvider = FutureProvider.family<Project, String>((
  ref,
  id,
) async {
  final repo = ref.watch(projectRepositoryProvider);
  return (await repo.getProjectById(id)).unpack();
});

final projectNotifierProvider = AsyncNotifierProvider<ProjectNotifier, void>(
  ProjectNotifier.new,
);

class ProjectNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createProject(Project project) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      (await repo.createProject(project)).unpack();
      ref.invalidate(projectsProvider);
    });
  }

  Future<void> updateProject(Project project) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      (await repo.updateProject(project)).unpack();
      ref.invalidate(projectsProvider);
      ref.invalidate(projectDetailProvider(project.id));
    });
  }

  Future<void> archiveProject(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(projectRepositoryProvider);
      (await repo.archiveProject(id)).unpack();
      ref.invalidate(projectsProvider);
    });
  }
}
