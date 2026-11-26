import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../domain/dose_plan.dart';
import '../domain/enums.dart';
import '../domain/format.dart';
import '../domain/look.dart';
import '../domain/notification_payload.dart';
import '../domain/reminder_diff.dart';
import '../domain/schedule_rule.dart';
import '../l10n/app_localizations.dart';
import '../ui/pill_icon.dart';

bool _tzReady = false;

/// Loads time-zone data and the device zone. Safe to call from any isolate.
Future<void> initTimeZones() async {
  if (_tzReady) return;
  tzdata.initializeTimeZones();
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(info.identifier));
  } catch (e) {
    debugPrint('Timezone lookup failed, using UTC: $e');
  }
  _tzReady = true;
}

/// Schedules local reminders with Android exact alarms. Each reminder has
/// Taken / Snooze / Skip buttons that work without opening the app.
class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const horizon = Duration(days: 14);

  /// Android refuses more than 500 alarms per app, so the furthest
  /// reminders wait for the next resync when a plan is very busy.
  static const maxPending = 450;
  static const _defaultChannelId = 'dose_reminders';
  static const _stockChannelId = 'stock';

  /// Restock reminders use negative ids, one per day, so they never clash
  /// with dose reminders.
  static int stockNotificationId(DateTime at) =>
      -1 - daysBetween(DateTime(2020), dateOnly(at));

  final FlutterLocalNotificationsPlugin _plugin;
  bool _ready = false;

  /// Sound key from settings (see `Prefs.sound`). Android fixes a channel's
  /// sound when it is created, so every sound gets its own channel.
  String? sound;

  static String channelIdFor(String? sound) {
    if (sound == null) return _defaultChannelId;
    return 'dose_${stableHash(sound)}';
  }

  static AndroidNotificationSound? _soundFor(String? key) {
    if (key == null) return null;
    if (key.startsWith('raw:')) {
      return RawResourceAndroidNotificationSound(key.substring(4));
    }
    return UriAndroidNotificationSound(key);
  }

  static bool get supported => !kIsWeb && Platform.isAndroid;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  /// Call once in the main isolate. [onResponse] handles taps and actions
  /// while the app is running; [onBackgroundResponse] must be a top-level
  /// function annotated with `@pragma('vm:entry-point')`.
  Future<void> init({
    DidReceiveNotificationResponseCallback? onResponse,
    DidReceiveBackgroundNotificationResponseCallback? onBackgroundResponse,
  }) async {
    if (_ready || !supported) return;
    await initTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@drawable/ic_stat_dose'),
      ),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse: onBackgroundResponse,
    );
    _ready = true;
  }

  /// Payload of the notification that launched the app, if any.
  Future<String?> launchPayload() async {
    if (!supported) return null;
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    final response = details!.notificationResponse;
    // A button press is handled in the background; only a tap opens a dose.
    if (response?.actionId != null) return null;
    return response?.payload;
  }

  Future<bool> requestPermissions() async {
    if (!supported) return false;
    return await _android?.requestNotificationsPermission() ?? false;
  }

  Future<bool> canScheduleExact() async {
    if (!supported) return false;
    return await _android?.canScheduleExactNotifications() ?? false;
  }

  Future<void> requestExactAlarms() async {
    if (!supported) return;
    await _android?.requestExactAlarmsPermission();
  }

  NotificationDetails _details(
    AppLocalizations l, {
    bool actions = true,
    Uint8List? largeIcon,
    PlannedNotification? n,
  }) {
    final role = n?.role ?? NotificationRole.single;
    final grouped = n != null && role != NotificationRole.single;
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelIdFor(sound),
        l.notifChannelName,
        channelDescription: l.notifChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        sound: _soundFor(sound),
        category: AndroidNotificationCategory.reminder,
        styleInformation: role == NotificationRole.summary
            ? InboxStyleInformation([
                for (final i in n!.items) itemLine(i, l),
              ], contentTitle: title(n, l))
            : const DefaultStyleInformation(true, true),
        largeIcon: largeIcon == null ? null : ByteArrayAndroidBitmap(largeIcon),
        // A group sounds once, through its summary.
        groupKey: n?.groupKey,
        setAsGroupSummary: role == NotificationRole.summary,
        groupAlertBehavior: grouped
            ? GroupAlertBehavior.summary
            : GroupAlertBehavior.all,
        subText: role == NotificationRole.child ? title(n!, l) : null,
        timeoutAfter: n?.timeoutAfter?.inMilliseconds,
        actions: actions && role != NotificationRole.summary
            ? [
                AndroidNotificationAction(
                  NotificationActions.taken,
                  l.actionTaken,
                ),
                AndroidNotificationAction(
                  NotificationActions.snooze,
                  l.actionSnooze,
                ),
                AndroidNotificationAction(
                  NotificationActions.skip,
                  l.actionSkip,
                ),
              ]
            : null,
      ),
    );
  }

  /// "Залізо: 1 табл. · після їжі".
  static String itemLine(NotificationItem i, AppLocalizations l) => [
    '${i.name}: ${formatDoseWithUnit(i.dose, i.unit, l)}',
    if (i.meal != MealRelation.any) l.mealName(i.meal.name),
  ].join(' · ');

  /// "1 табл. · після їжі", for a medication's own notification.
  static String _doseLine(NotificationItem i, AppLocalizations l) => [
    formatDoseWithUnit(i.dose, i.unit, l),
    if (i.meal != MealRelation.any) l.mealName(i.meal.name),
  ].join(' · ');

  static String body(PlannedNotification n, AppLocalizations l) =>
      switch (n.role) {
        NotificationRole.summary => n.items.map((i) => i.name).join(', '),
        NotificationRole.child when n.items.length == 1 => _doseLine(
          n.items.single,
          l,
        ),
        _ => n.items.map((i) => itemLine(i, l)).join('\n'),
      };

  /// "Час прийняти ліки · 08:00".
  static String title(PlannedNotification n, AppLocalizations l) {
    final time = formatTime(n.doseTime.hour, n.doseTime.minute);
    return switch (n.kind) {
      NotificationKind.main => '${l.notifTitle} · $time',
      NotificationKind.followUp => '${l.notifTitleRepeat} · $time',
      NotificationKind.snooze => '${l.notifTitleSnoozed} · $time',
    };
  }

  /// A medication's own notification is titled with its name.
  static String _shownTitle(PlannedNotification n, AppLocalizations l) =>
      n.role == NotificationRole.child
      ? n.items.map((i) => i.name).join(', ')
      : title(n, l);

  static String payloadFor(PlannedNotification n) => NotificationPayload(
    doseTime: n.doseTime,
    doses: {for (final i in n.items) i.medicationId: i.dose},
  ).encode();

  Future<void> schedule(
    PlannedNotification n,
    AppLocalizations l, {
    AndroidScheduleMode? mode,
  }) async {
    await _plugin.zonedSchedule(
      id: n.id,
      scheduledDate: tz.TZDateTime.from(n.at, tz.local),
      notificationDetails: _details(
        l,
        n: n,
        largeIcon: n.role == NotificationRole.summary
            ? null
            : await _iconFor(n),
      ),
      androidScheduleMode:
          mode ??
          (await canScheduleExact()
              ? AndroidScheduleMode.exactAllowWhileIdle
              : AndroidScheduleMode.inexactAllowWhileIdle),
      title: _shownTitle(n, l),
      body: body(n, l),
      payload: payloadFor(n),
    );
  }

  final _iconCache = <(PillShape, int, int?), Uint8List>{};

  /// Drawing of the first medication in the reminder.
  Future<Uint8List?> _iconFor(PlannedNotification n) async {
    if (n.items.isEmpty) return null;
    final look = n.items.first.look;
    final key = (look.shape, look.color, look.color2);
    try {
      return _iconCache[key] ??= await renderPillPng(
        shape: look.shape,
        color: look.color,
        color2: look.color2,
      );
    } catch (e) {
      debugPrint('Pill icon failed: $e');
      return null;
    }
  }

  /// Brings pending reminders in line with [plan] and [stock], touching only
  /// the ones that changed since [previous] (what the last call returned).
  /// Returns the signatures of everything now scheduled, to pass next time.
  Future<Map<int, String>> replaceAll(
    List<PlannedNotification> plan,
    AppLocalizations l, {
    Map<DateTime, List<String>> stock = const {},
    Map<int, String> previous = const {},
  }) async {
    if (!supported) return const {};
    final mode = await canScheduleExact()
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
    final channel = channelIdFor(sound);
    final now = DateTime.now();
    final upcoming = [
      for (final n in plan)
        if (n.at.isAfter(now)) n,
    ]..sort((a, b) => a.at.compareTo(b.at));
    final stockTimes = [
      for (final at in stock.keys)
        if (at.isAfter(now)) at,
    ]..sort();
    final doses = {
      for (final n in upcoming.take(maxPending - min(stockTimes.length, 7)))
        n.id: n,
    };
    final restock = {
      for (final at in stockTimes.take(maxPending - doses.length))
        stockNotificationId(at): at,
    };
    final desired = <int, String>{
      for (final n in doses.values)
        n.id: stableHash(
          [
            n.at.millisecondsSinceEpoch,
            channel,
            mode.name,
            _shownTitle(n, l),
            body(n, l),
            payloadFor(n),
            n.role.name,
            n.timeoutAfter?.inMinutes,
            if (n.items.isNotEmpty) n.items.first.look.key,
          ].join('\u0000'),
        ),
      for (final MapEntry(key: id, value: at) in restock.entries)
        id: stableHash(
          [
            at.millisecondsSinceEpoch,
            l.stockBanner,
            ...stock[at]!,
          ].join('\u0000'),
        ),
    };
    final pending = {
      for (final r in await _plugin.pendingNotificationRequests()) r.id,
    };
    final diff = diffReminders(
      previous: previous,
      pending: pending,
      desired: desired,
    );
    if (diff.schedule.isNotEmpty) await _removeOldChannels();
    for (final id in diff.cancel) {
      await _plugin.cancel(id: id);
    }
    for (final id in diff.schedule) {
      if (doses[id] case final n?) {
        await schedule(n, l, mode: mode);
      } else if (restock[id] case final at?) {
        await _plugin.zonedSchedule(
          id: id,
          scheduledDate: tz.TZDateTime.from(at, tz.local),
          notificationDetails: NotificationDetails(
            android: AndroidNotificationDetails(
              _stockChannelId,
              l.notifStockChannelName,
              channelDescription: l.notifStockChannelDescription,
              category: AndroidNotificationCategory.reminder,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          title: l.stockBanner,
          body: stock[at]!.join(', '),
        );
      }
    }
    return desired;
  }

  /// Deletes reminder channels left over from earlier sound choices.
  Future<void> _removeOldChannels() async {
    try {
      final current = channelIdFor(sound);
      for (final c in await _android?.getNotificationChannels() ?? const []) {
        final isOurs = c.id == _defaultChannelId || c.id.startsWith('dose_');
        if (isOurs && c.id != current) {
          await _android?.deleteNotificationChannel(channelId: c.id);
        }
      }
    } catch (e) {
      debugPrint('Channel cleanup failed: $e');
    }
  }

  /// Removes shown and pending notifications for doses at [doseTime]: only
  /// those of [medicationIds] when given. The group summary goes once no
  /// other medication's notification for that time is left.
  Future<void> cancelForDose(
    DateTime doseTime, {
    Iterable<int>? medicationIds,
  }) async {
    if (!supported) return;
    if (medicationIds == null) {
      for (final id in notificationIdsFor(doseTime)) {
        await _plugin.cancel(id: id);
      }
      return;
    }
    final slots = {for (final m in medicationIds) slotFor(m)};
    for (final id in notificationIdsFor(doseTime, slots)) {
      await _plugin.cancel(id: id);
    }
    List<int> others;
    try {
      others = [
        for (final a in await _android?.getActiveNotifications() ?? const [])
          if (a.id case final id? when isChildIdFor(id, doseTime)) id,
      ];
    } catch (e) {
      debugPrint('Active notifications lookup failed: $e');
      return;
    }
    if (others.isEmpty) {
      for (final id in notificationIdsFor(doseTime, const [summarySlot])) {
        await _plugin.cancel(id: id);
      }
    }
  }

  Future<void> showTest(AppLocalizations l) async {
    if (!supported) return;
    await _plugin.show(
      id: 0,
      title: l.notifTitle,
      body: l.testNotificationBody,
      notificationDetails: _details(l, actions: false),
    );
  }

  Future<int> pendingCount() async {
    if (!supported) return 0;
    return (await _plugin.pendingNotificationRequests()).length;
  }
}
