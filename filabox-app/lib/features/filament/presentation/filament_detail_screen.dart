import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/database/repositories/filament_repository.dart';

class FilamentDetailScreen extends StatelessWidget {
  final FilamentType filament;

  const FilamentDetailScreen({super.key, required this.filament});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorHex = filament.colorHex;
    final displayColor = colorHex != null
        ? Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return Scaffold(
      appBar: AppBar(
        title: Text('${filament.brand} ${filament.model}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push('/filaments/${filament.id}/edit', extra: filament),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with color
            Row(
              children: [
                Container(
                  width: 64, height: 64,
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
                      Text(filament.colorName, style: theme.textTheme.headlineSmall),
                      Text(filament.code, style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        color: theme.colorScheme.onSurfaceVariant,
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // QR Code
            Center(
              child: QrImageView(
                data: filament.qrPayload,
                version: QrVersions.auto,
                size: 180,
                backgroundColor: Colors.white,
              ),
            ),
            Center(
              child: TextButton.icon(
                icon: const Icon(Icons.print),
                label: const Text('打印二维码标签'),
                onPressed: () {/* TODO: share/print QR */},
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: FilledButton.icon(
                icon: const Icon(Icons.add_box_outlined),
                label: const Text('入库新件'),
                onPressed: () => context.push('/inventory/add', extra: {'filament': filament}),
              ),
            ),
            const SizedBox(height: 24),

            // Specs
            _Section(title: '技术参数', children: [
              _InfoRow(label: '品牌', value: filament.brand),
              _InfoRow(label: '型号', value: filament.model),
              _InfoRow(label: '直径', value: '${filament.diameter} mm'),
              _InfoRow(label: '打印温度', value: filament.printTempMin != null
                  ? '${filament.printTempMin} - ${filament.printTempMax} °C' : '-'),
              _InfoRow(label: '烘烤温度', value: filament.bakeTemp != null
                  ? '${filament.bakeTemp} °C' : '-'),
              _InfoRow(label: '烘烤时间', value: filament.bakeTimeMin != null
                  ? '${filament.bakeTimeMin} 分钟' : '-'),
            ]),
            const SizedBox(height: 16),

            _Section(title: '价格信息', children: [
              _InfoRow(label: '购买价', value: filament.purchasePrice != null
                  ? '¥${filament.purchasePrice!.toStringAsFixed(2)}' : '-'),
              _InfoRow(label: '最低价', value: filament.minPrice != null
                  ? '¥${filament.minPrice!.toStringAsFixed(2)}' : '-'),
            ]),
            if (filament.sku != null) ...[
              const SizedBox(height: 16),
              _Section(title: '其他', children: [
                _InfoRow(label: 'SKU', value: filament.sku!),
                if (filament.notes != null) _InfoRow(label: '备注', value: filament.notes!),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
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
          Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}
