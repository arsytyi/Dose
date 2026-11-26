import 'package:bady/app.dart';
import 'package:bady/data/database.dart';
import 'package:bady/domain/enums.dart';
import 'package:bady/domain/schedule_rule.dart';
import 'package:bady/providers.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  /// Unmounts the app so drift stream-close timers fire inside the test.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  /// Lets real-async database queries finish, then settles the UI.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester, {String locale = 'uk'}) async {
    SharedPreferences.setMockInitialValues({'locale': locale});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const DoseApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty today screen in Ukrainian', (tester) async {
    await pumpApp(tester);
    expect(find.text('На сьогодні прийомів немає'), findsOneWidget);
    expect(find.text('Препарати'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('Russian and Spanish UI when chosen', (tester) async {
    await pumpApp(tester, locale: 'ru');
    expect(find.text('На сегодня приёмов нет'), findsOneWidget);
    await unmount(tester);
    await pumpApp(tester, locale: 'es');
    expect(find.text('No hay tomas para hoy'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('English UI when chosen', (tester) async {
    await pumpApp(tester, locale: 'en');
    expect(find.text('No doses planned for today'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('statistics tab with no data', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Статистика'));
    await settle(tester);
    expect(find.textContaining('Ще немає даних'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('theme and sound are chosen in settings', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Налаштування'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Темна'));
    await tester.pumpAndSettle();
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.themeMode, ThemeMode.dark);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'dark');

    // Two more languages push the sound setting further down.
    await tester.scrollUntilVisible(
      find.text('Звук сповіщення'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Звук сповіщення'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Дзвіночок'));
    // The new sound reschedules reminders; let that database read finish.
    await settle(tester);
    expect(prefs.getString('sound'), 'raw:bady_chime');
    await unmount(tester);
  });

  testWidgets('add a medication through the form', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Препарати'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Додати препарат'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Магній B6');
    await tester.tap(find.text('Зберегти'));
    await tester.pumpAndSettle();

    final meds = (await tester.runAsync(() => db.watchMedications().first))!;
    expect(meds.single.name, 'Магній B6');
    expect(meds.single.kind, MedKind.supplement);
    // Lands on the detail screen with an add-schedule button.
    expect(find.text('Додати розклад'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('pick a ready-made product and read its notes', (tester) async {
    await pumpApp(tester);
    await settle(tester);
    await tester.tap(find.text('Препарати'));
    await settle(tester);
    await tester.tap(find.text('Додати препарат'));
    await settle(tester);
    await tester.enterText(find.byType(TextFormField).first, 'кверц');
    await settle(tester);
    await tester.tap(find.text('Quercetin 500 mg'));
    await settle(tester);
    await tester.tap(find.text('Зберегти'));
    await settle(tester);

    final m = (await tester.runAsync(() => db.watchMedications().first))!
        .single;
    expect(m.name, 'Quercetin 500 mg (Best Naturals)');
    expect(m.form, MedForm.capsule);
    expect(m.ingredientKeys, {'quercetin'});
    expect(m.notes, '500 мг кверцетину в капсулі');

    // The detail screen offers the notes for quercetin.
    expect(find.text('Довідка'), findsOneWidget);
    await tester.ensureVisible(find.text('Кверцетин'));
    await tester.tap(find.text('Кверцетин'));
    await settle(tester);
    expect(find.text('Як приймати'), findsOneWidget);
    expect(find.text('Обережно'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('scheduled dose shows on the today screen', (tester) async {
    await tester.runAsync(() async {
      final id = await db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Вітамін D',
          kind: MedKind.supplement,
          form: MedForm.capsule,
          unit: const Value('капс.'),
        ),
      );
      await db.insertSchedule(
        id,
        ScheduleRule(
          startDate: DateTime.now(),
          times: const [DoseTime(hour: 23, minute: 59)],
        ),
      );
    });
    await pumpApp(tester);
    expect(find.text('Вітамін D'), findsOneWidget);
    expect(find.text('23:59'), findsOneWidget);
    expect(find.text('1 капс.'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('low stock shows on Today and "Bought more" adds a pack', (
    tester,
  ) async {
    final id = (await tester.runAsync(() async {
      final id = await db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Магній',
          kind: MedKind.supplement,
          form: MedForm.tablet,
          stock: const Value(2),
          packSize: const Value(30),
        ),
      );
      await db.insertSchedule(
        id,
        ScheduleRule(
          startDate: DateTime.now(),
          times: const [DoseTime(hour: 23, minute: 59)],
        ),
      );
      return id;
    }))!;
    await pumpApp(tester);
    await settle(tester);
    expect(find.text('Час докупити'), findsOneWidget);

    await tester.tap(find.text('Магній').first);
    await settle(tester);
    expect(find.text('Мало запасу'), findsOneWidget);
    await tester.tap(find.text('Докупив'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Упаковка: +30'));
    await settle(tester);

    final m = (await tester.runAsync(() => db.watchMedication(id).first))!;
    expect(m.stock, 32);
    expect(find.text('Мало запасу'), findsNothing);
    await unmount(tester);
  });

  testWidgets('compatibility warnings on the medication and on save', (
    tester,
  ) async {
    final calcium = (await tester.runAsync(() async {
      final iron = await db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Залізо',
          kind: MedKind.supplement,
          form: MedForm.tablet,
        ),
      );
      await db.insertSchedule(
        iron,
        ScheduleRule(
          startDate: DateTime.now(),
          times: const [DoseTime(hour: 9, minute: 0)],
        ),
      );
      return db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Кальцій',
          kind: MedKind.supplement,
          form: MedForm.tablet,
        ),
      );
    }))!;
    await pumpApp(tester);
    await settle(tester);
    await tester.tap(find.text('Препарати'));
    await settle(tester);
    await tester.tap(find.text('Кальцій'));
    await settle(tester);
    // No schedule yet, so nothing to warn about.
    expect(find.textContaining('розділяйте'), findsNothing);

    // A new schedule defaults to 9:00, the same time as iron.
    await tester.tap(find.text('Додати розклад'));
    await settle(tester);
    await tester.tap(find.text('Зберегти'));
    await settle(tester);
    expect(find.text('Можлива несумісність'), findsOneWidget);
    expect(
      find.textContaining('перенесіть цей прийом на 11:00'),
      findsOneWidget,
    );
    await tester.tap(find.text('Зберегти все одно'));
    await settle(tester);

    final schedules = (await tester.runAsync(
      () => db.watchSchedulesFor(calcium).first,
    ))!;
    expect(schedules, hasLength(1));
    expect(find.text('Сумісність'), findsOneWidget);
    expect(
      find.textContaining('розділяйте щонайменше на 2 год'),
      findsOneWidget,
    );
    await unmount(tester);
  });

  testWidgets('history calendar opens a day on Today', (tester) async {
    await tester.runAsync(() async {
      final id = await db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Вітамін D',
          kind: MedKind.supplement,
          form: MedForm.capsule,
        ),
      );
      await db.insertSchedule(
        id,
        ScheduleRule(
          startDate: DateTime.now().subtract(const Duration(days: 3)),
          times: const [DoseTime(hour: 0, minute: 1)],
        ),
      );
    });
    await pumpApp(tester);
    await tester.tap(find.text('Статистика'));
    await settle(tester);
    await tester.tap(find.byTooltip('Історія'));
    await settle(tester);
    expect(find.text('Історія'), findsOneWidget);
    // Today's 00:01 dose is overdue: 0% taken.
    expect(find.text('0%'), findsWidgets);

    final today = find.text('${DateTime.now().day}').last;
    await tester.ensureVisible(today);
    await tester.pumpAndSettle();
    await tester.tap(today);
    await settle(tester);
    // Back on the Today tab.
    expect(find.text('Вітамін D'), findsWidgets);
    expect(find.text('Історія'), findsNothing);
    await unmount(tester);
  });

  testWidgets('schedule editor validates and saves', (tester) async {
    final id = (await tester.runAsync(
      () => db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Залізо',
          kind: MedKind.supplement,
          form: MedForm.tablet,
        ),
      ),
    ))!;
    await pumpApp(tester);
    await tester.tap(find.text('Препарати'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Залізо'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Додати розклад'));
    await tester.pumpAndSettle();

    // Switch to "every N days" and save with the default interval of 2.
    await tester.tap(find.text('Кожні N днів'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Зберегти'));
    await tester.pumpAndSettle();

    final schedules = (await tester.runAsync(
      () => db.watchSchedulesFor(id).first,
    ))!;
    expect(schedules.single.rule.dayPattern, DayPattern.everyNDays);
    expect(schedules.single.rule.everyNDays, 2);
    expect(find.textContaining('кожні 2 дні'), findsOneWidget);
    await unmount(tester);
  });

  Future<int> seedVitaminD(
    WidgetTester tester, {
    int hour = 0,
    int minute = 1,
  }) async {
    return (await tester.runAsync(() async {
      final id = await db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Вітамін D',
          kind: MedKind.supplement,
          form: MedForm.capsule,
          unit: const Value('капс.'),
          stock: const Value(30),
        ),
      );
      await db.insertSchedule(
        id,
        ScheduleRule(
          startDate: DateTime.now().subtract(const Duration(days: 3)),
          times: [DoseTime(hour: hour, minute: minute)],
        ),
      );
      return id;
    }))!;
  }

  testWidgets('mark a dose taken from the pillbox', (tester) async {
    final id = await seedVitaminD(tester);
    await pumpApp(tester);
    expect(find.text('Прострочено'), findsOneWidget);
    expect(find.text('0 з 1 прийнято'), findsOneWidget);

    await tester.tap(find.text('Вітамін D'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Прийняв'));
    await tester.pumpAndSettle();

    final events = (await tester.runAsync(
      () => db.eventsBetween(
        DateTime.now().subtract(const Duration(days: 1)),
        DateTime.now().add(const Duration(days: 1)),
      ),
    ))!;
    expect(events.single.status, DoseStatus.taken);
    final med = (await tester.runAsync(() => db.watchMedication(id).first))!;
    expect(med.stock, 29);
    expect(find.text('Усе прийнято'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('previous day button shows yesterday', (tester) async {
    await seedVitaminD(tester);
    await pumpApp(tester);
    expect(find.text('Сьогодні'), findsWidgets);
    await tester.tap(find.byTooltip('Попередній день'));
    await settle(tester);
    // Not on today any more: the title shows the date.
    expect(find.widgetWithText(AppBar, 'Сьогодні'), findsNothing);
    expect(find.text('Вітамін D'), findsOneWidget);
    // Tapping the Today tab again comes back to today.
    await tester.tap(find.widgetWithText(NavigationDestination, 'Сьогодні'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Сьогодні'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('swiping changes the day', (tester) async {
    await seedVitaminD(tester);
    await pumpApp(tester);
    await tester.fling(find.byType(PageView), const Offset(400, 0), 1000);
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Сьогодні'), findsNothing);
    await unmount(tester);
  });

  testWidgets('opening a reminder shows that dose with actions', (
    tester,
  ) async {
    await seedVitaminD(tester);
    SharedPreferences.setMockInitialValues({'locale': 'uk'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        databaseProvider.overrideWithValue(db),
      ],
    );
    final now = DateTime.now();
    container
        .read(focusRequestProvider.notifier)
        .request(DateTime(now.year, now.month, now.day, 0, 1));
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const DoseApp()),
    );
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.widgetWithText(FilledButton, 'Прийняв'), findsOneWidget);
    expect(find.textContaining('Відкласти на 10 хв'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.pump(Duration.zero);
  });
}
