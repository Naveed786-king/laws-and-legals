import 'package:flutter/material.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/categories/presentation/categories_list_screen.dart';
import '../../features/bookmarks/presentation/bookmarks_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/notifications/application/notification_service.dart';

/// Bottom navigation shell: Home, Categories, Bookmarks, Search, Settings.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  String? _lastSeenNotificationId;
  bool _isFirstSnapshot = true;

  static const _screens = [
    HomeScreen(),
    CategoriesListScreen(),
    BookmarksScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    NotificationService.watchNotifications().listen((notifications) {
      if (notifications.isEmpty) return;
      final latest = notifications.first;
      if (_isFirstSnapshot) {
        // Don't show a banner for notifications that already existed
        // before this screen opened - only genuinely new ones.
        _isFirstSnapshot = false;
        _lastSeenNotificationId = latest.id;
        return;
      }
      if (latest.id != _lastSeenNotificationId) {
        _lastSeenNotificationId = latest.id;
        NotificationService.showLocalNotification(latest);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${latest.title}: ${latest.body}'),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.grid_view_outlined), selectedIcon: Icon(Icons.grid_view), label: 'Categories'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'Bookmarks'),
          NavigationDestination(icon: Icon(Icons.search), selectedIcon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}
