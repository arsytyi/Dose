import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'l10n/app_localizations.dart';
import 'providers.dart';
import 'services/notification_service.dart';
import 'services/settings.dart';
import 'services/store.dart';
import 'ui/medications_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/stats_screen.dart';
import 'ui/theme.dart';
import 'ui/today_screen.dart';
import 'ui/update_ui.dart';

class DoseApp extends ConsumerWidget {
  const DoseApp({super.key, this.home});

  /// Replaces the home shell in tests.
  final Widget? home;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
      ],
      localeResolutionCallback: (device, supported) {
        for (final s in supported) {
          if (s.languageCode == device?.languageCode) return s;
        }
        return const Locale('en');
      },
      themeMode: themeMode,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: home ?? const HomeShell(),
    );
  }
}

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell>
    with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final service = ref.read(notificationServiceProvider);
      await service.requestPermissions();
      ref.read(reminderSyncProvider);
      if (mounted) await _askForExactAlarmsOnce();
      if (mounted && Store.selfUpdates) {
        await autoCheckForUpdate(context, ref.read(sharedPreferencesProvider));
      }
    });
  }

  /// Explains once why exact reminders matter before Android's settings
  /// page opens. Since Android 14 new installs don't get this by default.
  Future<void> _askForExactAlarmsOnce() async {
    final prefs = ref.read(sharedPreferencesProvider);
    final service = ref.read(notificationServiceProvider);
    if (prefs.getBool(Prefs.exactAlarmAsked) ?? false) return;
    if (!NotificationService.supported) return;
    if (await service.canScheduleExact()) return;
    await prefs.setBool(Prefs.exactAlarmAsked, true);
    if (!mounted) return;
    final l = AppLocalizations.of(context);
    final allow = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        icon: const Icon(Icons.alarm_on_outlined),
        title: Text(l.exactAlarmPromptTitle),
        content: Text(l.exactAlarmPromptBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialog).pop(false),
            child: Text(l.later),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialog).pop(true),
            child: Text(l.exactAlarmPromptAllow),
          ),
        ],
      ),
    );
    if (allow ?? false) {
      await service.requestExactAlarms();
      await ref.read(reminderSyncProvider).resync();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(reminderSyncProvider).resync();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Opening a reminder shows the Today tab with that dose.
    ref.listen(focusRequestProvider, (_, next) {
      if (next != null && _index != 0) {
        Navigator.of(context).popUntil((r) => r.isFirst);
        setState(() => _index = 0);
      }
    });
    const pages = [
      TodayScreen(),
      MedicationsScreen(),
      StatsScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) {
          if (i == _index && i == 0) {
            ref.read(todayTabTapsProvider.notifier).tap();
          }
          setState(() => _index = i);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.today_outlined),
            selectedIcon: const Icon(Icons.today),
            label: l.navToday,
          ),
          NavigationDestination(
            icon: const Icon(Icons.medication_outlined),
            selectedIcon: const Icon(Icons.medication),
            label: l.navMedications,
          ),
          NavigationDestination(
            icon: const Icon(Icons.insights_outlined),
            selectedIcon: const Icon(Icons.insights),
            label: l.navStats,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l.navSettings,
          ),
        ],
      ),
    );
  }
}
