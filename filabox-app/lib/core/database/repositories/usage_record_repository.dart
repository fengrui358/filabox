import '../app_database.dart';

class UsageRecord {
  final String id;
  final String inventoryItemId;
  final String action; // stock_in, load, unload, dry_start, dry_end, use_up
  final String? positionId;
  final DateTime occurredAt;
  final int? durationMinutes;
  final String? metadata;
  final DateTime createdAt;

  UsageRecord({
    required this.id,
    required this.inventoryItemId,
    required this.action,
    this.positionId,
    required this.occurredAt,
    this.durationMinutes,
    this.metadata,
    required this.createdAt,
  });

  factory UsageRecord.fromMap(Map<String, dynamic> m) => UsageRecord(
        id: m['id'] as String,
        inventoryItemId: m['inventory_item_id'] as String,
        action: m['action'] as String,
        positionId: m['position_id'] as String?,
        occurredAt: DateTime.parse(m['occurred_at'] as String),
        durationMinutes: m['duration_minutes'] as int?,
        metadata: m['metadata'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'inventory_item_id': inventoryItemId,
        'action': action,
        'position_id': positionId,
        'occurred_at': occurredAt.toIso8601String(),
        'duration_minutes': durationMinutes,
        'metadata': metadata,
        'created_at': createdAt.toIso8601String(),
      };

  static Future<String> insert(UsageRecord record) async {
    final db = await AppDatabase.database;
    await db.insert('usage_record', record.toMap());
    return record.id;
  }

  static Future<List<UsageRecord>> getByItemId(String inventoryItemId) async {
    final db = await AppDatabase.database;
    final maps = await db.query(
      'usage_record',
      where: 'inventory_item_id = ?',
      whereArgs: [inventoryItemId],
      orderBy: 'occurred_at DESC',
    );
    return maps.map((m) => UsageRecord.fromMap(m)).toList();
  }
}
