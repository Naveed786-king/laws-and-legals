import 'package:cloud_firestore/cloud_firestore.dart';

class MenuItem {
  final String label;
  final String type; // 'category' | 'page'
  final String targetId; // categoryId or page slug

  const MenuItem({required this.label, required this.type, required this.targetId});

  factory MenuItem.fromMap(Map<String, dynamic> map) => MenuItem(
        label: map['label'] ?? '',
        type: map['type'] ?? 'category',
        targetId: map['targetId'] ?? '',
      );
}

/// Reads the admin-configured navigation menu (Admin Panel > Menu). Each
/// entry points at either a category or a custom page. Falls back to an
/// empty list (drawer just shows Home/Bookmarks/Settings) if nothing has
/// been configured yet.
class MenuService {
  static Future<List<MenuItem>> getMenuItems() async {
    try {
      final doc = await FirebaseFirestore.instance.collection('menu').doc('config').get();
      if (!doc.exists) return [];
      final items = (doc.data()?['items'] as List?) ?? [];
      return items.map((e) => MenuItem.fromMap(Map<String, dynamic>.from(e))).toList();
    } catch (_) {
      return [];
    }
  }
}
