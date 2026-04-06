import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_theme.dart';
import 'features/filament/presentation/filament_list_screen.dart';
import 'features/inventory/presentation/inventory_overview_screen.dart';
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
      GoRoute(
        path: '/scan',
        name: 'scan',
        builder: (context, state) => const ScannerScreen(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/scan'),
        child: const Icon(Icons.qr_code_scanner),
      ),
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
