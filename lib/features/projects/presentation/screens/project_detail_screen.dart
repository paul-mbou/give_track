import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/presentation/providers/project_provider.dart';
import 'package:go_router/go_router.dart';

class ProjectDetailScreen extends ConsumerWidget {
  final String projectId;

  const ProjectDetailScreen({required this.projectId, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectDetailProvider(projectId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  // TODO: Navigate to edit
                  return;
                case 'archive':
                  _showArchiveDialog(context, ref);
                  return;
                case 'invite':
                  context.push('/settings/invite');
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 8),
                        Text('Edit Project'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'invite',
                    child: Row(
                      children: [
                        Icon(Icons.person_add_outlined),
                        SizedBox(width: 8),
                        Text('Invite Leaders'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'archive',
                    child: Row(
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          color: context.colors.tertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Archive',
                          style: TextStyle(color: context.colors.tertiary),
                        ),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: projectAsync.when(
        data: (project) => _ProjectDetailContent(project: project),
        loading: () => const LoadingWidget(),
        error:
            (error, stack) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(projectDetailProvider(projectId)),
            ),
      ),
    );
  }

  void _showArchiveDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Archive Project'),
            content: const Text(
              'Are you sure you want to archive this project? It will be moved to read-only mode.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(projectNotifierProvider.notifier)
                      .archiveProject(projectId);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.tertiary,
                  foregroundColor: context.colors.onTertiary,
                ),
                child: const Text('Archive'),
              ),
            ],
          ),
    );
  }
}

class _ProjectDetailContent extends StatelessWidget {
  final Project project;

  const _ProjectDetailContent({required this.project});

  @override
  Widget build(BuildContext context) {
    final giveTrack = context.giveTrack;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        project.title,
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusBadge(status: project.status),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  project.description,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  icon: Icons.lightbulb_outline,
                  label: 'Motif',
                  value: project.motif,
                ),
                const SizedBox(height: 12),
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Start Date',
                  value: project.startDate.toDateString(),
                ),
                if (project.deadline != null) ...[
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.event,
                    label: 'Deadline',
                    value: project.deadline!.toDateString(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.volunteer_activism,
                  label: 'Contributions',
                  value: project.contributionIds.length.toString(),
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.people,
                  label: 'Contributors',
                  value: project.contributorIds.length.toString(),
                  color: context.colors.secondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  icon: Icons.person_outline,
                  label: 'Leaders',
                  value: project.leaderIds.length.toString(),
                  color: giveTrack.chartOrange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  icon: Icons.trending_up,
                  label: 'Progress',
                  value: '${(project.progress * 100).toInt()}%',
                  color: giveTrack.chartGrass,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Progress Section
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Progress',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: project.progress.clamp(0.0, 1.0),
                    backgroundColor: context.colors.surfaceContainerHigh,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primary,
                    ),
                    minHeight: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${project.contributionIds.length} of 10 target contributions',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Activity
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Activity',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: View all activity
                      },
                      child: const Text('View All'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _ActivityItem(
                  icon: Icons.add_circle,
                  title: 'New contribution recorded',
                  subtitle: 'By Jean Dupont',
                  time: '2 hours ago',
                  color: context.colors.primary,
                ),
                const Divider(),
                _ActivityItem(
                  icon: Icons.person_add,
                  title: 'New contributor added',
                  subtitle: 'Marie Martin joined',
                  time: '5 hours ago',
                  color: context.colors.secondary,
                ),
                const Divider(),
                _ActivityItem(
                  icon: Icons.edit,
                  title: 'Project updated',
                  subtitle: 'Deadline extended',
                  time: '1 day ago',
                  color: giveTrack.chartOrange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: context.colors.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(value, style: context.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: context.textTheme.bodySmall?.copyWith(
              color: context.colors.outline,
            ),
          ),
        ],
      ),
    );
  }
}
