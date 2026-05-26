import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/localization/app_localizations.dart';
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
    final l10n = AppLocalizations(AppLocalizations.resolvedLocale);
    return MaterialApp.router(
      title: l10n.appTitle,
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: _router,
      locale: Locale(AppLocalizations.resolvedLocale),
      supportedLocales: const [Locale('en'), Locale('zh')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
      ],
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
    final l10n = AppLocalizations.of(context);
    final index = _currentIndex(GoRouterState.of(context).uri.toString());

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) => _onTap(context, i),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.self_improvement_outlined),
            selectedIcon: const Icon(Icons.self_improvement),
            label: l10n.homeTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.fitness_center_outlined),
            selectedIcon: const Icon(Icons.fitness_center),
            label: l10n.moveTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.air_outlined),
            selectedIcon: const Icon(Icons.air),
            label: l10n.breatheTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.water_drop_outlined),
            selectedIcon: const Icon(Icons.water_drop),
            label: l10n.waterTab,
          ),
          NavigationDestination(
            icon: const Icon(Icons.show_chart_outlined),
            selectedIcon: const Icon(Icons.show_chart),
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
