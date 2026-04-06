import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/repositories/filament_repository.dart';
import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/services/qr_service.dart';
import 'scan_action_sheet.dart';

class ScanResultRouter {
  static Future<void> route(BuildContext context, QrPayload payload) async {
    if (payload.type == 'filament_type') {
      await _handleFilamentType(context, payload);
    } else if (payload.type == 'inventory') {
      await _handleInventory(context, payload);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('无法识别的二维码')),
        );
        context.pop();
      }
    }
  }

  static Future<void> _handleFilamentType(BuildContext context, QrPayload payload) async {
    final ft = await FilamentType.getByCode(payload.code);

    if (!context.mounted) return;
    if (ft == null) {
      // Filament not found — offer to create
      final create = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('未找到耗材'),
          content: Text('未找到编码为 "${payload.code}" 的耗材，是否创建新耗材？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('创建耗材'),
            ),
          ],
        ),
      );
      if (create == true && context.mounted) {
        context.pop(); // Close scanner
        context.push('/filaments/add');
      } else if (context.mounted) {
        context.pop();
      }
      return;
    }

    // Found filament — show action sheet
    context.pop(); // Close scanner first
    showScanActionSheet(
      context,
      filamentType: ft,
      actions: [
        ScanAction(
          label: '入库新件',
          icon: Icons.add_box_outlined,
          isPrimary: true,
          onTap: () => context.push('/inventory/add', extra: {'filament': ft}),
        ),
        ScanAction(
          label: '查看详情',
          icon: Icons.info_outline,
          onTap: () => context.push('/filaments/${ft.id}', extra: ft),
        ),
      ],
    );
  }

  static Future<void> _handleInventory(BuildContext context, QrPayload payload) async {
    final inventoryId = payload.inventoryId;
    if (inventoryId == null) {
      // No inventory ID — treat as filament type
      return _handleFilamentType(context, payload);
    }

    final item = await InventoryItem.getById(inventoryId);
    if (!context.mounted) return;

    if (item == null) {
      // Item not found — offer stock in
      final stockIn = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('未找到库存'),
          content: Text('未找到该库存记录，是否入库新件？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('入库'),
            ),
          ],
        ),
      );
      if (stockIn == true && context.mounted) {
        context.pop();
        context.push('/inventory/add', extra: {'code': payload.code});
      } else if (context.mounted) {
        context.pop();
      }
      return;
    }

    // Build actions based on status
    final actions = <ScanAction>[];
    switch (item.status) {
      case 'standby':
        actions.addAll([
          ScanAction(
            label: '装机',
            icon: Icons.play_arrow,
            isPrimary: true,
            onTap: () => context.push('/inventory/${item.id}/load', extra: item),
          ),
          ScanAction(
            label: '开始烘干',
            icon: Icons.local_fire_department,
            onTap: () {
              // Quick action — handled in action sheet
            },
          ),
          ScanAction(
            label: '标记用完',
            icon: Icons.block,
            isDestructive: true,
            onTap: () {
              // Quick action — handled in action sheet
            },
          ),
        ]);
      case 'loaded':
        actions.addAll([
          ScanAction(
            label: '下机',
            icon: Icons.eject,
            isPrimary: true,
            onTap: () => context.push('/inventory/${item.id}/unload', extra: item),
          ),
          ScanAction(
            label: '标记用完',
            icon: Icons.block,
            isDestructive: true,
            onTap: () {},
          ),
        ]);
      case 'drying':
        actions.add(ScanAction(
          label: '结束烘干',
          icon: Icons.check,
          isPrimary: true,
          onTap: () {},
        ));
      case 'used_up':
        break;
    }
    actions.add(ScanAction(
      label: '查看详情',
      icon: Icons.info_outline,
      onTap: () => context.push('/inventory/${item.id}', extra: item),
    ));

    context.pop(); // Close scanner
    showScanActionSheet(
      context,
      inventoryItem: item,
      actions: actions,
    );
  }
}
