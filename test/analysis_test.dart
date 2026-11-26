import 'package:bady/domain/analysis.dart';
import 'package:bady/domain/dose_plan.dart';
import 'package:bady/domain/enums.dart';
import 'package:bady/domain/schedule_rule.dart';
import 'package:bady/domain/stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026, 11, 18, 12);
  final start = DateTime(2026, 11, 9); // a Monday
  DateTime at(int day, int hour, [int minute = 0]) =>
      DateTime(2026, 11, day, hour, minute);

  final entries = [
    PlanEntry(
      medicationId: 1,
      name: 'D',
      unit: '',
      rule: ScheduleRule(
        startDate: start,
        times: const [
          DoseTime(hour: 9, minute: 0),
          DoseTime(hour: 21, minute: 0, dose: 2),
        ],
      ),
    ),
  ];

  LoggedDose log(
    DateTime t,
    DoseStatus s, {
    DateTime? actual,
    double dose = 1,
  }) => LoggedDose(
    medicationId: 1,
    scheduledAt: t,
    status: s,
    dose: dose,
    actualAt: actual ?? t,
  );

  test('lists doses by outcome, newest first', () {
    final logged = [
      log(at(17, 9), DoseStatus.taken, actual: at(17, 9, 40)),
      log(at(17, 21), DoseStatus.skipped, dose: 2),
      log(at(18, 9), DoseStatus.taken),
    ];
    final taken = dosesWithOutcome(
      entries: entries,
      logged: logged,
      now: now,
      periodDays: 2,
      outcome: DoseOutcome.taken,
    );
    expect(taken.map((s) => s.time), [at(18, 9), at(17, 9)]);
    final missed = dosesWithOutcome(
      entries: entries,
      logged: logged,
      now: now,
      periodDays: 2,
      outcome: DoseOutcome.missed,
    );
    // 21:00 today is not due yet; nothing else was left unmarked.
    expect(missed, isEmpty);
    expect(delayMinutes(taken.last), 40);
  });

  test('timing buckets', () {
    DoseSlot slot(int delay) => DoseSlot(
      medicationId: 1,
      time: at(10, 9),
      scheduledAt: at(10, 9),
      actualAt: at(10, 9).add(Duration(minutes: delay)),
      dose: 1,
      state: DoseState.taken,
      eventId: 1,
    );
    final t = timingOf([slot(-30), slot(5), slot(-10), slot(40), slot(90)]);
    expect(t.count, 5);
    expect(t.early, 1);
    expect(t.onTime, 2);
    expect(t.late, 1);
    expect(t.veryLate, 1);
    expect(t.maxLateMinutes, 90);
    expect(t.averageMinutes, 19);
  });

  test('streaks: current and best, unfinished today is ok', () {
    DayStat d(int day, {int taken = 0, int missed = 0}) =>
        DayStat(at(day, 0), DoseCounts(taken: taken, missed: missed));
    final s = streaksOf([
      d(1, taken: 2),
      d(2, taken: 2),
      d(3, taken: 2),
      d(4, taken: 1, missed: 1),
      d(5), // nothing due
      d(6, taken: 2),
      d(7, missed: 1), // today, not finished
    ]);
    expect(s.best, 3);
    expect(s.current, 1);
  });

  test('medication analysis', () {
    final logged = [
      for (var day = 9; day <= 17; day++) ...[
        log(at(day, 9), DoseStatus.taken, actual: at(day, 9, 20)),
        if (day != 13) log(at(day, 21), DoseStatus.taken, dose: 2),
      ],
      log(at(18, 9), DoseStatus.taken),
    ];
    final a = analyzeMedication(
      entries: entries,
      logged: logged,
      now: now,
      historyStart: start,
      periodDays: 7,
    );
    expect(a.periodDays, 7);
    expect(a.days.first.day, at(12, 0));
    // 12th..17th: 12 doses, one missed (13th 21:00); today: 1 of 1 due.
    expect(a.counts.taken, 12);
    expect(a.counts.missed, 1);
    expect(a.partialDays, 1);
    expect(a.fullDays, 6);
    expect(a.byWeekday[DateTime.friday]!.missed, 1); // 13 Nov 2026
    expect(a.byTime[21 * 60]!.taken, 5);
    expect(a.timing.late, 6); // 20 minutes late each morning
    expect(a.timing.onTime, 6);
    expect(a.takenAmount, 6 + 5 * 2 + 1 + 0.0);
    expect(a.streaks.current, 5);
    expect(a.streaks.best, 5);
    // The 7 days before the period only partly exist (from the 9th).
    expect(a.previous, isNull);

    final all = analyzeMedication(
      entries: entries,
      logged: logged,
      now: now,
      historyStart: start,
      periodDays: 999,
    );
    expect(all.periodDays, 10);
    expect(all.takenCountAll, 18);
  });

  test('course progress and packs to finish', () {
    final rule = ScheduleRule(
      startDate: DateTime(2026, 11, 10),
      durationType: DurationType.days,
      durationValue: 30,
      times: const [DoseTime(hour: 9, minute: 0)],
    );
    final p = courseProgress(rule, now);
    expect(p.day, 9);
    expect(p.length, 30);
    // 19th..9th Dec: 21 doses left after noon on the 18th.
    final left = remainingCourseAmount([rule], now);
    expect(left, 21);
    expect(packsToFinish(remaining: left, stock: 5, packSize: 10), 2);
    expect(packsToFinish(remaining: left, stock: 30, packSize: 10), 0);
    expect(remainingCourseAmount([entries.first.rule], now), isNull);
  });
}
