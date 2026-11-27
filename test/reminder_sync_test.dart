import 'package:bady/data/database.dart';
import 'package:bady/domain/dose_plan.dart';
import 'package:bady/l10n/app_localizations.dart';
import 'package:bady/providers.dart';
import 'package:bady/services/notification_service.dart';
import 'package:bady/services/settings.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Records how reminder syncs reach the notification plugin.
class _FakeService extends NotificationService {
  int running = 0;
  int maxRunning = 0;
  int syncs = 0;
  int clears = 0;
  final previousSeen = <Map<int, String>>[];

  @override
  Future<void> cancelAllPending() async => clears++;

  @override
  Future<Map<int, String>> replaceAll(
    List<PlannedNotification> plan,
    AppLocalizations l, {
    Map<DateTime, List<String>> stock = const {},
    Map<int, String> previous = const {},
  }) async {
    running++;
    if (running > maxRunning) maxRunning = running;
    syncs++;
    previousSeen.add(previous);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    running--;
    return {1: 'sig'};
  }
}

void main() {
  late AppDatabase db;
  late _FakeService service;
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      // What v0.13.0 left: signatures of reminders stored with picture bytes.
      Prefs.scheduledReminders: '{"7":"old"}',
    });
    db = AppDatabase(NativeDatabase.memory());
    service = _FakeService();
    container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
        databaseProvider.overrideWithValue(db),
        notificationServiceProvider.overrideWithValue(service),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('overlapping syncs run one at a time and coalesce', () async {
    final sync = container.read(reminderSyncProvider);
    await Future.wait([sync.resync(), sync.resync(), sync.resync()]);
    expect(service.maxRunning, 1);
    // The first call plus one more pass for the calls made meanwhile.
    expect(service.syncs, 2);
  });

  test('old reminder store is cleared once, then syncs diff again', () async {
    final sync = container.read(reminderSyncProvider);
    await sync.resync();
    expect(service.clears, 1);
    expect(service.previousSeen.first, isEmpty);

    await sync.resync();
    expect(service.clears, 1);
    expect(service.previousSeen.last, {1: 'sig'});
  });
}
