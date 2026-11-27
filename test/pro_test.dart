import 'package:bady/data/database.dart';
import 'package:bady/providers.dart';
import 'package:bady/services/settings.dart';
import 'package:bady/services/store.dart';
import 'package:bady/ui/guide_widgets.dart';
import 'package:bady/ui/pro_screen.dart';
import 'package:bady/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  tearDown(() => Store.debugSellsPro = null);

  group('Prefs.pro', () {
    test('open in builds that do not sell Pro', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      expect(Prefs.pro(prefs), isTrue);
    });

    test('locked in the Play build until bought', () async {
      Store.debugSellsPro = true;
      SharedPreferences.setMockInitialValues({'sound': 'raw:bady_bell'});
      final prefs = await SharedPreferences.getInstance();
      expect(Prefs.pro(prefs), isFalse);
      // Without Pro the phone's default sound plays.
      expect(Prefs.soundKey(prefs), isNull);

      await prefs.setBool(Prefs.proUnlocked, true);
      expect(Prefs.pro(prefs), isTrue);
      expect(Prefs.soundKey(prefs), 'raw:bady_bell');
    });
  });

  testWidgets('the guide shows the Pro offer without Pro', (tester) async {
    Store.debugSellsPro = true;
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final db = AppDatabase(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          databaseProvider.overrideWithValue(db),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: GuideListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ProLockedBody), findsOneWidget);
    expect(find.text('Available in Dose Pro'), findsOneWidget);

    await tester.tap(find.text('About Dose Pro'));
    await tester.pumpAndSettle();
    expect(find.byType(ProScreen), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Restore purchase'), 200);
    expect(find.text('Buy Dose Pro'), findsOneWidget);
    expect(find.text('Restore purchase'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
    await db.close();
  });
}
