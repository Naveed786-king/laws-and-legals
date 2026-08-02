import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/theme_controller.dart';
import '../../../core/providers/core_providers.dart';
import '../application/settings_providers.dart';
import 'configure_everything_screen.dart';
import '../../pages/presentation/pages_list_screen.dart';
import '../../youtube/presentation/youtube_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final demoModeAsync = ref.watch(isDemoModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          demoModeAsync.when(
            data: (isDemo) => _StatusBanner(isDemo: isDemo),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
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
          ListTile(
            leading: const Icon(Icons.smart_display_outlined),
            title: const Text('YouTube Channel'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const YoutubeScreen()),
            ),
          ),
          const Divider(),
          const _SectionLabel('Notifications'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Requires permission - triggered later from WordPress admin'),
            value: false,
            onChanged: (_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Enable after completing Configure Everything')),
              );
            },
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
          const _SectionLabel('WordPress Integration'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              icon: const Icon(Icons.settings_ethernet),
              label: const Text('Configure Everything'),
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ConfigureEverythingScreen()),
              ),
            ),
          ),
          const Divider(),
          const _SectionLabel('Developer'),
          SwitchListTile(
            title: const Text('Developer Mode'),
            subtitle: const Text('Show raw config values and demo-mode indicator'),
            value: false,
            onChanged: (_) {},
          ),
          const _AppVersionTile(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.isDemo});
  final bool isDemo;

  @override
  Widget build(BuildContext context) {
    final color = isDemo ? Colors.orange : Colors.green;
    return Container(
      width: double.infinity,
      color: color.withOpacity(0.12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(isDemo ? Icons.science_outlined : Icons.check_circle_outline, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isDemo
                  ? 'Demo Mode - showing bundled sample content'
                  : 'Live - connected to your WordPress site',
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
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
