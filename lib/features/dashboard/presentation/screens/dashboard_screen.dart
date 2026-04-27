import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/config/app_design_tokens.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/core/widgets/common_widgets.dart';
import 'package:give_track/features/auth/presentation/providers/auth_provider.dart';
import 'package:give_track/features/contributions/domain/entities/contribution.dart';
import 'package:give_track/features/contributions/presentation/providers/contribution_provider.dart';
import 'package:give_track/features/projects/domain/entities/project.dart';
import 'package:give_track/features/projects/presentation/providers/project_provider.dart';
import 'package:go_router/go_router.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final projectsAsync = ref.watch(projectsProvider);
    final recentContributionsAsync = ref.watch(recentContributionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Notifications
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: context.colors.primary.withValues(alpha: 0.1),
              child: Text(
                user?.displayName.isNotEmpty ?? false
                    ? user!.displayName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  color: context.colors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(projectsProvider);
          ref.invalidate(recentContributionsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Welcome back,',
                style: context.textTheme.bodyLarge?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              Text(
                user?.displayName ?? 'Leader',
                style: context.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Stats Cards
              projectsAsync.when(
                data: (projects) => _StatsOverview(projects: projects),
                loading:
                    () => const SizedBox(height: 120, child: LoadingWidget()),
                error: (_, _) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),

              // Chart Section
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Contributions Overview',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Last 7 Days',
                            style: TextStyle(
                              color: context.colors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(height: 200, child: _ContributionsChart()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Contribution Types Pie Chart
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contribution Types',
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(height: 180, child: _ContributionTypesPieChart()),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Recent Contributions
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Recent Contributions',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/contributions'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    recentContributionsAsync.when(
                      data:
                          (contributions) => _RecentContributionsList(
                            contributions: contributions,
                          ),
                      loading:
                          () => const SizedBox(
                            height: 100,
                            child: LoadingWidget(),
                          ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Active Projects
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Active Projects',
                          style: context.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/projects'),
                          child: const Text('View All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    projectsAsync.when(
                      data: (projects) {
                        final active =
                            projects.where((p) => p.isActive).toList();
                        return _ActiveProjectsList(projects: active);
                      },
                      loading:
                          () => const SizedBox(
                            height: 100,
                            child: LoadingWidget(),
                          ),
                      error: (_, _) => const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsOverview extends StatelessWidget {
  final List<Project> projects;

  const _StatsOverview({required this.projects});

  @override
  Widget build(BuildContext context) {
    final activeProjects = projects.where((p) => p.isActive).length;
    final totalContributions = projects.fold<int>(
      0,
      (sum, p) => sum + p.contributionIds.length,
    );
    final totalContributors =
        projects
            .fold<Set<String>>({}, (set, p) => set..addAll(p.contributorIds))
            .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.folder_open,
            label: 'Active Projects',
            value: activeProjects.toString(),
            color: context.colors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.volunteer_activism,
            label: 'Contributions',
            value: totalContributions.toString(),
            color: context.colors.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people,
            label: 'Contributors',
            value: totalContributors.toString(),
            color: context.giveTrack.chartOrange,
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            value,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
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

class _ContributionsChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => context.colors.surfaceContainerHighest,
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                if (value >= 0 && value < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.onSurfaceVariant,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          _makeBarData(0, 3, context.colors.primary),
          _makeBarData(1, 5, context.colors.primary),
          _makeBarData(2, 2, context.colors.primary),
          _makeBarData(3, 7, context.colors.primary),
          _makeBarData(4, 4, context.colors.primary),
          _makeBarData(5, 6, context.colors.primary),
          _makeBarData(6, 8, context.colors.primary),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarData(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 16,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
        ),
      ],
    );
  }
}

class _ContributionTypesPieChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: [
          PieChartSectionData(
            color: context.colors.primary,
            value: 40,
            title: '40%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.colors.onPrimary,
            ),
          ),
          PieChartSectionData(
            color: context.colors.secondary,
            value: 30,
            title: '30%',
            radius: 50,
            titleStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: context.colors.onSecondary,
            ),
          ),
          PieChartSectionData(
            color: context.giveTrack.chartOrange,
            value: 20,
            title: '20%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          PieChartSectionData(
            color: context.giveTrack.chartNeutral,
            value: 10,
            title: '10%',
            radius: 50,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentContributionsList extends StatelessWidget {
  final List<Contribution> contributions;

  const _RecentContributionsList({required this.contributions});

  @override
  Widget build(BuildContext context) {
    if (contributions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No recent contributions'),
      );
    }

    return Column(
      children:
          contributions.take(5).map((contribution) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: context.colors.primary.withValues(alpha: 0.1),
                child: Icon(
                  Icons.volunteer_activism,
                  color: context.colors.primary,
                  size: 18,
                ),
              ),
              title: Text(
                contribution.contributorName,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Text(
                contribution.projectName,
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (contribution.value != null)
                    Text(
                      '${contribution.value} ${contribution.unit ?? ''}',
                      style: context.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  Text(
                    contribution.timestamp.toRelativeString(),
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colors.outline,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}

class _ActiveProjectsList extends StatelessWidget {
  final List<Project> projects;

  const _ActiveProjectsList({required this.projects});

  @override
  Widget build(BuildContext context) {
    if (projects.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No active projects'),
      );
    }

    return Column(
      children:
          projects.take(3).map((project) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.folder,
                  color: context.colors.primary,
                  size: 20,
                ),
              ),
              title: Text(
                project.title,
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '${project.contributionIds.length} contributions',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              trailing: SizedBox(
                width: 60,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: project.progress.clamp(0.0, 1.0),
                        backgroundColor: context.colors.surfaceContainerHigh,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          context.colors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(project.progress * 100).toInt()}%',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              onTap: () => context.push('/projects/${project.id}'),
            );
          }).toList(),
    );
  }
}
