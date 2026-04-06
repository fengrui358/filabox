import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/providers.dart';

class InventoryOverviewScreen extends ConsumerStatefulWidget {
  const InventoryOverviewScreen({super.key});

  @override
  ConsumerState<InventoryOverviewScreen> createState() =>
      _InventoryOverviewScreenState();
}

class _InventoryOverviewScreenState
    extends ConsumerState<InventoryOverviewScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _statusTabs = [
    ('全部', null),
    ('待用', 'standby'),
    ('已装机', 'loaded'),
    ('烘干中', 'drying'),
    ('已用完', 'used_up'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(inventoryStatsProvider);
    final inventoryAsync = ref.watch(inventoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FilaBox'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () => context.push('/inventory/add'),
            tooltip: '入库',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.center,
          tabs: _statusTabs.map((t) {
            final status = t.$2;
            return Tab(
              height: 40,
              child: statsAsync.when(
                data: (stats) {
                  if (status == null) {
                    final total = stats.values.fold(0, (a, b) => a + b);
                    return Text('${t.$1} ($total)');
                  }
                  return Text('${t.$1} (${stats[status] ?? 0})');
                },
                loading: () => Text(t.$1),
                error: (_, __) => Text(t.$1),
              ),
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          // Stats cards
          SizedBox(
            height: 80,
            child: statsAsync.when(
              data: (stats) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                children: [
                  _StatCard(
                    icon: Icons.inventory_2_outlined,
                    label: '可用',
                    value: '${(stats['standby'] ?? 0) + (stats['loaded'] ?? 0)}',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.check_circle_outline,
                    label: '已装机',
                    value: '${stats['loaded'] ?? 0}',
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.access_time,
                    label: '烘干中',
                    value: '${stats['drying'] ?? 0}',
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _StatCard(
                    icon: Icons.delete_outline,
                    label: '已用完',
                    value: '${stats['used_up'] ?? 0}',
                    color: Colors.grey,
                  ),
                ],
              ),
              loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const Divider(height: 1),
          // Inventory list with tabs
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _statusTabs.map((tab) {
                final filterStatus = tab.$2;
                return inventoryAsync.when(
                  data: (items) {
                    var filtered = items;
                    if (filterStatus != null) {
                      filtered = items
                          .where((i) => i.status == filterStatus)
                          .toList();
                    }
                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined,
                                size: 64,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.5)),
                            const SizedBox(height: 8),
                            Text('暂无${tab.$1}耗材',
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      );
                    }
                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.refresh(inventoryProvider.future),
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) =>
                            _InventoryTile(item: filtered[index], onTap: () => context.push('/inventory/${filtered[index].id}', extra: filtered[index])),
                      ),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (err, _) => Center(child: Text('加载失败: $err')),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'scan',
        onPressed: () => context.push('/scan'),
        child: const Icon(Icons.qr_code_scanner),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        )),
                Text(label, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryTile extends StatelessWidget {
  final InventoryItem item;
  final VoidCallback? onTap;

  const _InventoryTile({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ft = item.filamentType;
    final pos = item.position;

    final statusColor = switch (item.status) {
      'standby' => Colors.blue,
      'loaded' => Colors.green,
      'drying' => Colors.orange,
      'used_up' => Colors.grey,
      _ => Colors.grey,
    };

    final statusLabel = switch (item.status) {
      'standby' => '待用',
      'loaded' => '已装机',
      'drying' => '烘干中',
      'used_up' => '已用完',
      _ => item.status,
    };

    final colorHex = ft?.colorHex;
    final displayColor = colorHex != null
        ? Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        onTap: onTap,
        leading: Stack(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: displayColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.circle, size: 6, color: Colors.white),
              ),
            ),
          ],
        ),
        title: ft != null
            ? Text('${ft.brand} ${ft.model}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600))
            : const Text('未知耗材'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ft != null) Text(ft.colorName),
            if (pos != null && item.status == 'loaded')
              Text('位置: ${pos.name}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  )),
            if (item.loadedAt != null && item.status == 'loaded')
              Text(
                  '装机: ${_formatDate(item.loadedAt!)}',
                  style: theme.textTheme.bodySmall),
            if (item.remainingPercent < 100 && item.status != 'used_up')
              _RemainingBar(percent: item.remainingPercent),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }
}

class _RemainingBar extends StatelessWidget {
  final double percent;
  const _RemainingBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final color = percent > 50
        ? Colors.green
        : percent > 20
            ? Colors.orange
            : Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6,
          ),
        ),
        Text('剩余 ${percent.toStringAsFixed(0)}%',
            style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}
