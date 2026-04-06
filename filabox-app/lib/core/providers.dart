import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database/app_database.dart';
import 'database/repositories/filament_repository.dart';
import 'database/repositories/inventory_repository.dart';
import 'database/repositories/position_repository.dart';
import 'network/api_client.dart';
import 'services/qr_service.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

// Filament Types
final filamentTypesProvider = FutureProvider<List<FilamentType>>((ref) async {
  final db = await AppDatabase.database;
  final maps = await db.query(
    'filament_type',
    where: 'is_deleted = 0',
    orderBy: 'brand ASC, model ASC, color_name ASC',
  );
  return maps.map((m) => FilamentType.fromMap(m)).toList();
});

final filamentBrandsProvider = FutureProvider<List<String>>((ref) async {
  final db = await AppDatabase.database;
  final result = await db.rawQuery(
    'SELECT DISTINCT brand FROM filament_type WHERE is_deleted = 0 ORDER BY brand',
  );
  return result.map((r) => r['brand'] as String).toList();
});

final filamentModelsProvider = FutureProvider<List<String>>((ref) async {
  final db = await AppDatabase.database;
  final result = await db.rawQuery(
    'SELECT DISTINCT model FROM filament_type WHERE is_deleted = 0 ORDER BY model',
  );
  return result.map((r) => r['model'] as String).toList();
});

// Inventory
final inventoryProvider = FutureProvider<List<InventoryItem>>((ref) async {
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
    WHERE i.is_deleted = 0
    ORDER BY i.created_at DESC
  ''');

  return maps.map((m) {
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
  }).toList();
});

final inventoryStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = await AppDatabase.database;
  final result = await db.rawQuery('''
    SELECT status, COUNT(*) as count
    FROM inventory_item
    WHERE is_deleted = 0
    GROUP BY status
  ''');
  final stats = <String, int>{
    'standby': 0,
    'loaded': 0,
    'drying': 0,
    'used_up': 0,
  };
  for (final row in result) {
    stats[row['status'] as String] = (row['count'] as num).toInt();
  }
  return stats;
});

// Positions
final positionsProvider = FutureProvider<List<Position>>((ref) async {
  final db = await AppDatabase.database;
  final maps = await db.query(
    'position',
    where: 'is_active = 1',
    orderBy: 'sort_order ASC',
  );
  return maps.map((m) => Position.fromMap(m)).toList();
});

// QR
final qrServiceProvider = Provider<QrPayload>((ref) => const QrPayload(code: '', type: ''));
