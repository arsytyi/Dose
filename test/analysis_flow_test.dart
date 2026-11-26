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

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> pumpApp(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'locale': 'uk'});
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
    await settle(tester);
  }

  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  /// Vitamin D daily at 09:00 for the last three days: taken 40 minutes
  /// late two days ago, skipped yesterday.
  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final today = dateOnly(DateTime.now());
      final first = addDays(today, -2);
      final id = await db.insertMedication(
        MedicationsCompanion.insert(
          name: 'Вітамін D',
          kind: MedKind.supplement,
          form: MedForm.capsule,
          createdAt: Value(first),
        ),
      );
      await db.insertSchedule(
        id,
        ScheduleRule(
          startDate: first,
          times: const [DoseTime(hour: 9, minute: 0)],
        ),
      );
      final nine = first.add(const Duration(hours: 9));
      await db.setDoseStatus(
        medicationId: id,
        scheduledAt: nine,
        dose: 1,
        status: DoseStatus.taken,
        actualAt: nine.add(const Duration(minutes: 40)),
      );
      final yesterday = addDays(today, -1).add(const Duration(hours: 9));
      await db.setDoseStatus(
        medicationId: id,
        scheduledAt: yesterday,
        dose: 1,
        status: DoseStatus.skipped,
        actualAt: yesterday,
      );
    });
  }

  testWidgets('re-tapping Today returns to today; calendar opens a picker', (
    tester,
  ) async {
    await pumpApp(tester);
    await tester.tap(find.byTooltip('Попередній день'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Сьогодні'), findsNothing);

    await tester.tap(find.byTooltip('Вибрати дату'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);
    await tester.tap(find.text('Скасувати'));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(NavigationDestination, 'Сьогодні'));
    await settle(tester);
    expect(find.widgetWithText(AppBar, 'Сьогодні'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('statistics: counts list doses, days and medications open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 3600);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await seed(tester);
    await pumpApp(tester);
    await tester.tap(find.text('Статистика'));
    await settle(tester);

    // Taken -> list with when it was taken.
    await tester.tap(find.text('Прийнято'));
    await settle(tester);
    expect(find.text('Вітамін D'), findsWidgets);
    expect(find.text('на 40 хв пізніше'), findsOneWidget);

    // A dose in the list opens its day.
    await tester.tap(find.text('на 40 хв пізніше'));
    await settle(tester);
    expect(find.text('Прийоми'), findsOneWidget);
    expect(find.text('за планом 09:00 · 1'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await settle(tester);

    // Skipped list.
    await tester.tap(find.text('Пропущено'));
    await settle(tester);
    expect(find.textContaining('Пропущено ·'), findsOneWidget);
    Navigator.of(tester.element(find.byType(DraggableScrollableSheet))).pop();
    await settle(tester);

    // A medication opens its analysis.
    await tester.scrollUntilVisible(
      find.text('Вітамін D'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Вітамін D'));
    await settle(tester);
    expect(find.text('Аналіз прийому'), findsOneWidget);
    expect(find.text('Поточна серія'), findsOneWidget);
    expect(find.text('Найдовша серія'), findsOneWidget);
    await tester.tap(find.text('Точність часу'));
    await settle(tester);
    expect(find.text('Пізніше на 15–60 хв'), findsOneWidget);
    await unmount(tester);
  });
}
