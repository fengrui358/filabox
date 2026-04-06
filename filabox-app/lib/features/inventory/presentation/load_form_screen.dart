import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/database/repositories/position_repository.dart';
import '../../../core/providers.dart';

class LoadFormScreen extends ConsumerStatefulWidget {
  final InventoryItem item;
  const LoadFormScreen({super.key, required this.item});

  @override
  ConsumerState<LoadFormScreen> createState() => _LoadFormScreenState();
}

class _LoadFormScreenState extends ConsumerState<LoadFormScreen> {
  String? _selectedPositionId;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final positionsAsync = ref.watch(positionsProvider);
    final theme = Theme.of(context);

    final ft = widget.item.filamentType;
    final displayColor = ft?.colorHex != null
        ? Color(int.parse('FF${ft!.colorHex!.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(title: const Text('装机')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info card
            Card(
              child: ListTile(
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: displayColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                ),
                title: Text('${ft?.brand ?? ""} ${ft?.model ?? ""}', style: theme.textTheme.titleSmall),
                subtitle: Text(ft?.colorName ?? ""),
              ),
            ),
            const SizedBox(height: 24),

            // Position selector
            Text('选择装机位置', style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 8),
            positionsAsync.when(
              data: (positions) {
                final printerPositions = positions.where((p) => p.type == 'printer').toList();
                if (printerPositions.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('暂无打印机位，请先在设置中添加位置'),
                    ),
                  );
                }
                return Card(
                  child: Column(
                    children: printerPositions.map((p) => RadioListTile<String>(
                      title: Text(p.name),
                      subtitle: Text(_typeLabel(p.type)),
                      value: p.id,
                      groupValue: _selectedPositionId,
                      onChanged: (v) => setState(() => _selectedPositionId = v),
                    )).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('加载位置失败'),
            ),
            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('确认装机'),
                onPressed: _loading || _selectedPositionId == null ? null : _load,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) => switch (type) {
    'printer' => '打印机位',
    'dry_box' => '烘干箱',
    'storage' => '存储位',
    _ => type,
  };

  Future<void> _load() async {
    if (_selectedPositionId == null) return;
    setState(() => _loading = true);

    await ref.read(repositoryServiceProvider).loadToPosition(
      widget.item.id,
      _selectedPositionId!,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('装机成功')));
      context.go('/');
    }
  }
}
