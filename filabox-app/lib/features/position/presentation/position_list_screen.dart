import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/repositories/position_repository.dart';
import '../../../core/providers.dart';

class PositionListScreen extends ConsumerStatefulWidget {
  const PositionListScreen({super.key});

  @override
  ConsumerState<PositionListScreen> createState() => _PositionListScreenState();
}

class _PositionListScreenState extends ConsumerState<PositionListScreen> {
  @override
  Widget build(BuildContext context) {
    final positionsAsync = ref.watch(positionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('位置管理')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: positionsAsync.when(
        data: (positions) {
          if (positions.isEmpty) {
            return const Center(child: Text('暂无位置，点击 + 添加'));
          }

          final printers = positions.where((p) => p.type == 'printer').toList();
          final dryBoxes = positions.where((p) => p.type == 'dry_box').toList();
          final storages = positions.where((p) => p.type == 'storage').toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (printers.isNotEmpty) ...[
                _buildSection('打印机位', printers, Icons.print),
                const SizedBox(height: 16),
              ],
              if (dryBoxes.isNotEmpty) ...[
                _buildSection('烘干箱', dryBoxes, Icons.dry_cleaning),
                const SizedBox(height: 16),
              ],
              if (storages.isNotEmpty) ...[
                _buildSection('存储位', storages, Icons.inventory_2_outlined),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('加载失败: $err')),
      ),
    );
  }

  Widget _buildSection(String title, List<Position> items, IconData icon) {
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
          child: Column(
            children: items.map((p) => ListTile(
              leading: Icon(icon),
              title: Text(p.name),
              subtitle: Text(_typeLabel(p.type)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _showFormDialog(position: p),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                    onPressed: () => _confirmDelete(p),
                  ),
                ],
              ),
            )).toList(),
          ),
        ),
      ],
    );
  }

  String _typeLabel(String type) => switch (type) {
    'printer' => '打印机位',
    'dry_box' => '烘干箱',
    'storage' => '存储位',
    _ => type,
  };

  Future<void> _showFormDialog({Position? position}) async {
    final nameCtrl = TextEditingController(text: position?.name ?? '');
    var type = position?.type ?? 'printer';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(position == null ? '添加位置' : '编辑位置'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: '名称',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'printer', label: Text('打印机'), icon: Icon(Icons.print)),
                  ButtonSegment(value: 'dry_box', label: Text('烘干箱'), icon: Icon(Icons.dry_cleaning)),
                  ButtonSegment(value: 'storage', label: Text('存储'), icon: Icon(Icons.inventory_2_outlined)),
                ],
                selected: {type},
                onSelectionChanged: (v) => setDialogState(() => type = v.first),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );

    if (result != true || !mounted) return;
    if (nameCtrl.text.trim().isEmpty) return;

    final repo = ref.read(repositoryServiceProvider);
    if (position == null) {
      await repo.addPosition(Position(
        id: const Uuid().v4(),
        name: nameCtrl.text.trim(),
        type: type,
        sortOrder: 0,
        isActive: true,
        createdAt: DateTime.now(),
      ));
    } else {
      await repo.editPosition(Position(
        id: position.id,
        name: nameCtrl.text.trim(),
        type: type,
        sortOrder: position.sortOrder,
        isActive: position.isActive,
        createdAt: position.createdAt,
      ));
    }
  }

  Future<void> _confirmDelete(Position p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除位置 "${p.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await ref.read(repositoryServiceProvider).removePosition(p.id);
    }
  }
}
