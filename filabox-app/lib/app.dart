import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_theme.dart';
import 'core/database/repositories/filament_repository.dart';
import 'core/database/repositories/inventory_repository.dart';
import 'features/filament/presentation/filament_detail_screen.dart';
import 'features/filament/presentation/filament_form_screen.dart';
import 'features/filament/presentation/filament_list_screen.dart';
import 'features/inventory/presentation/inventory_detail_screen.dart';
import 'features/inventory/presentation/inventory_form_screen.dart';
import 'features/inventory/presentation/inventory_overview_screen.dart';
import 'features/inventory/presentation/load_form_screen.dart';
import 'features/inventory/presentation/unload_form_screen.dart';
import 'features/position/presentation/position_list_screen.dart';
import 'features/scanner/presentation/scanner_screen.dart';
import 'features/settings/presentation/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(child: child, location: state.matchedLocation);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'inventory',
            builder: (context, state) => const InventoryOverviewScreen(),
          ),
          GoRoute(
            path: '/filaments',
            name: 'filaments',
            builder: (context, state) => const FilamentListScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Full-screen routes
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScannerScreen(),
      ),
      GoRoute(
        path: '/filaments/add',
        name: 'filament_add',
        builder: (context, state) => const FilamentFormScreen(),
      ),
      GoRoute(
        path: '/filaments/:id',
        name: 'filament_detail',
        builder: (context, state) {
          final filament = state.extra as FilamentType;
          return FilamentDetailScreen(filament: filament);
        },
      ),
      GoRoute(
        path: '/filaments/:id/edit',
        name: 'filament_edit',
        builder: (context, state) {
          final filament = state.extra as FilamentType;
          return FilamentFormScreen(filament: filament);
        },
      ),
      GoRoute(
        path: '/inventory/add',
        name: 'inventory_add',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return InventoryFormScreen(
            preselectedFilament: extra?['filament'] as FilamentType?,
            scannedCode: extra?['code'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/inventory/:id',
        name: 'inventory_detail',
        builder: (context, state) {
          final item = state.extra as InventoryItem;
          return InventoryDetailScreen(item: item);
        },
      ),
      GoRoute(
        path: '/inventory/:id/load',
        name: 'inventory_load',
        builder: (context, state) {
          final item = state.extra as InventoryItem;
          return LoadFormScreen(item: item);
        },
      ),
      GoRoute(
        path: '/inventory/:id/unload',
        name: 'inventory_unload',
        builder: (context, state) {
          final item = state.extra as InventoryItem;
          return UnloadFormScreen(item: item);
        },
      ),
      GoRoute(
        path: '/positions',
        name: 'positions',
        builder: (context, state) => const PositionListScreen(),
      ),
    ],
  );
});

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;
  const MainScaffold({super.key, required this.child, required this.location});

  int get _currentIndex => switch (location) {
    '/' => 0,
    '/filaments' => 1,
    '/settings' => 2,
    _ => 0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.inventory_2), label: '库存'),
          NavigationDestination(icon: Icon(Icons.category), label: '耗材'),
          NavigationDestination(icon: Icon(Icons.settings), label: '设置'),
        ],
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              context.go('/');
            case 1:
              context.go('/filaments');
            case 2:
              context.go('/settings');
          }
        },
      ),
    );
  }
}

class FilaBoxApp extends ConsumerWidget {
  const FilaBoxApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'FilaBox',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
