import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_localizations.dart';

/// Preference keys and defaults shared by the UI and the background isolate.
abstract final class Prefs {
  static const locale = 'locale';
  static const snoozeMinutes = 'snoozeMinutes';
  static const repeatReminders = 'repeatReminders';
  static const themeMode = 'themeMode';
  static const autoUpdateCheck = 'autoUpdateCheck';
  static const lastUpdateCheck = 'lastUpdateCheck';

  /// JSON map of notification id to signature, from the last reminder sync.
  static const scheduledReminders = 'scheduledReminders';

  /// Notification sound: null for the phone default, `raw:<name>` for a
  /// sound bundled with the app, or a content URI picked on the phone.
  static const sound = 'sound';
  static const soundTitle = 'soundTitle';

  /// Sounds in android/app/src/main/res/raw.
  static const builtInSounds = [
    'bady_chime',
    'bady_bell',
    'bady_soft',
    'bady_pulse',
  ];

  static const snoozeChoices = [5, 10, 15, 30];
  static const defaultSnooze = 10;
  static const followUpMinutes = [15, 30];

  static int snooze(SharedPreferences p) =>
      p.getInt(snoozeMinutes) ?? defaultSnooze;

  static bool repeat(SharedPreferences p) => p.getBool(repeatReminders) ?? true;

  static String? soundKey(SharedPreferences p) => p.getString(sound);

  static Locale? chosenLocale(SharedPreferences p) {
    final code = p.getString(locale);
    return code == null ? null : Locale(code);
  }
}

/// The language actually in use (setting, else system, else English).
Locale effectiveLocale(Locale? chosen) {
  if (chosen != null) return chosen;
  for (final l in PlatformDispatcher.instance.locales) {
    if (AppLocalizations.supportedLocales.any(
      (s) => s.languageCode == l.languageCode,
    )) {
      return Locale(l.languageCode);
    }
  }
  return const Locale('en');
}

AppLocalizations localizationsFor(SharedPreferences p) =>
    lookupAppLocalizations(effectiveLocale(Prefs.chosenLocale(p)));
