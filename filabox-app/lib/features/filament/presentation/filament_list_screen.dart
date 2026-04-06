import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/repositories/filament_repository.dart';
import '../../../core/providers.dart';
import 'filament_detail_screen.dart';

class FilamentListScreen extends ConsumerStatefulWidget {
  const FilamentListScreen({super.key});

  @override
  ConsumerState<FilamentListScreen> createState() => _FilamentListScreenState();
}

class _FilamentListScreenState extends ConsumerState<FilamentListScreen> {
  String? _selectedBrand;
  String? _selectedModel;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(filamentBrandsProvider);
    final modelsAsync = ref.watch(filamentModelsProvider);
    final filamentsAsync = ref.watch(filamentTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('耗材库'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          SizedBox(
            height: 48,
            child: brandsAsync.when(
              data: (brands) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: const Text('全部'),
                      selected: _selectedBrand == null,
                      onSelected: (_) => setState(() => _selectedBrand = null),
                    ),
                  ),
                  ...brands.map((brand) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(brand),
                      selected: _selectedBrand == brand,
                      onSelected: (_) => setState(() =>
                        _selectedBrand = _selectedBrand == brand ? null : brand),
                    ),
                  )),
                ],
              ),
              loading: () => const Center(child: SizedBox(
                height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2))),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 48,
            child: modelsAsync.when(
              data: (models) => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: const Text('全部型号'),
                      selected: _selectedModel == null,
                      onSelected: (_) => setState(() => _selectedModel = null),
                    ),
                  ),
                  ...models.map((model) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(model),
                      selected: _selectedModel == model,
                      onSelected: (_) => setState(() =>
                        _selectedModel = _selectedModel == model ? null : model),
                    ),
                  )),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),
          const Divider(height: 1),
          // List
          Expanded(
            child: filamentsAsync.when(
              data: (filaments) {
                var filtered = filaments;
                if (_selectedBrand != null) {
                  filtered = filtered.where((f) => f.brand == _selectedBrand).toList();
                }
                if (_selectedModel != null) {
                  filtered = filtered.where((f) => f.model == _selectedModel).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  final q = _searchQuery.toLowerCase();
                  filtered = filtered.where((f) =>
                    f.code.toLowerCase().contains(q) ||
                    f.brand.toLowerCase().contains(q) ||
                    f.model.toLowerCase().contains(q) ||
                    f.colorName.toLowerCase().contains(q)
                  ).toList();
                }

                if (filtered.isEmpty) {
                  return const Center(child: Text('暂无耗材数据'));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(filamentTypesProvider.future),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.85,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _FilamentCard(
                        filament: filtered[index],
                        onTap: () => _navigateToDetail(context, filtered[index]),
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('加载失败: $err')),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearch(BuildContext context) {
    showSearch(
      context: context,
      delegate: _FilamentSearchDelegate(ref),
    ).then((query) {
      if (query != null && query.isNotEmpty) {
        setState(() => _searchQuery = query);
      }
    });
  }

  void _navigateToDetail(BuildContext context, FilamentType filament) {
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => FilamentDetailScreen(filament: filament),
    ));
  }
}

class _FilamentCard extends StatelessWidget {
  final FilamentType filament;
  final VoidCallback onTap;

  const _FilamentCard({required this.filament, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorHex = filament.colorHex;
    final displayColor = colorHex != null
        ? Color(int.parse('FF${colorHex.replaceAll('#', '')}', radix: 16))
        : theme.colorScheme.surfaceContainerHighest;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Color swatch + brand badge
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: displayColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          filament.brand,
                          style: theme.textTheme.labelSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          filament.model,
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                filament.colorName,
                style: theme.textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.straighten, size: 14, color: theme.textTheme.bodySmall?.color),
                  const SizedBox(width: 4),
                  Text('${filament.diameter}mm', style: theme.textTheme.bodySmall),
                ],
              ),
              if (filament.printTempMin != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.thermostat, size: 14, color: theme.textTheme.bodySmall?.color),
                    const SizedBox(width: 4),
                    Text('${filament.printTempMin}-${filament.printTempMax}°C', style: theme.textTheme.bodySmall),
                  ],
                ),
              ],
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  filament.code,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilamentSearchDelegate extends SearchDelegate<String> {
  final WidgetRef ref;

  _FilamentSearchDelegate(this.ref);

  @override
  List<Widget> buildActions(BuildContext context) => [
    IconButton(icon: const Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
    icon: const BackButtonIcon(),
    onPressed: () => close(context, ''),
  );

  @override
  Widget buildResults(BuildContext context) => _buildResults();

  @override
  Widget buildSuggestions(BuildContext context) => _buildResults();

  Widget _buildResults() {
    if (query.isEmpty) return const Center(child: Text('输入关键词搜索耗材'));

    final asyncFilaments = ref.watch(filamentTypesProvider);
    return asyncFilaments.when(
      data: (filaments) {
        final q = query.toLowerCase();
        final filtered = filaments.where((f) =>
          f.code.toLowerCase().contains(q) ||
          f.brand.toLowerCase().contains(q) ||
          f.model.toLowerCase().contains(q) ||
          f.colorName.toLowerCase().contains(q)
        ).toList();

        return ListView.builder(
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final f = filtered[index];
            return ListTile(
              leading: _ColorDot(hex: f.colorHex),
              title: Text('${f.brand} ${f.model}'),
              subtitle: Text(f.colorName),
              trailing: Text(f.code, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
              onTap: () {
                close(context, query);
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FilamentDetailScreen(filament: f),
                ));
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('搜索失败')),
    );
  }
}

class _ColorDot extends StatelessWidget {
  final String? hex;
  const _ColorDot({this.hex});

  @override
  Widget build(BuildContext context) {
    final color = hex != null
        ? Color(int.parse('FF${hex!.replaceAll('#', '')}', radix: 16))
        : Colors.grey;
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
    );
  }
}
