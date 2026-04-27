import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/presentation/providers/project_provider.dart';
import 'package:go_router/go_router.dart';

class ProjectsScreen extends ConsumerWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(projectsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filters
            },
          ),
        ],
      ),
      body: projectsAsync.when(
        data: (projects) => _ProjectsList(projects: projects),
        loading: () => const LoadingWidget(),
        error:
            (error, stack) => AppErrorWidget(
              message: error.toString(),
              onRetry: () => ref.invalidate(projectsProvider),
            ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/projects/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Project'),
      ),
    );
  }
}

class _ProjectsList extends StatelessWidget {
  final List<Project> projects;

  const _ProjectsList({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return EmptyStateWidget(
        message: 'No projects yet. Create your first project to get started.',
        icon: Icons.folder_open_outlined,
        actionLabel: 'Create Project',
        onAction: () => context.push('/projects/create'),
      );
    }

    final activeProjects =
        projects.where((p) => p.isActive || p.isPaused).toList();
    final completedProjects =
        projects.where((p) => p.isCompleted || p.isArchived).toList();

    return CustomScrollView(
      slivers: [
        if (activeProjects.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Active Projects',
              actionLabel: 'View All',
              onAction: () {
                // TODO: Filter active
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProjectCard(project: activeProjects[index]),
                );
              }, childCount: activeProjects.length),
            ),
          ),
        ],
        if (completedProjects.isNotEmpty) ...[
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Completed & Archived'),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ProjectCard(project: completedProjects[index]),
                );
              }, childCount: completedProjects.length),
            ),
          ),
        ],
        const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
      ],
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final Project project;

  const _ProjectCard({required this.project});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push('/projects/${project.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  project.title,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(status: project.status),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            project.description,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurfaceVariant,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 14,
                color: context.colors.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Started ${project.startDate.toDateString()}',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              if (project.deadline != null) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.event,
                  size: 14,
                  color: context.colors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Due ${project.deadline!.toDateString()}',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: project.progress.clamp(0.0, 1.0),
              backgroundColor: context.colors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(
                project.isActive
                    ? context.colors.primary
                    : context.giveTrack.chartNeutral,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 14,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${project.contributorIds.length} contributors',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.volunteer_activism_outlined,
                    size: 14,
                    color: context.colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${project.contributionIds.length} contributions',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: context.colors.outline,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
