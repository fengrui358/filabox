import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/providers.dart';

class UnloadFormScreen extends ConsumerStatefulWidget {
  final InventoryItem item;
  const UnloadFormScreen({super.key, required this.item});

  @override
  ConsumerState<UnloadFormScreen> createState() => _UnloadFormScreenState();
}

class _UnloadFormScreenState extends ConsumerState<UnloadFormScreen> {
  late double _remainingPercent;
  final _remainingCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _remainingPercent = widget.item.remainingPercent;
    _remainingCtrl.text = _remainingPercent.round().toString();
  }

  @override
  void dispose() {
    _remainingCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ft = widget.item.filamentType;
    final pos = widget.item.position;
    final displayColor = ft?.colorHex != null
        ? Color(int.parse('FF${ft!.colorHex!.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(title: const Text('下机')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item info
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
                subtitle: Text('${ft?.colorName ?? ""}${pos != null ? " · ${pos.name}" : ""}'),
              ),
            ),
            const SizedBox(height: 24),

            // Remaining slider
            Text('剩余量', style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            )),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _remainingPercent,
                            min: 0,
                            max: 100,
                            divisions: 20,
                            label: '${_remainingPercent.round()}%',
                            onChanged: (v) {
                              setState(() => _remainingPercent = v);
                              _remainingCtrl.text = v.round().toString();
                            },
                          ),
                        ),
                        SizedBox(
                          width: 72,
                          child: TextField(
                            controller: _remainingCtrl,
                            decoration: const InputDecoration(
                              suffixText: '%',
                              border: OutlineInputBorder(),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (v) {
                              final val = double.tryParse(v);
                              if (val != null && val >= 0 && val <= 100) {
                                setState(() => _remainingPercent = val);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _remainingPercent / 100,
                      backgroundColor: theme.colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _remainingPercent > 50
                            ? Colors.green
                            : _remainingPercent > 20
                                ? Colors.orange
                                : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Confirm button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: const Icon(Icons.eject),
                label: Text(_remainingPercent <= 0 ? '标记用完' : '确认下机'),
                onPressed: _loading ? null : _unload,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _unload() async {
    setState(() => _loading = true);
    await ref.read(repositoryServiceProvider).unloadFromPosition(
      widget.item.id,
      remaining: _remainingPercent,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_remainingPercent <= 0 ? '已标记用完' : '下机成功')),
      );
      context.go('/');
    }
  }
}
