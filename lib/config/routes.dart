import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/config/router_refresh.dart';
import 'package:give_track/features/auth/presentation/providers/auth_provider.dart';
import 'package:give_track/features/auth/presentation/screens/login_screen.dart';
import 'package:give_track/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:give_track/features/contributions/presentation/screens/contributions_screen.dart';
import 'package:give_track/features/contributions/presentation/screens/contributors_screen.dart';
import 'package:give_track/features/contributions/presentation/screens/record_contribution_screen.dart';
import 'package:give_track/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:give_track/features/projects/presentation/screens/create_project_screen.dart';
import 'package:give_track/features/projects/presentation/screens/project_detail_screen.dart';
import 'package:give_track/features/projects/presentation/screens/projects_screen.dart';
import 'package:give_track/features/settings/presentation/screens/invite_leaders_screen.dart';
import 'package:give_track/features/settings/presentation/screens/settings_screen.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');

final routerProvider = Provider<GoRouter>((ref) {
  final authRefresh = ref.watch(routerAuthRefreshProvider);
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    refreshListenable: authRefresh,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authState.maybeWhen(
        data: (user) => user != null,
        orElse: () => false,
      );
      final isAuthRoute =
          state.matchedLocation == '/' ||
          state.matchedLocation == '/onboarding';

      if (!isLoggedIn && !isAuthRoute) {
        return '/';
      }
      if (isLoggedIn && isAuthRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => ScaffoldWithNavBar(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/projects',
            name: 'projects',
            builder: (context, state) => const ProjectsScreen(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'createProject',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const CreateProjectScreen(),
              ),
              GoRoute(
                path: ':id',
                name: 'projectDetail',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) {
                  final id = state.pathParameters['id']!;
                  return ProjectDetailScreen(projectId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/contributions',
            name: 'contributions',
            builder: (context, state) => const ContributionsScreen(),
            routes: [
              GoRoute(
                path: 'record',
                name: 'recordContribution',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const RecordContributionScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/contributors',
            name: 'contributors',
            builder: (context, state) => const ContributorsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
            routes: [
              GoRoute(
                path: 'invite',
                name: 'inviteLeaders',
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const InviteLeadersScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final Widget child;
  const ScaffoldWithNavBar({required this.child, super.key});

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/dashboard')) return 0;
    if (location.startsWith('/projects')) return 1;
    if (location.startsWith('/contributions')) return 2;
    if (location.startsWith('/contributors')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/dashboard');
      case 1:
        context.go('/projects');
      case 2:
        context.go('/contributions');
      case 3:
        context.go('/contributors');
      case 4:
        context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex(context),
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.folder_outlined),
            selectedIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          NavigationDestination(
            icon: Icon(Icons.volunteer_activism_outlined),
            selectedIcon: Icon(Icons.volunteer_activism),
            label: 'Contributions',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Contributors',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
