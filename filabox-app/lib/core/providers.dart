import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'database/app_database.dart';
import 'database/repositories/filament_repository.dart';
import 'database/repositories/inventory_repository.dart';
import 'database/repositories/position_repository.dart';
import 'database/repositories/usage_record_repository.dart';
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

// Single filament by ID
final filamentByIdProvider =
    FutureProvider.family<FilamentType?, String>((ref, id) async {
  return FilamentType.getById(id);
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

// Single inventory item by ID
final inventoryByIdProvider =
    FutureProvider.family<InventoryItem?, String>((ref, id) async {
  return InventoryItem.getById(id);
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

// RepositoryService — central place for all write operations
final repositoryServiceProvider = Provider<RepositoryService>((ref) {
  return RepositoryService(ref);
});

class RepositoryService {
  final Ref _ref;
  static const _uuid = Uuid();

  RepositoryService(this._ref);

  void _invalidateFilament() {
    _ref.invalidate(filamentTypesProvider);
    _ref.invalidate(filamentBrandsProvider);
    _ref.invalidate(filamentModelsProvider);
  }

  void _invalidateInventory() {
    _ref.invalidate(inventoryProvider);
    _ref.invalidate(inventoryStatsProvider);
  }

  void _invalidatePositions() {
    _ref.invalidate(positionsProvider);
  }

  // Filament mutations
  Future<String> addFilamentType(FilamentType ft) async {
    final id = await FilamentType.insert(ft);
    _invalidateFilament();
    return id;
  }

  Future<void> editFilamentType(FilamentType ft) async {
    await FilamentType.update(ft);
    _invalidateFilament();
  }

  Future<void> removeFilamentType(String id) async {
    await FilamentType.softDelete(id);
    _invalidateFilament();
  }

  // Inventory mutations
  Future<String> addInventoryItem(InventoryItem item) async {
    final id = await InventoryItem.insert(item);
    // Create stock_in usage record
    await UsageRecord.insert(UsageRecord(
      id: _uuid.v4(),
      inventoryItemId: id,
      action: 'stock_in',
      occurredAt: DateTime.now(),
      createdAt: DateTime.now(),
    ));
    _invalidateInventory();
    return id;
  }

  Future<void> loadToPosition(String itemId, String positionId) async {
    final now = DateTime.now();
    await InventoryItem.updateStatus(
      itemId,
      status: 'loaded',
      loadedPositionId: positionId,
      loadedAt: now,
    );
    await UsageRecord.insert(UsageRecord(
      id: _uuid.v4(),
      inventoryItemId: itemId,
      action: 'load',
      positionId: positionId,
      occurredAt: now,
      createdAt: now,
    ));
    _invalidateInventory();
  }

  Future<void> unloadFromPosition(String itemId, {double? remaining}) async {
    final now = DateTime.now();
    // Calculate duration if we have loadedAt
    int? durationMinutes;
    final item = await InventoryItem.getById(itemId);
    if (item?.loadedAt != null) {
      durationMinutes = now.difference(item!.loadedAt!).inMinutes;
    }

    final newStatus = (remaining != null && remaining <= 0) ? 'used_up' : 'standby';
    final newRemaining = (remaining != null && remaining <= 0) ? 0.0 : (remaining ?? item?.remainingPercent ?? 100.0);

    await InventoryItem.updateStatus(
      itemId,
      status: newStatus,
      unloadedAt: now,
      remainingPercent: newRemaining,
    );
    await UsageRecord.insert(UsageRecord(
      id: _uuid.v4(),
      inventoryItemId: itemId,
      action: newStatus == 'used_up' ? 'use_up' : 'unload',
      positionId: item?.loadedPositionId,
      occurredAt: now,
      durationMinutes: durationMinutes,
      createdAt: now,
    ));
    _invalidateInventory();
  }

  Future<void> startDrying(String itemId) async {
    final now = DateTime.now();
    await InventoryItem.updateStatus(itemId, status: 'drying');
    await UsageRecord.insert(UsageRecord(
      id: _uuid.v4(),
      inventoryItemId: itemId,
      action: 'dry_start',
      occurredAt: now,
      createdAt: now,
    ));
    _invalidateInventory();
  }

  Future<void> endDrying(String itemId) async {
    final now = DateTime.now();
    await InventoryItem.updateStatus(itemId, status: 'standby');
    await UsageRecord.insert(UsageRecord(
      id: _uuid.v4(),
      inventoryItemId: itemId,
      action: 'dry_end',
      occurredAt: now,
      createdAt: now,
    ));
    _invalidateInventory();
  }

  Future<void> markUsedUp(String itemId) async {
    final now = DateTime.now();
    await InventoryItem.updateStatus(
      itemId,
      status: 'used_up',
      remainingPercent: 0,
    );
    await UsageRecord.insert(UsageRecord(
      id: _uuid.v4(),
      inventoryItemId: itemId,
      action: 'use_up',
      occurredAt: now,
      createdAt: now,
    ));
    _invalidateInventory();
  }

  // Position mutations
  Future<String> addPosition(Position p) async {
    final id = await Position.insert(p);
    _invalidatePositions();
    return id;
  }

  Future<void> editPosition(Position p) async {
    await Position.update(p);
    _invalidatePositions();
  }

  Future<void> removePosition(String id) async {
    await Position.softDelete(id);
    _invalidatePositions();
  }
}
