/// Detailed analysis built on top of [computeStats]: which doses were taken,
/// skipped or missed, and per-medication breakdowns (streaks, weekdays,
/// dose times, timing accuracy, amounts). Pure Dart.
library;

import 'dose_plan.dart';
import 'schedule_rule.dart';
import 'stats.dart';

/// How a due dose ended up.
enum DoseOutcome { taken, skipped, missed }

/// Null while the dose is not due yet, or is snoozed and still pending.
DoseOutcome? outcomeOf(DoseSlot s, DateTime now) {
  if (s.time.isAfter(now)) return null;
  return switch (s.state) {
    DoseState.taken => DoseOutcome.taken,
    DoseState.skipped => DoseOutcome.skipped,
    DoseState.overdue => DoseOutcome.missed,
    DoseState.snoozed || DoseState.planned => null,
  };
}

DoseCounts countsOf(DoseOutcome? o) => switch (o) {
  DoseOutcome.taken => const DoseCounts(taken: 1),
  DoseOutcome.skipped => const DoseCounts(skipped: 1),
  DoseOutcome.missed => const DoseCounts(missed: 1),
  null => const DoseCounts(),
};

/// Every dose on the days [firstDay]..[lastDay] (inclusive), oldest first.
List<DoseSlot> slotsBetween({
  required Iterable<PlanEntry> entries,
  required Iterable<LoggedDose> logged,
  required DateTime firstDay,
  required DateTime lastDay,
  required DateTime now,
}) {
  final byDay = <DateTime, List<LoggedDose>>{};
  for (final e in logged) {
    final t = e.scheduledAt ?? e.actualAt;
    if (t == null) continue;
    byDay.putIfAbsent(dateOnly(t), () => []).add(e);
  }
  final entryList = entries.toList();
  final result = <DoseSlot>[];
  final first = dateOnly(firstDay);
  final count = daysBetween(first, dateOnly(lastDay)) + 1;
  for (var i = 0; i < count; i++) {
    final day = addDays(first, i);
    result.addAll(
      buildDay(
        entries: entryList,
        logged: byDay[day] ?? const [],
        day: day,
        now: now,
      ),
    );
  }
  return result;
}

/// Due doses with [outcome] over the [periodDays] days ending today,
/// newest first.
List<DoseSlot> dosesWithOutcome({
  required Iterable<PlanEntry> entries,
  required Iterable<LoggedDose> logged,
  required DateTime now,
  required int periodDays,
  required DoseOutcome outcome,
}) {
  final today = dateOnly(now);
  return slotsBetween(
    entries: entries,
    logged: logged,
    firstDay: addDays(today, 1 - periodDays),
    lastDay: today,
    now: now,
  ).where((s) => outcomeOf(s, now) == outcome).toList().reversed.toList();
}

/// How close to the planned time taken doses were.
class Timing {
  const Timing({
    this.count = 0,
    this.averageMinutes,
    this.early = 0,
    this.onTime = 0,
    this.late = 0,
    this.veryLate = 0,
    this.maxLateMinutes,
  });

  /// Taken scheduled doses with a known time.
  final int count;

  /// Average minutes after the planned time (negative = early).
  final double? averageMinutes;

  /// More than [tolerance] minutes early.
  final int early;

  /// Within [tolerance] minutes either way.
  final int onTime;

  /// [tolerance] to 60 minutes late.
  final int late;

  /// More than an hour late.
  final int veryLate;

  /// The latest a dose was taken, in minutes; null when none was late.
  final int? maxLateMinutes;

  static const tolerance = 15;
}

/// Minutes from planned to actual time for a taken scheduled dose.
int? delayMinutes(DoseSlot s) {
  if (s.state != DoseState.taken) return null;
  final planned = s.scheduledAt, actual = s.actualAt;
  if (planned == null || actual == null) return null;
  return actual.difference(planned).inMinutes;
}

Timing timingOf(Iterable<DoseSlot> slots) {
  var count = 0, sum = 0, early = 0, onTime = 0, late = 0, veryLate = 0;
  int? maxLate;
  for (final s in slots) {
    final d = delayMinutes(s);
    if (d == null) continue;
    count++;
    sum += d;
    if (d < -Timing.tolerance) {
      early++;
    } else if (d <= Timing.tolerance) {
      onTime++;
    } else if (d <= 60) {
      late++;
    } else {
      veryLate++;
    }
    if (d > Timing.tolerance && (maxLate == null || d > maxLate)) maxLate = d;
  }
  return Timing(
    count: count,
    averageMinutes: count == 0 ? null : sum / count,
    early: early,
    onTime: onTime,
    late: late,
    veryLate: veryLate,
    maxLateMinutes: maxLate,
  );
}

/// Days in a row with every due dose taken.
class Streaks {
  const Streaks(this.current, this.best);

  /// Ending today or yesterday; an unfinished today does not break it.
  final int current;
  final int best;
}

/// [days] oldest first; the last one is today.
Streaks streaksOf(List<DayStat> days) {
  var best = 0, run = 0;
  for (final (i, d) in days.indexed) {
    final c = d.counts;
    if (c.total == 0) continue;
    if (c.skipped + c.missed > 0) {
      // An unfinished today neither breaks nor extends the run.
      if (i == days.length - 1) continue;
      run = 0;
    } else {
      run++;
      if (run > best) best = run;
    }
  }
  return Streaks(run, best);
}

/// Everything shown on a medication's analysis screen.
class MedicationAnalysis {
  const MedicationAnalysis({
    required this.periodDays,
    required this.days,
    required this.counts,
    required this.previous,
    required this.streaks,
    required this.fullDays,
    required this.partialDays,
    required this.emptyDays,
    required this.byWeekday,
    required this.byTime,
    required this.timing,
    required this.takenAmount,
    required this.takenAmountAll,
    required this.takenCountAll,
  });

  final int periodDays;

  /// The period, oldest first.
  final List<DayStat> days;
  final DoseCounts counts;

  /// The same length of time just before the period; null when the history
  /// does not reach that far.
  final DoseCounts? previous;

  /// Over the whole history, not only the period.
  final Streaks streaks;

  /// Days in the period with something due, by how much of it was taken.
  final int fullDays;
  final int partialDays;
  final int emptyDays;

  /// 1 = Monday … 7 = Sunday.
  final Map<int, DoseCounts> byWeekday;

  /// Planned minute of day -> counts.
  final Map<int, DoseCounts> byTime;
  final Timing timing;

  /// Sum of taken doses (in the medication's unit) in the period.
  final double takenAmount;
  final double takenAmountAll;
  final int takenCountAll;

  bool get isEmpty => counts.total == 0;

  /// Taken amount per day of the period.
  double get averagePerDay => periodDays == 0 ? 0 : takenAmount / periodDays;
}

/// Analysis of one medication. [entries] and [logged] should already be
/// limited to it. [historyStart] is the first day to look at (when the
/// medication was added, or a year ago at most); [periodDays] counts back
/// from today and is clamped to the history.
MedicationAnalysis analyzeMedication({
  required Iterable<PlanEntry> entries,
  required Iterable<LoggedDose> logged,
  required DateTime now,
  required DateTime historyStart,
  required int periodDays,
}) {
  final today = dateOnly(now);
  var start = dateOnly(historyStart);
  if (start.isAfter(today)) start = today;
  final historyDays = daysBetween(start, today) + 1;
  final period = periodDays.clamp(1, historyDays);

  final slots = slotsBetween(
    entries: entries,
    logged: logged,
    firstDay: start,
    lastDay: today,
    now: now,
  );
  final byDay = <DateTime, List<DoseSlot>>{};
  for (final s in slots) {
    byDay.putIfAbsent(dateOnly(s.time), () => []).add(s);
  }

  final allDays = <DayStat>[];
  for (var i = 0; i < historyDays; i++) {
    final day = addDays(start, i);
    var c = const DoseCounts();
    for (final s in byDay[day] ?? const <DoseSlot>[]) {
      c = c + countsOf(outcomeOf(s, now));
    }
    allDays.add(DayStat(day, c));
  }

  final days = allDays.sublist(historyDays - period);
  final periodStart = days.first.day;
  final inPeriod = [
    for (final s in slots)
      if (!s.time.isBefore(periodStart)) s,
  ];

  DoseCounts sum(Iterable<DayStat> d) =>
      d.fold(const DoseCounts(), (a, b) => a + b.counts);

  final previous = historyDays >= period * 2
      ? sum(allDays.sublist(historyDays - period * 2, historyDays - period))
      : null;

  var full = 0, partial = 0, empty = 0;
  for (final d in days) {
    final c = d.counts;
    if (c.total == 0) continue;
    if (c.taken == c.total) {
      full++;
    } else if (c.taken > 0) {
      partial++;
    } else {
      empty++;
    }
  }

  final byWeekday = <int, DoseCounts>{};
  final byTime = <int, DoseCounts>{};
  var amount = 0.0;
  for (final s in inPeriod) {
    final o = outcomeOf(s, now);
    if (o == null) continue;
    final c = countsOf(o);
    byWeekday[s.time.weekday] =
        (byWeekday[s.time.weekday] ?? const DoseCounts()) + c;
    if (s.scheduledAt case final t?) {
      final m = t.hour * 60 + t.minute;
      byTime[m] = (byTime[m] ?? const DoseCounts()) + c;
    }
    if (o == DoseOutcome.taken) amount += s.dose;
  }

  var amountAll = 0.0;
  var takenAll = 0;
  for (final s in slots) {
    if (outcomeOf(s, now) == DoseOutcome.taken) {
      amountAll += s.dose;
      takenAll++;
    }
  }

  return MedicationAnalysis(
    periodDays: period,
    days: days,
    counts: sum(days),
    previous: previous,
    streaks: streaksOf(allDays),
    fullDays: full,
    partialDays: partial,
    emptyDays: empty,
    byWeekday: byWeekday,
    byTime: byTime,
    timing: timingOf(inPeriod),
    takenAmount: amount,
    takenAmountAll: amountAll,
    takenCountAll: takenAll,
  );
}

/// A schedule's course: which day it is on and how long it lasts.
class CourseProgress {
  const CourseProgress({required this.day, required this.length});

  /// 1-based day of the course today (0 before it starts).
  final int day;

  /// Total days, or null for a schedule with no end.
  final int? length;
}

CourseProgress courseProgress(ScheduleRule rule, DateTime now) {
  final start = dateOnly(rule.startDate);
  final today = dateOnly(now);
  final last = rule.lastDay;
  final length = last == null ? null : daysBetween(start, last) + 1;
  var day = daysBetween(start, today) + 1;
  if (day < 0) day = 0;
  if (length != null && day > length) day = length;
  return CourseProgress(day: day, length: length);
}

/// Amount still to take from [now] until every rule ends; null when any
/// rule runs forever.
double? remainingCourseAmount(Iterable<ScheduleRule> rules, DateTime now) {
  var total = 0.0;
  for (final r in rules) {
    final last = r.lastDay;
    if (last == null) return null;
    for (final o in r.occurrences(now, addDays(last, 1))) {
      if (o.at.isAfter(now)) total += o.dose;
    }
  }
  return total;
}

/// Packs to buy to finish the course, or null when unknown.
int? packsToFinish({
  required double? remaining,
  required double? stock,
  required double? packSize,
}) {
  if (remaining == null || stock == null || packSize == null) return null;
  if (packSize <= 0) return null;
  final need = remaining - stock;
  if (need <= 1e-9) return 0;
  return (need / packSize - 1e-9).ceil();
}
