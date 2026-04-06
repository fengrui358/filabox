import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/database/repositories/usage_record_repository.dart';
import '../../../core/providers.dart';
import 'status_actions.dart';

class InventoryDetailScreen extends ConsumerStatefulWidget {
  final InventoryItem item;

  const InventoryDetailScreen({super.key, required this.item});

  @override
  ConsumerState<InventoryDetailScreen> createState() => _InventoryDetailScreenState();
}

class _InventoryDetailScreenState extends ConsumerState<InventoryDetailScreen> {
  late InventoryItem _item;

  @override
  void initState() {
    super.initState();
    _item = widget.item;
  }

  Future<void> _refreshItem() async {
    final updated = await InventoryItem.getById(_item.id);
    if (updated != null && mounted) {
      setState(() => _item = updated);
    }
  }
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _item;
    final ft = item.filamentType;
    final pos = item.position;

    final displayColor = ft?.colorHex != null
        ? Color(int.parse('FF${ft!.colorHex!.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        title: Text(ft != null ? '${ft.brand} ${ft.model}' : '库存详情'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: displayColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: theme.colorScheme.outlineVariant),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ft?.colorName ?? '', style: theme.textTheme.headlineSmall),
                          const SizedBox(height: 4),
                          _StatusBadge(status: item.status),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Info sections
            _buildSection('基本信息', [
              _InfoRow(label: '状态', value: _statusLabel(item.status)),
              if (pos != null) _InfoRow(label: '当前位置', value: pos.name),
              _InfoRow(label: '剩余量', value: '${item.remainingPercent.round()}%'),
              if (item.actualPrice != null)
                _InfoRow(label: '入库价格', value: '¥${item.actualPrice!.toStringAsFixed(2)}'),
              if (item.loadedAt != null)
                _InfoRow(label: '装机时间', value: _formatDate(item.loadedAt!)),
              if (item.unloadedAt != null)
                _InfoRow(label: '下机时间', value: _formatDate(item.unloadedAt!)),
              if (item.notes != null) _InfoRow(label: '备注', value: item.notes!),
            ]),
            const SizedBox(height: 16),

            // Filament type info
            if (ft != null) ...[
              _buildSection('耗材参数', [
                _InfoRow(label: '品牌', value: ft.brand),
                _InfoRow(label: '型号', value: ft.model),
                _InfoRow(label: '直径', value: '${ft.diameter} mm'),
                if (ft.printTempMin != null)
                  _InfoRow(label: '打印温度', value: '${ft.printTempMin} - ${ft.printTempMax} °C'),
              ]),
              const SizedBox(height: 16),
            ],

            // Usage records
            _UsageRecordsSection(inventoryItemId: item.id),
            const SizedBox(height: 24),

            // Action buttons
            _buildActions(item),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildActions(InventoryItem item) {
    final buttons = <Widget>[];

    switch (item.status) {
      case 'standby':
        buttons.addAll([
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('装机'),
              onPressed: () => context.push('/inventory/${item.id}/load', extra: item),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.local_fire_department),
              label: const Text('开始烘干'),
              onPressed: () async {
                await startDrying(context, ref, _item.id);
                await _refreshItem();
              },
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text('标记用完'),
              onPressed: () async {
                await markUsedUp(context, ref, item.id);
                await _refreshItem();
              },
            ),
          ),
        ]);
      case 'loaded':
        buttons.addAll([
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: const Icon(Icons.eject),
              label: const Text('下机'),
              onPressed: () => context.push('/inventory/${item.id}/unload', extra: item),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.block, color: Colors.red),
              label: const Text('标记用完'),
              onPressed: () async {
                await markUsedUp(context, ref, item.id);
                await _refreshItem();
              },
            ),
          ),
        ]);
      case 'drying':
        buttons.add(SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('结束烘干'),
            onPressed: () async {
              await endDrying(context, ref, item.id);
              await _refreshItem();
            },
          ),
        ));
      case 'used_up':
        buttons.add(const Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey),
                SizedBox(width: 8),
                Text('此耗材已用完', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ));
    }

    return Column(children: buttons);
  }

  String _statusLabel(String status) => switch (status) {
    'standby' => '待用',
    'loaded' => '已装机',
    'drying' => '烘干中',
    'used_up' => '已用完',
    _ => status,
  };

  String _formatDate(DateTime dt) => '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
          Flexible(child: Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _UsageRecordsSection extends StatelessWidget {
  final String inventoryItemId;
  const _UsageRecordsSection({required this.inventoryItemId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('使用记录', style: theme.textTheme.titleSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        )),
        const SizedBox(height: 8),
        FutureBuilder<List<UsageRecord>>(
          future: UsageRecord.getByItemId(inventoryItemId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(child: Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ));
            }
            final records = snapshot.data ?? [];
            if (records.isEmpty) {
              return const Card(child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('暂无使用记录'),
              ));
            }
            return Card(
              child: Column(
                children: records.map((r) => ListTile(
                  dense: true,
                  leading: Icon(_actionIcon(r.action), size: 20, color: _actionColor(r.action)),
                  title: Text(_actionLabel(r.action)),
                  subtitle: Text(_formatDate(r.occurredAt)),
                  trailing: r.durationMinutes != null
                      ? Text('${r.durationMinutes}分钟', style: theme.textTheme.bodySmall)
                      : null,
                )).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _actionIcon(String action) => switch (action) {
    'stock_in' => Icons.add_box,
    'load' => Icons.play_arrow,
    'unload' => Icons.eject,
    'dry_start' => Icons.local_fire_department,
    'dry_end' => Icons.check,
    'use_up' => Icons.block,
    _ => Icons.history,
  };

  Color _actionColor(String action) => switch (action) {
    'stock_in' => Colors.blue,
    'load' => Colors.green,
    'unload' => Colors.orange,
    'dry_start' => Colors.deepOrange,
    'dry_end' => Colors.teal,
    'use_up' => Colors.grey,
    _ => Colors.grey,
  };

  String _actionLabel(String action) => switch (action) {
    'stock_in' => '入库',
    'load' => '装机',
    'unload' => '下机',
    'dry_start' => '开始烘干',
    'dry_end' => '结束烘干',
    'use_up' => '标记用完',
    _ => action,
  };

  String _formatDate(DateTime dt) => '${dt.month}/${dt.day} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}
