import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/localization/app_localizations.dart';
import 'theme/colors.dart';
import 'features/sedentary/sedentary_screen.dart';
import 'features/sedentary/sedentary_provider.dart';
import 'features/stretch/stretch_screen.dart';
import 'features/breathing/breathing_screen.dart';
import 'features/hydration/hydration_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/settings/settings_screen.dart';
import 'theme/theme.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, __, child) =>
          _LifecycleObserver(child: _AppShell(child: child)),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(path: '/', builder: (_, __) => const SedentaryScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/stretch', builder: (_, __) => const StretchScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/breathing',
              builder: (_, __) => const BreathingScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/hydration',
              builder: (_, __) => const HydrationScreen()),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/stats', builder: (_, __) => const StatsScreen()),
        ]),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (_, __) => const SettingsScreen(),
    ),
  ],
);

class WellnessApp extends StatelessWidget {
  const WellnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
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
  ConsumerState<_LifecycleObserver> createState() =>
      _LifecycleObserverState();
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
    final brightness = Theme.of(context).brightness;
    final accent = AppColors.accent(brightness);

    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        onTap: (i) => _onTap(context, i),
        selectedItemColor: accent,
        unselectedItemColor:
            AppColors.textSecondary(brightness).withValues(alpha: 0.55),
        backgroundColor: AppColors.surface2(brightness),
        elevation: 0,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.self_improvement_outlined),
            activeIcon: const Icon(Icons.self_improvement),
            label: l10n.homeTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.fitness_center_outlined),
            activeIcon: const Icon(Icons.fitness_center),
            label: l10n.moveTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.air_outlined),
            activeIcon: const Icon(Icons.air),
            label: l10n.breatheTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.water_drop_outlined),
            activeIcon: const Icon(Icons.water_drop),
            label: l10n.waterTab,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.show_chart_outlined),
            activeIcon: const Icon(Icons.show_chart),
            label: l10n.statsTab,
          ),
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
