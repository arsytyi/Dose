import 'dart:ui';

import 'package:bady/domain/dose_plan.dart';
import 'package:bady/domain/enums.dart';
import 'package:bady/l10n/app_localizations.dart';
import 'package:bady/services/notification_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('each sound gets its own stable channel', () {
    expect(NotificationService.channelIdFor(null), 'dose_reminders');
    final chime = NotificationService.channelIdFor('raw:bady_chime');
    expect(chime, startsWith('dose_'));
    expect(NotificationService.channelIdFor('raw:bady_chime'), chime);
    expect(NotificationService.channelIdFor('raw:bady_bell'), isNot(chime));
  });

  test('reminder text includes the meal note', () {
    final l = lookupAppLocalizations(const Locale('uk'));
    final n = PlannedNotification(
      doseTime: DateTime(2026, 11, 19, 9),
      at: DateTime(2026, 11, 19, 9),
      kind: NotificationKind.main,
      items: const [
        NotificationItem(
          medicationId: 1,
          name: 'Залізо',
          dose: 1,
          unit: '@tablet',
          meal: MealRelation.after,
        ),
        NotificationItem(medicationId: 2, name: 'D3', dose: 2, unit: ''),
      ],
    );
    expect(
      NotificationService.body(n, l),
      'Залізо: 1 ${l.unitShort('tablet')} · ${l.mealName('after')}\nD3: 2',
    );
  });

  test('a medication in a group is titled with its name', () {
    final l = lookupAppLocalizations(const Locale('uk'));
    const items = [
      NotificationItem(
        medicationId: 1,
        name: 'Залізо',
        dose: 1,
        unit: '@tablet',
        meal: MealRelation.after,
      ),
      NotificationItem(medicationId: 2, name: 'D3', dose: 2, unit: ''),
    ];
    final list = notificationsFor(
      doseTime: DateTime(2026, 11, 19, 9),
      at: DateTime(2026, 11, 19, 9),
      kind: NotificationKind.main,
      items: [...items],
    );
    final summary = list.first;
    expect(summary.role, NotificationRole.summary);
    expect(NotificationService.body(summary, l), 'D3, Залізо');
    expect(NotificationService.title(summary, l), '${l.notifTitle} · 09:00');
    final iron = list.firstWhere((n) => n.items.first.name == 'Залізо');
    expect(iron.role, NotificationRole.child);
    expect(
      NotificationService.body(iron, l),
      '1 ${l.unitShort('tablet')} · ${l.mealName('after')}',
    );
  });
}
