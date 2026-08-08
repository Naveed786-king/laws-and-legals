import 'package:flutter/material.dart';
import '../application/menu_service.dart';
import '../../categories/presentation/category_screen.dart';
import '../../pages/presentation/page_detail_screen.dart';
import '../../bookmarks/presentation/bookmarks_screen.dart';
import '../../settings/presentation/settings_screen.dart';

/// Left-side navigation drawer. Menu entries come from the Admin Panel
/// (Menu tab) - each points at a category or a custom page. Falls back to
/// just the built-in destinations if nothing has been configured yet.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: FutureBuilder<List<MenuItem>>(
          future: MenuService.getMenuItems(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
                  child: const Align(
                    alignment: Alignment.bottomLeft,
                    child: Text('Laws And Legals',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Bookmarks'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookmarksScreen()));
                  },
                ),
                if (items.isNotEmpty) const Divider(),
                for (final item in items)
                  ListTile(
                    title: Text(item.label),
                    onTap: () {
                      Navigator.pop(context);
                      if (item.type == 'page') {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => PageDetailScreen(slug: item.targetId)),
                        );
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CategoryScreen(categoryId: item.targetId, categoryName: item.label),
                          ),
                        );
                      }
                    },
                  ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
