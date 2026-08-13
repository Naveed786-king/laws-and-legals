import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../application/menu_service.dart';
import '../../categories/presentation/category_screen.dart';
import '../../pages/presentation/page_detail_screen.dart';
import '../../bookmarks/presentation/bookmarks_screen.dart';

/// Left-side navigation drawer. Menu entries come from the Admin Panel
/// (Menu tab) - each points at a category or a custom page. Falls back to
/// just Bookmarks if nothing has been configured yet.
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        top: false,
        child: FutureBuilder<List<MenuItem>>(
          future: MenuService.getMenuItems(),
          builder: (context, snapshot) {
            final items = snapshot.data ?? [];
            return ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerLogoHeader(),
                if (items.isNotEmpty) const Divider(height: 1),
                for (final item in items)
                  ListTile(
                    title: Text(item.label),
                    onTap: () {
                      Navigator.pop(context);
                      if (item.type == 'home') {
                        // Already at Home when the drawer opens (only wired
                        // in on HomeScreen); just close the drawer.
                      } else if (item.type == 'page') {
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
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.bookmark_border),
                  title: const Text('Bookmarks'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BookmarksScreen()));
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

/// Top of the drawer: shows the admin-set logo with no extra top gap.
/// Falls back to plain text if no logo has been configured.
class _DrawerLogoHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).colorScheme.primary,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: FutureBuilder<String?>(
        future: _fetchLogoUrl(),
        builder: (context, snapshot) {
          final url = snapshot.data;
          if (url == null || url.isEmpty) {
            return const Text(
              'Laws And Legals',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
            );
          }
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: url,
              height: 44,
              fit: BoxFit.contain,
              alignment: Alignment.centerLeft,
              errorWidget: (c, _, __) => const Text(
                'Laws And Legals',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String?> _fetchLogoUrl() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('splash').doc('config').get();
      final url = doc.data()?['logoUrl'] as String?;
      return (url != null && url.isNotEmpty) ? url : null;
    } catch (_) {
      return null;
    }
  }
}
