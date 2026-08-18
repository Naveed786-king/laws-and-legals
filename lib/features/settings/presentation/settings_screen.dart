import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/theme_controller.dart';
import '../../pages/presentation/pages_list_screen.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../notifications/application/notification_service.dart';
import '../../menu/presentation/app_drawer.dart';
import '../../auth/application/auth_service.dart';
import '../../auth/presentation/login_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Settings'),
        actions: [
          Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        ],
      ),
      body: ListView(
        children: [
          const _SectionLabel('Profile'),
          const _ProfileTile(),
          const Divider(),
          const _SectionLabel('Appearance'),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeControllerProvider.notifier).setMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeControllerProvider.notifier).setMode(m!),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (m) => ref.read(themeControllerProvider.notifier).setMode(m!),
          ),
          const Divider(),
          const _SectionLabel('Content'),
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Pages'),
            subtitle: const Text('About, Contact, Advertise, Privacy, Terms'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PagesListScreen()),
            ),
          ),
          const Divider(),
          const _SectionLabel('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Get notified in real time while the app is open'),
            value: true,
            onChanged: (_) async {
              await NotificationService.requestPermission();
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notification History'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          const Divider(),
          const _SectionLabel('Storage'),
          ListTile(
            leading: const Icon(Icons.cleaning_services_outlined),
            title: const Text('Clear Cache'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared')),
              );
            },
          ),
          const Divider(),
          const _AppVersionTile(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return ListTile(
            leading: const Icon(Icons.account_circle_outlined),
            title: const Text('Not signed in'),
            subtitle: const Text('Sign in to sync bookmarks across devices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          );
        }
        return ListTile(
          leading: const Icon(Icons.account_circle),
          title: Text(user.displayName ?? user.email ?? 'Signed in'),
          subtitle: user.displayName != null ? Text(user.email ?? '') : null,
          trailing: TextButton(
            onPressed: () => AuthService.signOut(),
            child: const Text('Sign Out'),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .labelLarge
            ?.copyWith(color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _AppVersionTile extends StatelessWidget {
  const _AppVersionTile();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '1.0.0';
        return ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('App Version'),
          trailing: Text(version),
        );
      },
    );
  }
}
