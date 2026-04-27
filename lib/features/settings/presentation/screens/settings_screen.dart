import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:give_track/core/utils/extensions.dart';
import 'package:give_track/features/auth/domain/entities/user.dart';
import 'package:give_track/features/auth/presentation/providers/auth_provider.dart';
import 'package:give_track/features/settings/presentation/providers/settings_provider.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDarkMode = ref.watch(themeModeProvider);
    final language = ref.watch(languageProvider);
    final notificationsEnabled = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Profile Section
          _ProfileHeader(user: user),
          const Divider(),

          // Appearance
          _SettingsSection(
            title: 'Appearance',
            children: [
              SwitchListTile(
                secondary: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: context.colors.primary,
                ),
                title: const Text('Dark Mode'),
                subtitle: const Text('Toggle between light and dark theme'),
                value: isDarkMode,
                onChanged: (_) {
                  ref.read(themeModeProvider.notifier).toggleTheme();
                },
              ),
              ListTile(
                leading: Icon(Icons.language, color: context.colors.primary),
                title: const Text('Language'),
                subtitle: Text(language == 'fr' ? 'Français' : 'English'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showLanguageDialog(context, ref, language),
              ),
            ],
          ),
          const Divider(),

          // Notifications
          _SettingsSection(
            title: 'Notifications',
            children: [
              SwitchListTile(
                secondary: Icon(
                  notificationsEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: context.colors.primary,
                ),
                title: const Text('Push Notifications'),
                subtitle: const Text(
                  'Receive updates about contributions and projects',
                ),
                value: notificationsEnabled,
                onChanged: (_) {
                  ref.read(notificationsProvider.notifier).toggle();
                },
              ),
              ListTile(
                leading: Icon(Icons.campaign, color: context.colors.primary),
                title: const Text('Notification Preferences'),
                subtitle: const Text('Customize what you get notified about'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Notification preferences
                },
              ),
            ],
          ),
          const Divider(),

          // Project Management
          _SettingsSection(
            title: 'Project Management',
            children: [
              ListTile(
                leading: Icon(Icons.person_add, color: context.colors.primary),
                title: const Text('Invite Leaders'),
                subtitle: const Text('Add new leaders to your projects'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => context.push('/settings/invite'),
              ),
              ListTile(
                leading: Icon(Icons.group, color: context.colors.primary),
                title: const Text('Manage Teams'),
                subtitle: const Text('View and manage team members'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Team management
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.admin_panel_settings,
                  color: context.colors.primary,
                ),
                title: const Text('Role & Permissions'),
                subtitle: const Text('Configure access levels'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Role management
                },
              ),
            ],
          ),
          const Divider(),

          // Data & Privacy
          _SettingsSection(
            title: 'Data & Privacy',
            children: [
              ListTile(
                leading: Icon(Icons.download, color: context.colors.primary),
                title: const Text('Export Data'),
                subtitle: const Text('Download your data as PDF or Excel'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Export data
                },
              ),
              ListTile(
                leading: Icon(Icons.privacy_tip, color: context.colors.primary),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Open privacy policy
                },
              ),
              ListTile(
                leading: Icon(Icons.description, color: context.colors.primary),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Open terms
                },
              ),
            ],
          ),
          const Divider(),

          // About
          _SettingsSection(
            title: 'About',
            children: [
              ListTile(
                leading: Icon(Icons.info, color: context.colors.primary),
                title: const Text('About Give Track'),
                subtitle: const Text('Version 1.0.0'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: 'Give Track',
                    applicationVersion: '1.0.0',
                    applicationIcon: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.volunteer_activism,
                        color: context.colors.primary,
                      ),
                    ),
                    applicationLegalese:
                        '© 2026 Give Track. All rights reserved.',
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: context.colors.primary,
                ),
                title: const Text('Help & Support'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  // TODO: Help center
                },
              ),
            ],
          ),
          const Divider(),

          // Account
          _SettingsSection(
            title: 'Account',
            children: [
              ListTile(
                leading: Icon(Icons.logout, color: context.colors.error),
                title: Text(
                  'Sign Out',
                  style: TextStyle(color: context.colors.error),
                ),
                onTap: () => _showSignOutDialog(context, ref),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    WidgetRef ref,
    String currentLang,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Select Language'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<String>(
                  title: const Text('English'),
                  value: 'en',
                  groupValue: currentLang,
                  onChanged: (value) {
                    ref.read(languageProvider.notifier).setLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
                RadioListTile<String>(
                  title: const Text('Français'),
                  value: 'fr',
                  groupValue: currentLang,
                  onChanged: (value) {
                    ref.read(languageProvider.notifier).setLanguage(value!);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.error,
                  foregroundColor: context.colors.onError,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final User? user;

  const _ProfileHeader({this.user});

  @override
  Widget build(BuildContext context) {
    final profileUser = user;
    final Widget avatarChild;
    if (profileUser != null && profileUser.photoUrl != null) {
      avatarChild = ClipOval(child: Image.network(profileUser.photoUrl!));
    } else {
      final initial =
          profileUser != null && profileUser.displayName.isNotEmpty
              ? profileUser.displayName[0].toUpperCase()
              : '?';
      avatarChild = Text(
        initial,
        style: TextStyle(
          color: context.colors.primary,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: context.colors.primary.withValues(alpha: 0.1),
            child: avatarChild,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Guest User',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: context.colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    (user?.role ?? 'viewer').toUpperCase(),
                    style: TextStyle(
                      color: context.colors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // TODO: Edit profile
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: context.textTheme.titleSmall?.copyWith(
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
