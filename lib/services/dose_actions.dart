import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/database.dart';
import '../domain/dose_plan.dart';
import '../domain/enums.dart';
import '../domain/notification_payload.dart';
import 'notification_service.dart';
import 'settings.dart';

/// A scheduled dose to act on.
typedef DoseRef = ({int medicationId, DateTime scheduledAt, double dose});

/// Marks doses taken, skipped or snoozed. Used by the UI and by
/// notification buttons (also from the background isolate).
class DoseActions {
  DoseActions({
    required this.db,
    required this.notifications,
    required this.prefs,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final NotificationService notifications;
  final SharedPreferences prefs;
  final DateTime Function() _clock;

  Future<void> _setAll(
    List<DoseRef> doses,
    DoseStatus status,
    DateTime actualAt,
  ) async {
    for (final d in doses) {
      await db.setDoseStatus(
        medicationId: d.medicationId,
        scheduledAt: d.scheduledAt,
        dose: d.dose,
        status: status,
        actualAt: actualAt,
      );
    }
    final byTime = <DateTime, Set<int>>{};
    for (final d in doses) {
      byTime.putIfAbsent(d.scheduledAt, () => {}).add(d.medicationId);
    }
    for (final MapEntry(key: t, value: ids) in byTime.entries) {
      await notifications.cancelForDose(t, medicationIds: ids);
    }
  }

  /// Marks taken now, or at the scheduled time for a past day.
  Future<void> take(List<DoseRef> doses) async {
    final now = _clock();
    for (final d in doses) {
      final sameDay =
          d.scheduledAt.year == now.year &&
          d.scheduledAt.month == now.month &&
          d.scheduledAt.day == now.day;
      await _setAll([d], DoseStatus.taken, sameDay ? now : d.scheduledAt);
    }
  }

  Future<void> skip(List<DoseRef> doses) =>
      _setAll(doses, DoseStatus.skipped, _clock());

  /// Snoozes and returns when the reminder fires again.
  Future<DateTime> snooze(List<DoseRef> doses) async {
    final until = _clock().add(Duration(minutes: Prefs.snooze(prefs)));
    await _setAll(doses, DoseStatus.snoozed, until);
    return until;
  }

  Future<void> undo(List<DoseRef> doses) async {
    for (final d in doses) {
      await db.clearDose(d.medicationId, d.scheduledAt);
    }
  }

  /// Handles a notification button. Returns false for a plain tap.
  Future<bool> handleNotificationResponse(NotificationResponse r) async {
    final action = r.actionId;
    final payload = NotificationPayload.tryDecode(r.payload);
    if (action == null || payload == null) return false;
    final doses = [
      for (final e in payload.doses.entries)
        (medicationId: e.key, scheduledAt: payload.doseTime, dose: e.value),
    ];
    switch (action) {
      case NotificationActions.taken:
        await take(doses);
      case NotificationActions.skip:
        await skip(doses);
      case NotificationActions.snooze:
        final until = await snooze(doses);
        await _scheduleSnooze(payload, until);
      default:
        return false;
    }
    return true;
  }

  Future<void> _scheduleSnooze(NotificationPayload p, DateTime until) async {
    if (!NotificationService.supported) return;
    final meds = {for (final m in await db.watchMedications().first) m.id: m};
    final items = [
      for (final e in p.doses.entries)
        if (meds[e.key] case final m?)
          NotificationItem(
            medicationId: m.id,
            name: m.name,
            dose: e.value,
            unit: m.unit,
            look: m.look,
            meal: m.meal,
          ),
    ];
    if (items.isEmpty) return;
    notifications.sound = Prefs.soundKey(prefs);
    // One reminder per medication, as when planned (see the sync).
    for (final n in notificationsFor(
      doseTime: p.doseTime,
      at: until,
      kind: NotificationKind.snooze,
      items: items,
    )) {
      await notifications.schedule(n, localizationsFor(prefs));
    }
  }
}

/// Entry point for notification buttons when the app is in the background
/// or closed. Runs in its own isolate.
@pragma('vm:entry-point')
Future<void> onNotificationActionInBackground(NotificationResponse r) async {
  DartPluginRegistrant.ensureInitialized();
  await initTimeZones();
  final prefs = await SharedPreferences.getInstance();
  final db = AppDatabase();
  try {
    await DoseActions(
      db: db,
      notifications: NotificationService(),
      prefs: prefs,
    ).handleNotificationResponse(r);
  } finally {
    await db.close();
  }
}
