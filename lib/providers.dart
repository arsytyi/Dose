import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:material_ui/material_ui.dart' show ThemeMode;

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/database.dart';
import 'domain/dose_plan.dart';
import 'domain/schedule_rule.dart';
import 'domain/interactions.dart';
import 'domain/stock.dart';
import 'services/dose_actions.dart';
import 'services/notification_service.dart';
import 'services/settings.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final notificationServiceProvider = Provider<NotificationService>(
  (ref) => NotificationService(),
);

/// Overridden in main() with the loaded instance.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider not overridden'),
);

/// The language picked in settings; null follows the system.
class LocaleNotifier extends Notifier<Locale?> {
  @override
  Locale? build() => Prefs.chosenLocale(ref.read(sharedPreferencesProvider));

  Future<void> set(Locale? locale) async {
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(Prefs.locale);
    } else {
      await prefs.setString(Prefs.locale, locale.languageCode);
    }
    state = locale;
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale?>(
  LocaleNotifier.new,
);

/// Light, dark, or following the system.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final name = ref.read(sharedPreferencesProvider).getString(Prefs.themeMode);
    return ThemeMode.values.asNameMap()[name] ?? ThemeMode.system;
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(Prefs.themeMode, mode.name);
  }
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Reminder behaviour from settings.
class ReminderSettings {
  const ReminderSettings({
    required this.snoozeMinutes,
    required this.repeat,
    this.sound,
    this.soundTitle,
  });

  final int snoozeMinutes;
  final bool repeat;

  /// See `Prefs.sound`.
  final String? sound;

  /// Name of a sound picked on the phone.
  final String? soundTitle;

  ReminderSettings copyWith({
    int? snoozeMinutes,
    bool? repeat,
    (String?, String?)? sound,
  }) => ReminderSettings(
    snoozeMinutes: snoozeMinutes ?? this.snoozeMinutes,
    repeat: repeat ?? this.repeat,
    sound: sound == null ? this.sound : sound.$1,
    soundTitle: sound == null ? soundTitle : sound.$2,
  );
}

class ReminderSettingsNotifier extends Notifier<ReminderSettings> {
  @override
  ReminderSettings build() {
    final p = ref.read(sharedPreferencesProvider);
    return ReminderSettings(
      snoozeMinutes: Prefs.snooze(p),
      repeat: Prefs.repeat(p),
      sound: Prefs.soundKey(p),
      soundTitle: p.getString(Prefs.soundTitle),
    );
  }

  Future<void> setSnooze(int minutes) async {
    await ref
        .read(sharedPreferencesProvider)
        .setInt(Prefs.snoozeMinutes, minutes);
    state = state.copyWith(snoozeMinutes: minutes);
  }

  Future<void> setRepeat(bool repeat) async {
    await ref
        .read(sharedPreferencesProvider)
        .setBool(Prefs.repeatReminders, repeat);
    state = state.copyWith(repeat: repeat);
  }

  /// [sound] null means the phone default; [title] names a phone sound.
  Future<void> setSound(String? sound, {String? title}) async {
    final p = ref.read(sharedPreferencesProvider);
    if (sound == null) {
      await p.remove(Prefs.sound);
    } else {
      await p.setString(Prefs.sound, sound);
    }
    if (title == null) {
      await p.remove(Prefs.soundTitle);
    } else {
      await p.setString(Prefs.soundTitle, title);
    }
    state = state.copyWith(sound: (sound, title));
  }
}

final reminderSettingsProvider =
    NotifierProvider<ReminderSettingsNotifier, ReminderSettings>(
      ReminderSettingsNotifier.new,
    );

final medicationsProvider = StreamProvider<List<Medication>>(
  (ref) => ref.watch(databaseProvider).watchMedications(),
);

final archivedMedicationsProvider = StreamProvider<List<Medication>>(
  (ref) => ref.watch(databaseProvider).watchMedications(archived: true),
);

final medicationProvider = StreamProvider.family<Medication?, int>(
  (ref, id) => ref.watch(databaseProvider).watchMedication(id),
);

final schedulesProvider = StreamProvider.family<List<Schedule>, int>(
  (ref, id) => ref.watch(databaseProvider).watchSchedulesFor(id),
);

final activePlanProvider = StreamProvider<List<PlannedSchedule>>(
  (ref) => ref.watch(databaseProvider).watchActivePlan(),
);

/// Logged doses for one calendar day.
final dayEventsProvider = StreamProvider.family<List<DoseEvent>, DateTime>((
  ref,
  day,
) {
  final start = dateOnly(day);
  final end = addDays(start, 1).subtract(const Duration(microseconds: 1));
  return ref.watch(databaseProvider).watchEventsBetween(start, end);
});

/// Every medication, including archived ones, by id (for showing history).
final allMedicationsProvider = StreamProvider<Map<int, Medication>>((ref) {
  final db = ref.watch(databaseProvider);
  return db
      .select(db.medications)
      .watch()
      .map((list) => {for (final m in list) m.id: m});
});

/// Stock forecast for each medication that tracks stock.
final stockForecastsProvider = Provider<Map<int, StockForecast>>((ref) {
  final meds = ref.watch(medicationsProvider).value ?? const [];
  final plan = ref.watch(activePlanProvider).value ?? const [];
  final now = DateTime.now();
  return {
    for (final m in meds)
      if (m.stock case final stock?)
        m.id: forecastStock(
          stock: stock,
          rules: [
            for (final p in plan)
              if (p.medication.id == m.id) p.schedule.rule,
          ],
          now: now,
          lowStockDays: m.lowStockDays,
        ),
  };
});

final interactionCatalogProvider = FutureProvider<InteractionCatalog>((
  ref,
) async {
  final text = await rootBundle.loadString(
    'assets/interactions.json',
    // A cached future can belong to a finished test zone in widget tests.
    cache: false,
  );
  return InteractionCatalog.fromJson(jsonDecode(text) as Map<String, dynamic>);
});

/// Medications for the compatibility check. [edited] replaces (or adds) one
/// schedule of [editedMedicationId], to check a schedule before saving it.
/// Medications saved before substances existed use what their name says.
List<InteractionMed> interactionMeds(
  InteractionCatalog catalog,
  List<Medication> meds,
  List<PlannedSchedule> plan, {
  int? editedMedicationId,
  int? editedScheduleId,
  ScheduleRule? edited,
}) => [
  for (final m in meds)
    if (!m.archived)
      if (m.ingredients == null ? catalog.detect(m.name) : m.ingredientKeys
          case final substances when substances.isNotEmpty)
        InteractionMed(
          id: m.id,
          name: m.name,
          substances: substances,
          rules: [
            for (final p in plan)
              if (p.medication.id == m.id &&
                  !(m.id == editedMedicationId &&
                      p.schedule.id == editedScheduleId))
                p.schedule.rule,
            if (m.id == editedMedicationId && edited != null) edited,
          ],
        ),
];

/// Compatibility issues among current medications and schedules.
final interactionIssuesProvider = Provider<List<InteractionIssue>>((ref) {
  final catalog = ref.watch(interactionCatalogProvider).value;
  if (catalog == null) return const [];
  return findInteractions(
    catalog,
    interactionMeds(
      catalog,
      ref.watch(medicationsProvider).value ?? const [],
      ref.watch(activePlanProvider).value ?? const [],
    ),
  );
});

List<PlanEntry> toPlanEntries(List<PlannedSchedule> plan) => [
  for (final p in plan)
    PlanEntry(
      medicationId: p.medication.id,
      name: p.medication.name,
      unit: p.medication.unit,
      rule: p.schedule.rule,
      look: p.medication.look,
      meal: p.medication.meal,
    ),
];

final doseActionsProvider = Provider<DoseActions>(
  (ref) => DoseActions(
    db: ref.watch(databaseProvider),
    notifications: ref.watch(notificationServiceProvider),
    prefs: ref.watch(sharedPreferencesProvider),
  ),
);

/// A request to show a dose, e.g. after tapping its notification.
class FocusRequest {
  FocusRequest(this.doseTime);

  final DateTime doseTime;
}

class FocusNotifier extends Notifier<FocusRequest?> {
  @override
  FocusRequest? build() => null;

  void request(DateTime doseTime) => state = FocusRequest(doseTime);

  void clear() => state = null;
}

final focusRequestProvider = NotifierProvider<FocusNotifier, FocusRequest?>(
  FocusNotifier.new,
);

/// Counts taps on the already selected Today tab; the Today screen jumps
/// back to today on each one.
class TodayTabTaps extends Notifier<int> {
  @override
  int build() => 0;

  void tap() => state++;
}

final todayTabTapsProvider = NotifierProvider<TodayTabTaps, int>(
  TodayTabTaps.new,
);

/// Keeps scheduled notifications in sync with the database and settings.
/// Call [resync] after logging doses and when the app returns to the
/// foreground to roll the window forward.
class ReminderSync {
  ReminderSync(this.ref) {
    ref.listen(activePlanProvider, (_, next) {
      if (next.hasValue) schedule();
    }, fireImmediately: true);
    ref.listen(localeProvider, (_, _) => schedule());
    ref.listen(reminderSettingsProvider, (_, _) => schedule());
  }

  final Ref ref;
  Timer? _debounce;

  /// How many reminders the last sync left scheduled.
  int lastScheduled = 0;

  void schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), resync);
  }

  Future<void> resync() async {
    final db = ref.read(databaseProvider);
    final now = DateTime.now();
    final plan = await db.activePlan();
    final events = await db.eventsBetween(
      now.subtract(const Duration(days: 1)),
      now.add(NotificationService.horizon),
    );
    final settings = ref.read(reminderSettingsProvider);
    ref.read(notificationServiceProvider).sound = settings.sound;
    final notifications = buildNotificationPlan(
      entries: toPlanEntries(plan),
      logged: events.map((e) => e.toLogged()),
      now: now,
      horizon: NotificationService.horizon,
      followUpMinutes: settings.repeat ? Prefs.followUpMinutes : const [],
    );
    final prefs = ref.read(sharedPreferencesProvider);
    final scheduled = await ref
        .read(notificationServiceProvider)
        .replaceAll(
          notifications,
          localizationsFor(prefs),
          stock: _stockReminders(plan, now),
          previous: _decode(prefs.getString(Prefs.scheduledReminders)),
        );
    await prefs.setString(
      Prefs.scheduledReminders,
      jsonEncode({for (final e in scheduled.entries) '${e.key}': e.value}),
    );
    lastScheduled = scheduled.length;
  }

  static Map<int, String> _decode(String? json) {
    if (json == null) return const {};
    try {
      return {
        for (final e in (jsonDecode(json) as Map<String, dynamic>).entries)
          int.parse(e.key): e.value as String,
      };
    } catch (_) {
      return const {};
    }
  }

  void dispose() => _debounce?.cancel();

  /// Daily restock reminders: time -> (name, days left) for low medications.
  static Map<DateTime, List<String>> _stockReminders(
    List<PlannedSchedule> plan,
    DateTime now,
  ) {
    final meds = {
      for (final p in plan)
        if (p.medication.stock != null) p.medication.id: p.medication,
    };
    final items = [
      for (final m in meds.values)
        StockItem(
          medicationId: m.id,
          stock: m.stock!,
          lowStockDays: m.lowStockDays,
          rules: [
            for (final p in plan)
              if (p.medication.id == m.id) p.schedule.rule,
          ],
        ),
    ];
    return {
      for (final e in planLowStockReminders(items: items, now: now).entries)
        e.key: [for (final id in e.value) meds[id]!.name],
    };
  }
}

final reminderSyncProvider = Provider<ReminderSync>((ref) {
  final sync = ReminderSync(ref);
  ref.onDispose(sync.dispose);
  return sync;
});
