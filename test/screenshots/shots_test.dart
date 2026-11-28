// Renders app screens with demo data to PNG files.
// Skipped unless SHOTS_DIR is set. Run:
// flutter test test/screenshots/shots_test.dart --dart-define=SHOTS_DIR=/abs/dir \
//   --dart-define=SHOTS_FONTS=<flutter>/bin/cache/artifacts/material_fonts
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:bady/app.dart';
import 'package:bady/data/database.dart';
import 'package:bady/domain/enums.dart';
import 'package:bady/domain/schedule_rule.dart';
import 'package:bady/l10n/app_localizations.dart';
import 'package:bady/providers.dart';
import 'package:bady/ui/day_analysis_screen.dart';
import 'package:bady/ui/guide_widgets.dart';
import 'package:bady/ui/history_screen.dart';
import 'package:bady/ui/medication_detail_screen.dart';
import 'package:bady/ui/medication_form_screen.dart';
import 'package:bady/ui/medication_stats_screen.dart';
import 'package:bady/ui/pro_screen.dart';
import 'package:bady/ui/schedule_editor_screen.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _outDir = String.fromEnvironment('SHOTS_DIR');
const _variant = String.fromEnvironment('SHOTS_PREFIX', defaultValue: 'shot');
const _fontsDir = String.fromEnvironment('SHOTS_FONTS');
const _locale = String.fromEnvironment('SHOTS_LOCALE', defaultValue: 'ru');
// SHOTS_ALL=true also renders detail screens (forms, analysis, guide...).
const _all = bool.fromEnvironment('SHOTS_ALL');
const _uk = _locale == 'uk';

Future<void> _loadFonts() async {
  final roboto = FontLoader('Roboto');
  for (final w in ['Regular', 'Medium', 'Bold']) {
    final bytes = File('$_fontsDir/Roboto-$w.ttf').readAsBytesSync();
    roboto.addFont(Future.value(ByteData.view(bytes.buffer)));
  }
  await roboto.load();
  final icons = FontLoader('MaterialIcons');
  icons.addFont(
    Future.value(
      ByteData.view(
        File('$_fontsDir/MaterialIcons-Regular.otf').readAsBytesSync().buffer,
      ),
    ),
  );
  await icons.load();
}

void main() {
  late AppDatabase db;
  final boundary = GlobalKey();

  setUpAll(() async {
    if (_outDir.isEmpty) return;
    debugDisableShadows = false;
    await _loadFonts();
  });
  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
  }

  Future<void> seed(WidgetTester tester) async {
    await tester.runAsync(() async {
      final today = dateOnly(DateTime.now());
      final first = addDays(today, -29);
      final rnd = Random(7);
      final meds = [
        (
          _uk ? 'Вітамін D3' : 'Витамин D3',
          MedKind.supplement,
          MedForm.capsule,
          0xFFF2B233,
          [9],
          0.95,
        ),
        ('Омега-3', MedKind.supplement, MedForm.capsule, 0xFF4F7DF3, [13], 0.8),
        (
          _uk ? 'Магній' : 'Магний',
          MedKind.supplement,
          MedForm.tablet,
          0xFF8E6CEF,
          [21],
          0.7,
        ),
        (
          _uk ? 'Метформін' : 'Метформин',
          MedKind.medicine,
          MedForm.tablet,
          0xFFE8655A,
          [8, 20],
          0.9,
        ),
      ];
      for (final (name, kind, form, color, hours, rate) in meds) {
        final id = await db.insertMedication(
          MedicationsCompanion.insert(
            name: name,
            kind: kind,
            form: form,
            color: Value(color),
            createdAt: Value(first),
            stock: Value(
              name == 'Омега-3'
                  ? 30
                  : kind == MedKind.medicine
                  ? 90
                  : 40,
            ),
            packSize: const Value(60),
          ),
        );
        await db.insertSchedule(
          id,
          ScheduleRule(
            startDate: first,
            times: [for (final h in hours) DoseTime(hour: h, minute: 0)],
          ),
        );
        for (var d = 0; d < 30; d++) {
          for (final h in hours) {
            final at = addDays(first, d).add(Duration(hours: h));
            if (!at.isBefore(DateTime.now())) continue;
            final r = rnd.nextDouble();
            if (r < rate) {
              await db.setDoseStatus(
                medicationId: id,
                scheduledAt: at,
                dose: 1,
                status: DoseStatus.taken,
                actualAt: at.add(Duration(minutes: rnd.nextInt(40))),
              );
            } else if (r < rate + (1 - rate) / 2) {
              await db.setDoseStatus(
                medicationId: id,
                scheduledAt: at,
                dose: 1,
                status: DoseStatus.skipped,
                actualAt: at,
              );
            } // else missed
          }
        }
      }
    });
  }

  Future<void> shot(WidgetTester tester, String name) async {
    await settle(tester);
    final ro =
        boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final bytes = await tester.runAsync(() async {
      final image = await ro.toImage(pixelRatio: 2.5);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    });
    File('$_outDir/${_variant}_$name.png').writeAsBytesSync(bytes!);
  }

  for (final dark in [false, true]) {
    testWidgets('screens ${dark ? 'dark' : 'light'}', skip: _outDir.isEmpty, (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2280);
      tester.view.devicePixelRatio = 2.625;
      tester.platformDispatcher.platformBrightnessTestValue = dark
          ? Brightness.dark
          : Brightness.light;
      addTearDown(tester.view.reset);
      addTearDown(() => debugDisableShadows = true);
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await seed(tester);
      SharedPreferences.setMockInitialValues({
        'locale': _locale,
        'exactAlarmAsked': true,
      });
      final prefs = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        RepaintBoundary(
          key: boundary,
          child: ProviderScope(
            overrides: [
              sharedPreferencesProvider.overrideWithValue(prefs),
              databaseProvider.overrideWithValue(db),
            ],
            child: const DoseApp(),
          ),
        ),
      );
      final l = lookupAppLocalizations(Locale(_locale));
      final suffix = dark ? 'dark' : 'light';
      await shot(tester, 'today_$suffix');
      if (_all) {
        await tester.tap(find.text(_uk ? 'Метформін' : 'Метформин').first);
        await shot(tester, 'dosesheet_$suffix');
        await tester.tapAt(const Offset(200, 60));
        await settle(tester);
      }
      await tester.tap(find.text(l.navMedications));
      await shot(tester, 'meds_$suffix');
      await tester.tap(find.text(l.navStats));
      await shot(tester, 'stats_$suffix');
      await tester.drag(find.byType(ListView).last, const Offset(0, -700));
      await shot(tester, 'statsmeds_$suffix');
      await tester.tap(find.text(l.statsPeriod(30)));
      await shot(tester, 'stats30_$suffix');
      await tester.tap(find.text(l.navSettings));
      await shot(tester, 'settings_$suffix');
      if (_all) {
        await tester.drag(find.byType(ListView).last, const Offset(0, -1400));
        await shot(tester, 'settings2_$suffix');
        final meds = await tester.runAsync(() => db.watchMedications().first);
        final med = meds!.firstWhere((m) => m.kind == MedKind.medicine);
        final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
        Future<void> open(String name, Widget screen) async {
          nav.push(MaterialPageRoute<void>(builder: (_) => screen));
          await shot(tester, '${name}_$suffix');
          nav.pop();
          await settle(tester);
        }

        final today = dateOnly(DateTime.now());
        final supplement = meds.firstWhere((m) => m.kind == MedKind.supplement);
        await open('detail', MedicationDetailScreen(id: supplement.id));
        await open('form', MedicationFormScreen(existing: med));
        await open('formnew', const MedicationFormScreen());
        await open('schedule', ScheduleEditorScreen(medication: med));
        await open('medstats', MedicationStatsScreen(medication: med));
        await open('day', DayAnalysisScreen(day: addDays(today, -1)));
        await open('history', const HistoryScreen());
        nav.push(
          MaterialPageRoute<void>(builder: (_) => const GuideListScreen()),
        );
        await shot(tester, 'guide_$suffix');
        await tester.tap(find.textContaining('Ашваганда'));
        await shot(tester, 'substance_$suffix');
        nav.popUntil((r) => r.isFirst);
        await settle(tester);
        await open('pro', const ProScreen());
      }
      await tester.pumpWidget(const SizedBox());
      await tester.pump(Duration.zero);
    });
  }
}
