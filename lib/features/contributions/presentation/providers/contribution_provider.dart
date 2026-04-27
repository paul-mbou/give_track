import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/core/utils/either_utils.dart';
import 'package:give_track/data/di/backend_providers.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/domain/entities/contributor.dart';

final contributionsProvider = FutureProvider<List<Contribution>>((ref) async {
  final repo = ref.watch(contributionRepositoryProvider);
  return (await repo.getContributions()).unpack();
});

final recentContributionsProvider = FutureProvider<List<Contribution>>((
  ref,
) async {
  final repo = ref.watch(contributionRepositoryProvider);
  return (await repo.getRecentContributions(limit: 10)).unpack();
});

final contributionsByProjectProvider =
    FutureProvider.family<List<Contribution>, String>((ref, projectId) async {
      final repo = ref.watch(contributionRepositoryProvider);
      return (await repo.getContributionsByProject(projectId)).unpack();
    });

final contributorsProvider = FutureProvider<List<Contributor>>((ref) async {
  final repo = ref.watch(contributorRepositoryProvider);
  return (await repo.getContributors()).unpack();
});

final contributorsByProjectProvider =
    FutureProvider.family<List<Contributor>, String>((ref, projectId) async {
      final repo = ref.watch(contributorRepositoryProvider);
      return (await repo.getContributorsByProject(projectId)).unpack();
    });

final contributionNotifierProvider =
    AsyncNotifierProvider<ContributionNotifier, void>(ContributionNotifier.new);

class ContributionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> recordContribution(Contribution contribution) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(contributionRepositoryProvider);
      (await repo.recordContribution(contribution)).unpack();
      ref.invalidate(contributionsProvider);
      ref.invalidate(recentContributionsProvider);
    });
  }

  Future<void> deleteContribution(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(contributionRepositoryProvider);
      (await repo.deleteContribution(id)).unpack();
      ref.invalidate(contributionsProvider);
    });
  }
}

final contributorNotifierProvider =
    AsyncNotifierProvider<ContributorNotifier, void>(ContributorNotifier.new);

/// Deprecated. Use [contributorNotifierProvider].
@Deprecated('Use contributorNotifierProvider')
final jeuneNotifierProvider = contributorNotifierProvider;

class ContributorNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createContributor(Contributor contributor) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(contributorRepositoryProvider);
      (await repo.createContributor(contributor)).unpack();
      ref.invalidate(contributorsProvider);
    });
  }

  /// Deprecated. Use [createContributor].
  @Deprecated('Use createContributor')
  Future<void> createJeune(Contributor contributor) =>
      createContributor(contributor);
}
