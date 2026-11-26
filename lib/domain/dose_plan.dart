/// Pure-Dart planning of doses: what is due on a day, what has been logged,
/// and which notifications to schedule. No Flutter or database imports.
library;

import 'enums.dart';
import 'look.dart';
import 'schedule_rule.dart';

/// A schedule together with the medication fields planning needs.
class PlanEntry {
  const PlanEntry({
    required this.medicationId,
    required this.name,
    required this.unit,
    required this.rule,
    this.look = const PillLook(),
    this.meal = MealRelation.any,
  });

  final int medicationId;
  final String name;
  final String unit;
  final ScheduleRule rule;
  final PillLook look;
  final MealRelation meal;
}

/// What a medication looks like, for drawing it in notifications.
class PillLook {
  const PillLook({
    this.shape = PillShape.roundTablet,
    this.color = 0xFFFFFFFF,
    this.color2,
  });

  final PillShape shape;
  final int color;
  final int? color2;

  /// Identifies the drawing, e.g. to notice when a reminder's icon changes.
  String get key => '${shape.name}:$color:$color2';
}

/// A dose that was logged (taken, skipped or snoozed).
class LoggedDose {
  const LoggedDose({
    this.id,
    required this.medicationId,
    required this.scheduledAt,
    required this.status,
    required this.dose,
    this.actualAt,
  });

  final int? id;
  final int medicationId;

  /// Null for an unscheduled ("as needed") dose.
  final DateTime? scheduledAt;
  final DoseStatus status;
  final double dose;

  /// When it was taken or skipped; for [DoseStatus.snoozed], when the
  /// snoozed reminder fires.
  final DateTime? actualAt;
}

/// What the user sees for a dose.
enum DoseState { planned, overdue, snoozed, taken, skipped }

class DoseSlot {
  const DoseSlot({
    required this.medicationId,
    required this.time,
    required this.dose,
    required this.state,
    this.scheduledAt,
    this.actualAt,
    this.eventId,
  });

  final int medicationId;

  /// Scheduled time, or the actual time for unscheduled doses.
  final DateTime time;

  /// Null for unscheduled doses.
  final DateTime? scheduledAt;
  final double dose;
  final DoseState state;
  final DateTime? actualAt;
  final int? eventId;

  bool get isPending =>
      state == DoseState.planned ||
      state == DoseState.overdue ||
      state == DoseState.snoozed;

  bool get isLogged => eventId != null && state != DoseState.snoozed;
}

typedef _Key = (int, DateTime);

DoseState _stateFor(LoggedDose? e, DateTime time, DateTime now) {
  if (e == null) {
    return time.isAfter(now) ? DoseState.planned : DoseState.overdue;
  }
  switch (e.status) {
    case DoseStatus.taken:
      return DoseState.taken;
    case DoseStatus.skipped:
      return DoseState.skipped;
    case DoseStatus.snoozed:
      final until = e.actualAt;
      return until != null && until.isAfter(now)
          ? DoseState.snoozed
          : DoseState.overdue;
    case DoseStatus.missed:
      return DoseState.overdue;
  }
}

/// All doses for [day]: scheduled ones merged with what was logged, plus
/// unscheduled doses logged that day. Sorted by time.
List<DoseSlot> buildDay({
  required Iterable<PlanEntry> entries,
  required Iterable<LoggedDose> logged,
  required DateTime day,
  required DateTime now,
}) {
  final start = dateOnly(day);
  final end = addDays(start, 1);
  final byKey = <_Key, LoggedDose>{
    for (final e in logged)
      if (e.scheduledAt != null) (e.medicationId, e.scheduledAt!): e,
  };
  final slots = <DoseSlot>[];
  final seen = <_Key>{};

  for (final entry in entries) {
    for (final o in entry.rule.occurrences(start, end)) {
      final key = (entry.medicationId, o.at);
      if (!seen.add(key)) continue;
      final e = byKey[key];
      slots.add(
        DoseSlot(
          medicationId: entry.medicationId,
          time: o.at,
          scheduledAt: o.at,
          dose: e?.dose ?? o.dose,
          state: _stateFor(e, o.at, now),
          actualAt: e?.actualAt,
          eventId: e?.id,
        ),
      );
    }
  }

  // Logged doses that no longer match a schedule (edited or deleted), and
  // unscheduled doses.
  for (final e in logged) {
    final time = e.scheduledAt ?? e.actualAt;
    if (time == null || time.isBefore(start) || !time.isBefore(end)) continue;
    if (e.scheduledAt != null &&
        seen.contains((e.medicationId, e.scheduledAt!))) {
      continue;
    }
    slots.add(
      DoseSlot(
        medicationId: e.medicationId,
        time: time,
        scheduledAt: e.scheduledAt,
        dose: e.dose,
        state: _stateFor(e, time, now),
        actualAt: e.actualAt,
        eventId: e.id,
      ),
    );
  }

  slots.sort((a, b) {
    final c = a.time.compareTo(b.time);
    return c != 0 ? c : a.medicationId.compareTo(b.medicationId);
  });
  return slots;
}

class DaySummary {
  const DaySummary({
    required this.total,
    required this.taken,
    required this.skipped,
    required this.pending,
  });

  final int total;
  final int taken;
  final int skipped;
  final int pending;

  double get progress => total == 0 ? 0 : taken / total;
}

DaySummary summarize(List<DoseSlot> slots) {
  var taken = 0, skipped = 0, pending = 0;
  for (final s in slots) {
    switch (s.state) {
      case DoseState.taken:
        taken++;
      case DoseState.skipped:
        skipped++;
      default:
        pending++;
    }
  }
  return DaySummary(
    total: slots.length,
    taken: taken,
    skipped: skipped,
    pending: pending,
  );
}

/// Part of the day a dose time falls into.
enum DayPart { night, morning, afternoon, evening }

DayPart dayPartOf(DateTime t) => switch (t.hour) {
  < 4 => DayPart.night,
  < 12 => DayPart.morning,
  < 17 => DayPart.afternoon,
  _ => DayPart.evening,
};

// ---------------------------------------------------------------------------
// Notifications

enum NotificationKind { main, followUp, snooze }

class NotificationItem {
  const NotificationItem({
    required this.medicationId,
    required this.name,
    required this.dose,
    required this.unit,
    this.look = const PillLook(),
    this.meal = MealRelation.any,
  });

  final int medicationId;
  final String name;
  final double dose;
  final String unit;
  final PillLook look;

  /// Shown in the reminder ("after meals").
  final MealRelation meal;
}

/// How a notification relates to the others for the same dose time.
enum NotificationRole {
  /// The only notification for its dose time and fire time.
  single,

  /// One medication's notification inside a group; it has its own buttons.
  child,

  /// The group header listing all medications; no buttons.
  summary,
}

/// One notification to schedule. [doseTime] identifies the doses it is
/// about; [at] is when it fires. Doses due at the same time get one
/// notification per medication, bundled under a [NotificationRole.summary]
/// when there are several, so each can be taken, snoozed or skipped alone.
class PlannedNotification {
  PlannedNotification({
    required this.doseTime,
    required this.at,
    required this.kind,
    required this.items,
    this.role = NotificationRole.single,
    this.timeoutAfter,
    int followUpIndex = 0,
  }) : id = notificationIdFor(
         doseTime,
         role == NotificationRole.summary
             ? summarySlot
             : slotFor(items.first.medicationId),
         _kindIndex(kind, followUpIndex),
       );

  final int id;
  final DateTime doseTime;
  final DateTime at;
  final NotificationKind kind;
  final List<NotificationItem> items;
  final NotificationRole role;

  /// Dismiss after this long, when the next follow-up replaces it.
  final Duration? timeoutAfter;

  /// Android bundles notifications with the same key.
  String get groupKey =>
      'dose_${doseTime.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute}';
}

int _kindIndex(NotificationKind kind, int followUpIndex) => switch (kind) {
  NotificationKind.main => 0,
  NotificationKind.followUp => 1 + followUpIndex.clamp(0, 1),
  NotificationKind.snooze => 3,
};

/// Medications get one of 15 slots per dose minute; slot 15 is the group
/// summary. Two medications sharing a slot (ids 15 apart, due at the same
/// minute) share one notification.
const summarySlot = 15;
int slotFor(int medicationId) => medicationId % 15;

/// 16 slots × 4 kinds (main, two follow-ups, snooze) per dose minute.
int notificationIdFor(DateTime doseTime, int slot, int kind) {
  final minute =
      doseTime.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;
  return (minute % 0x1FFFFFF) * 64 + slot * 4 + kind;
}

/// Every notification id for [doseTime] in [slots] (default: all).
List<int> notificationIdsFor(DateTime doseTime, [Iterable<int>? slots]) => [
  for (final slot in slots ?? List.generate(16, (i) => i))
    for (var k = 0; k < 4; k++) notificationIdFor(doseTime, slot, k),
];

/// Whether notification [id] is a medication's (not the summary's) for
/// [doseTime].
bool isChildIdFor(int id, DateTime doseTime) {
  final minute =
      doseTime.millisecondsSinceEpoch ~/ Duration.millisecondsPerMinute;
  return id >= 0 &&
      id ~/ 64 == minute % 0x1FFFFFF &&
      (id % 64) ~/ 4 != summarySlot;
}

/// Splits one fire time's medications into per-medication notifications,
/// with a summary when there are several.
List<PlannedNotification> notificationsFor({
  required DateTime doseTime,
  required DateTime at,
  required NotificationKind kind,
  int followUpIndex = 0,
  required List<NotificationItem> items,
  Duration? timeoutAfter,
}) {
  items.sort((a, b) => a.name.compareTo(b.name));
  final bySlot = <int, List<NotificationItem>>{};
  for (final i in items) {
    bySlot.putIfAbsent(slotFor(i.medicationId), () => []).add(i);
  }
  PlannedNotification make(List<NotificationItem> list, NotificationRole r) =>
      PlannedNotification(
        doseTime: doseTime,
        at: at,
        kind: kind,
        followUpIndex: followUpIndex,
        items: list,
        role: r,
        timeoutAfter: timeoutAfter,
      );
  if (bySlot.length == 1) return [make(items, NotificationRole.single)];
  return [
    make(items, NotificationRole.summary),
    for (final list in bySlot.values) make(list, NotificationRole.child),
  ];
}

/// Works out every notification to schedule from [now] to [now] + [horizon]:
/// the main reminder, follow-ups for doses still not logged, and snoozed
/// reminders. Doses already taken or skipped get nothing. At most
/// [maxCount] notifications, earliest first, never splitting a group.
List<PlannedNotification> buildNotificationPlan({
  required Iterable<PlanEntry> entries,
  required Iterable<LoggedDose> logged,
  required DateTime now,
  Duration horizon = const Duration(days: 14),
  List<int> followUpMinutes = const [15, 30],
  int maxCount = 400,
}) {
  final follow = followUpMinutes.take(2).toList();
  final maxFollow = follow.isEmpty ? 0 : follow.reduce((a, b) => a > b ? a : b);
  final from = now.subtract(Duration(minutes: maxFollow));
  final to = now.add(horizon);
  final byKey = <_Key, LoggedDose>{
    for (final e in logged)
      if (e.scheduledAt != null) (e.medicationId, e.scheduledAt!): e,
  };

  // (fire time, kind, follow-up index, dose time) -> items
  final groups =
      <(DateTime, NotificationKind, int, DateTime), List<NotificationItem>>{};
  void add(
    DateTime at,
    NotificationKind kind,
    int index,
    DateTime doseTime,
    NotificationItem item,
  ) {
    if (!at.isAfter(now)) return;
    groups.putIfAbsent((at, kind, index, doseTime), () => []).add(item);
  }

  for (final entry in entries) {
    for (final o in entry.rule.occurrences(from, to)) {
      final item = NotificationItem(
        medicationId: entry.medicationId,
        name: entry.name,
        dose: o.dose,
        unit: entry.unit,
        look: entry.look,
        meal: entry.meal,
      );
      final e = byKey[(entry.medicationId, o.at)];
      if (e != null &&
          (e.status == DoseStatus.taken || e.status == DoseStatus.skipped)) {
        continue;
      }
      if (e != null &&
          e.status == DoseStatus.snoozed &&
          e.actualAt != null &&
          e.actualAt!.isAfter(now)) {
        add(e.actualAt!, NotificationKind.snooze, 0, o.at, item);
        continue;
      }
      add(o.at, NotificationKind.main, 0, o.at, item);
      for (final (i, m) in follow.indexed) {
        add(
          o.at.add(Duration(minutes: m)),
          NotificationKind.followUp,
          i,
          o.at,
          item,
        );
      }
    }
  }

  // Each reminder clears itself when the next follow-up arrives.
  Duration? timeoutFor(NotificationKind kind, int index) {
    if (kind == NotificationKind.snooze || follow.isEmpty) return null;
    final current = kind == NotificationKind.main ? 0 : follow[index];
    final nextIndex = kind == NotificationKind.main ? 0 : index + 1;
    if (nextIndex >= follow.length) return null;
    return Duration(minutes: follow[nextIndex] - current);
  }

  final keys = groups.keys.toList()
    ..sort((a, b) {
      final c = a.$1.compareTo(b.$1);
      return c != 0 ? c : a.$4.compareTo(b.$4);
    });
  final result = <PlannedNotification>[];
  for (final k in keys) {
    final list = notificationsFor(
      doseTime: k.$4,
      at: k.$1,
      kind: k.$2,
      followUpIndex: k.$3,
      items: groups[k]!,
      timeoutAfter: timeoutFor(k.$2, k.$3),
    );
    if (result.length + list.length > maxCount) break;
    result.addAll(list);
  }
  return result;
}
