import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/sedentary/sedentary_screen.dart';
import 'features/sedentary/sedentary_provider.dart';
import 'features/stretch/stretch_screen.dart';
import 'features/breathing/breathing_screen.dart';
import 'features/hydration/hydration_screen.dart';
import 'features/stats/stats_screen.dart';
import 'theme/theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, child) => _LifecycleObserver(child: _AppShell(child: child)),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const SedentaryScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/stretch', builder: (_, __) => const StretchScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/breathing', builder: (_, __) => const BreathingScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/hydration', builder: (_, __) => const HydrationScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(path: '/stats', builder: (_, __) => const StatsScreen()),
        ]),
      ],
    ),
  ],
);

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '片刻',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
    );
  }
}

/// Watches app lifecycle and notifies the sedentary timer.
class _LifecycleObserver extends ConsumerStatefulWidget {
  final Widget child;
  const _LifecycleObserver({required this.child});

  @override
  ConsumerState<_LifecycleObserver> createState() => _LifecycleObserverState();
}

class _LifecycleObserverState extends ConsumerState<_LifecycleObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      ref.read(sedentaryProvider.notifier).onPaused();
    } else if (state == AppLifecycleState.resumed) {
      ref.read(sedentaryProvider.notifier).onResumed();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Bottom nav shell.
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(GoRouterState.of(context).uri.toString());

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.self_improvement_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.fitness_center_outlined), label: 'Move'),
          NavigationDestination(icon: Icon(Icons.air_outlined), label: 'Breathe'),
          NavigationDestination(icon: Icon(Icons.water_drop_outlined), label: 'Water'),
          NavigationDestination(icon: Icon(Icons.show_chart_outlined), label: 'Stats'),
        ],
      ),
    );
  }

  int _currentIndex(String path) {
    if (path.startsWith('/stretch')) return 1;
    if (path.startsWith('/breathing')) return 2;
    if (path.startsWith('/hydration')) return 3;
    if (path.startsWith('/stats')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    final paths = ['/', '/stretch', '/breathing', '/hydration', '/stats'];
    GoRouter.of(context).go(paths[index]);
  }
}
