import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/presentation/providers/contribution_provider.dart';
import 'package:go_router/go_router.dart';

class ContributionsScreen extends ConsumerWidget {
  const ContributionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contributions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Filters
            },
          ),
        ],
      ),
      body: contributionsAsync.when(
        data:
            (contributions) => _ContributionsList(contributions: contributions),
        loading: () => const LoadingWidget(),
        error:
            (error, stack) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(contributionsProvider),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/contributions/record'),
        icon: const Icon(Icons.add),
        label: const Text('Record'),
      ),
    );
  }
}

class _ContributionsList extends StatelessWidget {
  final List<Contribution> contributions;

  const _ContributionsList({required this.contributions});

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return EmptyStateWidget(
        message: 'No contributions recorded yet.',
        icon: Icons.volunteer_activism_outlined,
        actionLabel: 'Record Contribution',
        onAction: () => context.push('/contributions/record'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: contributions.length,
      itemBuilder: (context, index) {
        final contribution = contributions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ContributionCard(contribution: contribution),
        );
      },
    );
  }
}

class _ContributionCard extends ConsumerWidget {
  final Contribution contribution;

  const _ContributionCard({required this.contribution});

  IconData _getTypeIcon() {
    switch (contribution.type) {
      case 'volunteering':
        return Icons.access_time;
      case 'fundraising':
        return Icons.attach_money;
      case 'donation':
        return Icons.card_giftcard;
      default:
        return Icons.help_outline;
    }
  }

  Color _getTypeColor(BuildContext context) {
    switch (contribution.type) {
      case 'volunteering':
        return context.colors.primary;
      case 'fundraising':
        return context.giveTrack.chartOrange;
      case 'donation':
        return context.colors.secondary;
      default:
        return context.giveTrack.chartNeutral;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeColor = _getTypeColor(context);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {
              // TODO: Edit
            },
            backgroundColor: context.colors.secondary,
            foregroundColor: context.colors.onSecondary,
            icon: Icons.edit,
            label: 'Edit',
          ),
          SlidableAction(
            onPressed: (_) {
              _showDeleteDialog(context, ref);
            },
            backgroundColor: context.colors.error,
            foregroundColor: context.colors.onError,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getTypeIcon(), color: typeColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        contribution.contributorName,
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        contribution.projectName,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (contribution.value != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${contribution.value} ${contribution.unit ?? ''}',
                      style: TextStyle(
                        color: typeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              contribution.description,
              style: context.textTheme.bodyMedium,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'By ${contribution.recordedByName}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: context.colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      contribution.timestamp.toRelativeString(),
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Contribution'),
            content: const Text(
              'Are you sure you want to delete this contribution? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(contributionNotifierProvider.notifier)
                      .deleteContribution(contribution.id);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.error,
                  foregroundColor: context.colors.onError,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}
