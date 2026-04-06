import 'filament_repository.dart';
import 'position_repository.dart';

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

  String get qrPayload => 'FILABOX:${filamentType?.code ?? ""}:i=$id?v=1&t=inventory';
}
