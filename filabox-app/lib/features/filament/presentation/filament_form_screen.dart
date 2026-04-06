import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/repositories/filament_repository.dart';
import '../../../core/providers.dart';

class FilamentFormScreen extends ConsumerStatefulWidget {
  final FilamentType? filament;

  const FilamentFormScreen({super.key, this.filament});

  @override
  ConsumerState<FilamentFormScreen> createState() => _FilamentFormScreenState();
}

class _FilamentFormScreenState extends ConsumerState<FilamentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _modelCtrl;
  late final TextEditingController _colorNameCtrl;
  late final TextEditingController _colorHexCtrl;
  late final TextEditingController _printTempMinCtrl;
  late final TextEditingController _printTempMaxCtrl;
  late final TextEditingController _bakeTempCtrl;
  late final TextEditingController _bakeTimeMinCtrl;
  late final TextEditingController _purchasePriceCtrl;
  late final TextEditingController _minPriceCtrl;
  late final TextEditingController _skuCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _linkCtrl;
  late double _diameter;

  bool get _isEdit => widget.filament != null;

  @override
  void initState() {
    super.initState();
    final f = widget.filament;
    _codeCtrl = TextEditingController(text: f?.code ?? '');
    _brandCtrl = TextEditingController(text: f?.brand ?? 'Bambu Lab');
    _modelCtrl = TextEditingController(text: f?.model ?? '');
    _colorNameCtrl = TextEditingController(text: f?.colorName ?? '');
    _colorHexCtrl = TextEditingController(text: f?.colorHex ?? '');
    _printTempMinCtrl = TextEditingController(text: f?.printTempMin?.toString() ?? '');
    _printTempMaxCtrl = TextEditingController(text: f?.printTempMax?.toString() ?? '');
    _bakeTempCtrl = TextEditingController(text: f?.bakeTemp?.toString() ?? '');
    _bakeTimeMinCtrl = TextEditingController(text: f?.bakeTimeMin?.toString() ?? '');
    _purchasePriceCtrl = TextEditingController(text: f?.purchasePrice?.toString() ?? '');
    _minPriceCtrl = TextEditingController(text: f?.minPrice?.toString() ?? '');
    _skuCtrl = TextEditingController(text: f?.sku ?? '');
    _notesCtrl = TextEditingController(text: f?.notes ?? '');
    _linkCtrl = TextEditingController(text: f?.link ?? '');
    _diameter = f?.diameter ?? 1.75;
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _brandCtrl.dispose();
    _modelCtrl.dispose();
    _colorNameCtrl.dispose();
    _colorHexCtrl.dispose();
    _printTempMinCtrl.dispose();
    _printTempMaxCtrl.dispose();
    _bakeTempCtrl.dispose();
    _bakeTimeMinCtrl.dispose();
    _purchasePriceCtrl.dispose();
    _minPriceCtrl.dispose();
    _skuCtrl.dispose();
    _notesCtrl.dispose();
    _linkCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final ft = FilamentType(
      id: widget.filament?.id ?? const Uuid().v4(),
      code: _codeCtrl.text.trim(),
      brand: _brandCtrl.text.trim(),
      model: _modelCtrl.text.trim(),
      diameter: _diameter,
      colorName: _colorNameCtrl.text.trim(),
      colorHex: _colorHexCtrl.text.trim().isEmpty ? null : _colorHexCtrl.text.trim(),
      printTempMin: int.tryParse(_printTempMinCtrl.text),
      printTempMax: int.tryParse(_printTempMaxCtrl.text),
      bakeTemp: int.tryParse(_bakeTempCtrl.text),
      bakeTimeMin: int.tryParse(_bakeTimeMinCtrl.text),
      purchasePrice: double.tryParse(_purchasePriceCtrl.text),
      minPrice: double.tryParse(_minPriceCtrl.text),
      sku: _skuCtrl.text.trim().isEmpty ? null : _skuCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      link: _linkCtrl.text.trim().isEmpty ? null : _linkCtrl.text.trim(),
      createdAt: widget.filament?.createdAt ?? now,
      updatedAt: now,
    );

    final repo = ref.read(repositoryServiceProvider);
    if (_isEdit) {
      await repo.editFilamentType(ft);
    } else {
      await repo.addFilamentType(ft);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '编辑耗材' : '添加耗材'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('保存'),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicSection(),
              const SizedBox(height: 16),
              _buildTechSection(),
              const SizedBox(height: 16),
              _buildPriceSection(),
              const SizedBox(height: 16),
              _buildOtherSection(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicSection() => _FormSection(
    title: '基础信息',
    children: [
      _TextFormField(label: '编码 *', controller: _codeCtrl, required: true, mono: true),
      _TextFormField(label: '品牌 *', controller: _brandCtrl, required: true),
      _TextFormField(label: '型号 *', controller: _modelCtrl, required: true),
      _DiameterField(value: _diameter, onChanged: (v) => setState(() => _diameter = v)),
      _TextFormField(label: '颜色名称 *', controller: _colorNameCtrl, required: true),
      _ColorField(controller: _colorHexCtrl),
    ],
  );

  Widget _buildTechSection() => _FormSection(
    title: '技术参数',
    children: [
      Row(
        children: [
          Expanded(child: _TextFormField(label: '最低温度 (°C)', controller: _printTempMinCtrl, number: true)),
          const SizedBox(width: 12),
          Expanded(child: _TextFormField(label: '最高温度 (°C)', controller: _printTempMaxCtrl, number: true)),
        ],
      ),
      _TextFormField(label: '烘烤温度 (°C)', controller: _bakeTempCtrl, number: true),
      _buildBakeTimeChips(),
      _TextFormField(label: '烘烤时间 (分钟)', controller: _bakeTimeMinCtrl, number: true),
    ],
  );

  Widget _buildBakeTimeChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text('快捷选择', style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          )),
          ...[60, 120, 240].map((min) => ActionChip(
            label: Text('$min分钟'),
            onPressed: () => _bakeTimeMinCtrl.text = min.toString(),
          )),
        ],
      ),
    );
  }

  Widget _buildPriceSection() => _FormSection(
    title: '价格信息',
    children: [
      _TextFormField(label: '购买价 (¥)', controller: _purchasePriceCtrl, number: true, prefix: '¥'),
      _TextFormField(label: '最低价 (¥)', controller: _minPriceCtrl, number: true, prefix: '¥'),
    ],
  );

  Widget _buildOtherSection() => _FormSection(
    title: '其他',
    children: [
      _TextFormField(label: 'SKU', controller: _skuCtrl),
      _TextFormField(label: '备注', controller: _notesCtrl, multiline: true),
      _TextFormField(label: '链接', controller: _linkCtrl),
    ],
  );
}

class _FormSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _FormSection({required this.title, required this.children});

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

class _TextFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool required;
  final bool mono;
  final bool number;
  final bool multiline;
  final String? prefix;

  const _TextFormField({
    required this.label,
    required this.controller,
    this.required = false,
    this.mono = false,
    this.number = false,
    this.multiline = false,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: prefix,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        style: mono ? const TextStyle(fontFamily: 'monospace') : null,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : multiline
                ? TextInputType.multiline
                : null,
        maxLines: multiline ? 3 : 1,
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? '请输入$label' : null
            : null,
      ),
    );
  }
}

class _DiameterField extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const _DiameterField({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: DropdownButtonFormField<double>(
        value: value,
        decoration: const InputDecoration(
          labelText: '直径 (mm)',
          border: OutlineInputBorder(),
          isDense: true,
        ),
        items: const [
          DropdownMenuItem(value: 1.75, child: Text('1.75 mm')),
          DropdownMenuItem(value: 2.85, child: Text('2.85 mm')),
        ],
        onChanged: (v) { if (v != null) onChanged(v); },
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  final TextEditingController controller;
  const _ColorField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: '颜色代码 (如 #FF0000)',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => (context as Element).markNeedsBuild(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: _parseColor(controller.text),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
            ),
          ),
        ],
      ),
    );
  }

  Color? _parseColor(String hex) {
    if (hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '');
    if (clean.length == 6) {
      return Color(int.parse('FF$clean', radix: 16));
    }
    return null;
  }
}
