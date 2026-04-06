import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/repositories/filament_repository.dart';
import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/providers.dart';
import '../../inventory/presentation/status_actions.dart';

class ScanAction {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final bool isDestructive;
  final VoidCallback onTap;

  const ScanAction({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
    this.isDestructive = false,
  });
}

void showScanActionSheet(
  BuildContext context, {
  FilamentType? filamentType,
  InventoryItem? inventoryItem,
  required List<ScanAction> actions,
}) {
  showModalBottomSheet(
    context: context,
    builder: (ctx) => _ScanActionSheetContent(
      filamentType: filamentType,
      inventoryItem: inventoryItem,
      actions: actions,
    ),
  );
}

class _ScanActionSheetContent extends ConsumerWidget {
  final FilamentType? filamentType;
  final InventoryItem? inventoryItem;
  final List<ScanAction> actions;

  const _ScanActionSheetContent({
    this.filamentType,
    this.inventoryItem,
    required this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final ft = inventoryItem?.filamentType ?? filamentType;

    final displayColor = ft?.colorHex != null
        ? Color(int.parse('FF${ft!.colorHex!.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ft != null ? '${ft.brand} ${ft.model}' : '未知耗材',
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        ft?.colorName ?? '',
                        style: theme.textTheme.bodySmall,
                      ),
                      if (inventoryItem != null) ...[
                        const SizedBox(height: 4),
                        _StatusBadge(status: inventoryItem!.status),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Action buttons
            ...actions.map((action) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: action.isPrimary
                    ? FilledButton.icon(
                        icon: Icon(action.icon),
                        label: Text(action.label),
                        onPressed: () {
                          Navigator.pop(context);
                          action.onTap();
                        },
                      )
                    : action.isDestructive
                        ? OutlinedButton.icon(
                            icon: Icon(action.icon, color: theme.colorScheme.error),
                            label: Text(action.label, style: TextStyle(color: theme.colorScheme.error)),
                            onPressed: () {
                              Navigator.pop(context);
                              if (inventoryItem != null) {
                                if (action.label == '标记用完') {
                                  markUsedUp(context, ref, inventoryItem!.id);
                                }
                              }
                            },
                          )
                        : OutlinedButton.icon(
                            icon: Icon(action.icon),
                            label: Text(action.label),
                            onPressed: () {
                              Navigator.pop(context);
                              action.onTap();
                            },
                          ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (status) {
      'standby' => (Colors.blue, '待用'),
      'loaded' => (Colors.green, '已装机'),
      'drying' => (Colors.orange, '烘干中'),
      'used_up' => (Colors.grey, '已用完'),
      _ => (Colors.grey, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
