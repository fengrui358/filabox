import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/repositories/filament_repository.dart';
import '../../../core/database/repositories/inventory_repository.dart';
import '../../../core/providers.dart';

class InventoryFormScreen extends ConsumerStatefulWidget {
  final FilamentType? preselectedFilament;
  final String? scannedCode;

  const InventoryFormScreen({super.key, this.preselectedFilament, this.scannedCode});

  @override
  ConsumerState<InventoryFormScreen> createState() => _InventoryFormScreenState();
}

class _InventoryFormScreenState extends ConsumerState<InventoryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  FilamentType? _selectedFilament;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _selectedFilament = widget.preselectedFilament;
    if (_selectedFilament?.purchasePrice != null) {
      _priceCtrl.text = _selectedFilament!.purchasePrice.toString();
    }
    // If we have a scanned code but no filament, try to look it up
    if (widget.scannedCode != null && _selectedFilament == null) {
      _lookupScannedCode();
    }
  }

  Future<void> _lookupScannedCode() async {
    final ft = await FilamentType.getByCode(widget.scannedCode!);
    if (ft != null && mounted) {
      setState(() {
        _selectedFilament = ft;
        if (ft.purchasePrice != null) _priceCtrl.text = ft.purchasePrice.toString();
      });
    }
  }

  @override
  void dispose() {
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_selectedFilament == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择耗材类型')),
      );
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final now = DateTime.now();
    final item = InventoryItem(
      id: const Uuid().v4(),
      filamentTypeId: _selectedFilament!.id,
      status: 'standby',
      actualPrice: double.tryParse(_priceCtrl.text),
      remainingPercent: 100.0,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: now,
      updatedAt: now,
    );

    await ref.read(repositoryServiceProvider).addInventoryItem(item);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('入库成功')),
      );
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filamentsAsync = ref.watch(filamentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('入库'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('确认入库'),
            onPressed: _loading ? null : _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filament selector
              Text('耗材类型', style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              )),
              const SizedBox(height: 8),
              Card(
                child: filamentsAsync.when(
                  data: (filaments) {
                    if (widget.preselectedFilament != null) {
                      return _FilamentInfoTile(filament: _selectedFilament!);
                    }
                    return _FilamentDropdown(
                      filaments: filaments,
                      selected: _selectedFilament,
                      onChanged: (ft) {
                        setState(() => _selectedFilament = ft);
                        if (ft?.purchasePrice != null) {
                          _priceCtrl.text = ft!.purchasePrice.toString();
                        }
                      },
                    );
                  },
                  loading: () => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('加载耗材列表失败'),
                  ),
                ),
              ),
              if (widget.scannedCode != null && _selectedFilament == null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: Text('未找到耗材 "${widget.scannedCode}"，点击创建'),
                  onPressed: () => context.push('/filaments/add'),
                ),
              ],
              const SizedBox(height: 24),

              // Price
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(
                  labelText: '入库价格 (¥)',
                  prefixText: '¥',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: '备注',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilamentDropdown extends StatelessWidget {
  final List<FilamentType> filaments;
  final FilamentType? selected;
  final ValueChanged<FilamentType?> onChanged;

  const _FilamentDropdown({
    required this.filaments,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: selected?.id,
      decoration: const InputDecoration(
        labelText: '选择耗材',
        border: OutlineInputBorder(),
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: filaments.map((f) => DropdownMenuItem(
        value: f.id,
        child: Row(
          children: [
            if (f.colorHex != null)
              Container(
                width: 16, height: 16,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Color(int.parse('FF${f.colorHex!.replaceAll('#', '')}', radix: 16)),
                  shape: BoxShape.circle,
                ),
              ),
            Flexible(child: Text('${f.brand} ${f.model} ${f.colorName}', overflow: TextOverflow.ellipsis)),
          ],
        ),
      )).toList(),
      onChanged: (id) {
        if (id == null) { onChanged(null); return; }
        onChanged(filaments.firstWhere((f) => f.id == id));
      },
    );
  }
}

class _FilamentInfoTile extends StatelessWidget {
  final FilamentType filament;
  const _FilamentInfoTile({required this.filament});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorHex = filament.colorHex;
    final displayColor = colorHex != null
        ? Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return ListTile(
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: displayColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
      ),
      title: Text('${filament.brand} ${filament.model}', style: theme.textTheme.titleSmall),
      subtitle: Text('${filament.colorName} · ${filament.diameter}mm'),
    );
  }
}
