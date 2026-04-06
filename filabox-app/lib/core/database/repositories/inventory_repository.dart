import 'filament_repository.dart';
import 'position_repository.dart';
import '../app_database.dart';

class InventoryItem {
  final String id;
  final String filamentTypeId;
  final String status; // standby, loaded, drying, used_up
  final double? actualPrice;
  final String? loadedPositionId;
  final DateTime? loadedAt;
  final DateTime? unloadedAt;
  final double remainingPercent;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Joined data
  final FilamentType? filamentType;
  final Position? position;

  InventoryItem({
    required this.id,
    required this.filamentTypeId,
    required this.status,
    this.actualPrice,
    this.loadedPositionId,
    this.loadedAt,
    this.unloadedAt,
    required this.remainingPercent,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.filamentType,
    this.position,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> m, {FilamentType? ft, Position? pos}) =>
      InventoryItem(
        id: m['id'] as String,
        filamentTypeId: m['filament_type_id'] as String,
        status: m['status'] as String,
        actualPrice: (m['actual_price'] as num?)?.toDouble(),
        loadedPositionId: m['loaded_position_id'] as String?,
        loadedAt: m['loaded_at'] != null ? DateTime.parse(m['loaded_at'] as String) : null,
        unloadedAt: m['unloaded_at'] != null ? DateTime.parse(m['unloaded_at'] as String) : null,
        remainingPercent: (m['remaining_percent'] as num).toDouble(),
        notes: m['notes'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
        filamentType: ft,
        position: pos,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'filament_type_id': filamentTypeId,
        'status': status,
        'actual_price': actualPrice,
        'loaded_position_id': loadedPositionId,
        'loaded_at': loadedAt?.toIso8601String(),
        'unloaded_at': unloadedAt?.toIso8601String(),
        'remaining_percent': remainingPercent,
        'notes': notes,
        'updated_at': DateTime.now().toIso8601String(),
      };

  String get qrPayload => 'FILABOX:${filamentType?.code ?? ""}?v=1&t=inventory&i=$id';

  // CRUD methods
  static Future<String> insert(InventoryItem item) async {
    final db = await AppDatabase.database;
    await db.insert('inventory_item', item.toMap());
    return item.id;
  }

  static Future<void> update(InventoryItem item) async {
    final db = await AppDatabase.database;
    await db.update(
      'inventory_item',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  static Future<void> softDelete(String id) async {
    final db = await AppDatabase.database;
    await db.update(
      'inventory_item',
      {'is_deleted': 1, 'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<InventoryItem?> getById(String id) async {
    final db = await AppDatabase.database;
    final maps = await db.rawQuery('''
      SELECT i.*,
             f.code as ft_code, f.brand as ft_brand, f.model as ft_model,
             f.color_name as ft_color_name, f.color_hex as ft_color_hex,
             f.diameter as ft_diameter, f.print_temp_min as ft_print_temp_min,
             f.print_temp_max as ft_print_temp_max,
             p.name as pos_name
      FROM inventory_item i
      LEFT JOIN filament_type f ON i.filament_type_id = f.id
      LEFT JOIN position p ON i.loaded_position_id = p.id
      WHERE i.id = ? AND i.is_deleted = 0
    ''', [id]);
    if (maps.isEmpty) return null;

    final m = maps.first;
    FilamentType? ft;
    if (m['ft_code'] != null) {
      ft = FilamentType(
        id: m['filament_type_id'] as String,
        code: m['ft_code'] as String,
        brand: m['ft_brand'] as String,
        model: m['ft_model'] as String,
        diameter: (m['ft_diameter'] as num).toDouble(),
        colorName: m['ft_color_name'] as String,
        colorHex: m['ft_color_hex'] as String?,
        printTempMin: m['ft_print_temp_min'] as int?,
        printTempMax: m['ft_print_temp_max'] as int?,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    Position? pos;
    if (m['pos_name'] != null) {
      pos = Position(
        id: m['loaded_position_id'] as String,
        name: m['pos_name'] as String,
        type: '',
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime.now(),
      );
    }
    return InventoryItem.fromMap(m, ft: ft, pos: pos);
  }

  static Future<void> updateStatus(
    String id, {
    required String status,
    String? loadedPositionId,
    DateTime? loadedAt,
    DateTime? unloadedAt,
    double? remainingPercent,
  }) async {
    final db = await AppDatabase.database;
    final values = <String, dynamic>{
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (loadedPositionId != null) values['loaded_position_id'] = loadedPositionId;
    if (loadedAt != null) values['loaded_at'] = loadedAt.toIso8601String();
    if (unloadedAt != null) values['unloaded_at'] = unloadedAt.toIso8601String();
    if (remainingPercent != null) values['remaining_percent'] = remainingPercent;
    await db.update('inventory_item', values, where: 'id = ?', whereArgs: [id]);
  }
}
