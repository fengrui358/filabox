import '../app_database.dart';

class Position {
  final String id;
  final String name;
  final String type; // printer, dry_box, storage
  final int sortOrder;
  final bool isActive;
  final DateTime createdAt;

  Position({
    required this.id,
    required this.name,
    required this.type,
    required this.sortOrder,
    required this.isActive,
    required this.createdAt,
  });

  factory Position.fromMap(Map<String, dynamic> m) => Position(
        id: m['id'] as String,
        name: m['name'] as String,
        type: m['type'] as String,
        sortOrder: m['sort_order'] as int,
        isActive: (m['is_active'] as int) == 1,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'sort_order': sortOrder,
        'is_active': isActive ? 1 : 0,
      };

  // CRUD methods
  static Future<String> insert(Position p) async {
    final db = await AppDatabase.database;
    await db.insert('position', p.toMap());
    return p.id;
  }

  static Future<void> update(Position p) async {
    final db = await AppDatabase.database;
    await db.update('position', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  static Future<void> softDelete(String id) async {
    final db = await AppDatabase.database;
    await db.update(
      'position',
      {'is_active': 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
