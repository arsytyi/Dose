import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../services/settings.dart';
import '../services/files.dart';
import '../services/sound_picker.dart';
import '../data/backup.dart';
import '../services/store.dart';
import '../services/update_check.dart';
import '../version.dart';
import 'update_ui.dart';
import 'guide_widgets.dart';
import 'theme.dart';
import 'widgets.dart';
import '../services/pro.dart';
import 'pro_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int? _pending;
  bool? _exact;

  Future<void> _refresh() async {
    final service = ref.read(notificationServiceProvider);
    final pending = await service.pendingCount();
    final exact = await service.canScheduleExact();
    if (mounted) {
      setState(() {
        _pending = pending;
        _exact = exact;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  bool get _autoUpdate =>
      ref.read(sharedPreferencesProvider).getBool(Prefs.autoUpdateCheck) ??
      true;

  Future<void> _checkUpdate() async {
    final l = AppLocalizations.of(context);
    if (!DeviceFiles.supported) return;
    final result = await UpdateCheck.check();
    if (!mounted) return;
    if (!result.checked) {
      _toast(
        (result.error ?? '').isEmpty
            ? l.updateUnavailable
            : '${l.updateUnavailable}\n(${result.error})',
      );
    } else if (result.update case final u?) {
      await showUpdateDialog(context, u);
    } else {
      _toast(l.updateNone);
    }
  }

  void _toast(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _export() async {
    final l = AppLocalizations.of(context);
    if (!DeviceFiles.supported) return;
    try {
      final now = DateTime.now();
      final json = await Backup.export(ref.read(databaseProvider), now: now);
      if (await DeviceFiles.save(Backup.fileName(now), json)) {
        _toast(l.backupSaved);
      }
    } catch (e) {
      _toast(l.backupFailed('$e'));
    }
  }

  Future<void> _import() async {
    final l = AppLocalizations.of(context);
    if (!DeviceFiles.supported) return;
    try {
      final json = await DeviceFiles.open();
      if (json == null || !mounted) return;
      final ({int medications, int schedules, int doseEvents}) info;
      try {
        info = Backup.inspect(json);
      } on BackupFormatException {
        _toast(l.backupInvalid);
        return;
      }
      final ok = await confirm(
        context,
        title: l.backupConfirmTitle,
        body: l.backupConfirmBody(
          info.medications,
          info.schedules,
          info.doseEvents,
        ),
        confirmLabel: l.backupRestore,
        cancelLabel: l.cancel,
      );
      if (!ok) return;
      await Backup.restore(ref.read(databaseProvider), json);
      await ref.read(reminderSyncProvider).resync();
      _toast(l.backupRestored);
    } catch (e) {
      _toast(l.backupFailed('$e'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final reminders = ref.watch(reminderSettingsProvider);
    final isPro = ref.watch(isProProvider);
    final themeMode = ref.watch(themeModeProvider);
    final service = ref.read(notificationServiceProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.navSettings)),
      body: ListView(
        children: [
          SectionTitle(l.settingsLanguage),
          RadioGroup<String>(
            groupValue: locale?.languageCode ?? '',
            onChanged: (code) => ref
                .read(localeProvider.notifier)
                .set(code == null || code.isEmpty ? null : Locale(code)),
            child: Column(
              children: [
                RadioListTile(value: '', title: Text(l.langSystem)),
                const RadioListTile(value: 'en', title: Text('English')),
                const RadioListTile(value: 'uk', title: Text('Українська')),
                const RadioListTile(value: 'ru', title: Text('Русский')),
                const RadioListTile(value: 'es', title: Text('Español')),
              ],
            ),
          ),
          SectionTitle(l.settingsAppearance),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.lg,
              vertical: Spacing.sm,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: const Icon(Icons.brightness_auto_outlined),
                    label: Text(l.themeSystem),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: const Icon(Icons.light_mode_outlined),
                    label: Text(l.themeLight),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: const Icon(Icons.dark_mode_outlined),
                    label: Text(l.themeDark),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).set(s.first),
              ),
            ),
          ),
          SectionTitle(l.settingsNotifications),
          ListTile(
            leading: const TonalIcon(Icons.music_note_outlined, index: 0),
            title: Text(l.settingsSound),
            subtitle: Text(soundName(reminders.sound, reminders.soundTitle, l)),
            trailing: Icon(
              isPro ? Icons.chevron_right : Icons.workspace_premium_outlined,
            ),
            onTap: isPro
                ? () => showModalBottomSheet<void>(
                    context: context,
                    showDragHandle: true,
                    isScrollControlled: true,
                    builder: (_) => const _SoundSheet(),
                  ).whenComplete(SoundPicker.stop)
                : () => showPro(context),
          ),
          ListTile(
            leading: const TonalIcon(
              Icons.notifications_active_outlined,
              index: 1,
            ),
            title: Text(l.grantNotifications),
            onTap: () async {
              await service.requestPermissions();
              await _refresh();
            },
          ),
          if (_exact == false)
            ListTile(
              leading: const TonalIcon(Icons.alarm_on_outlined, index: 2),
              title: Text(l.grantExactAlarms),
              subtitle: Text(l.grantExactAlarmsHint),
              onTap: () async {
                await service.requestExactAlarms();
                await ref.read(reminderSyncProvider).resync();
                await _refresh();
              },
            ),
          ListTile(
            leading: const TonalIcon(Icons.snooze, index: 3),
            title: Text(l.snoozeDuration),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  for (final m in Prefs.snoozeChoices)
                    ButtonSegment(value: m, label: Text(l.minutesShort(m))),
                ],
                selected: {reminders.snoozeMinutes},
                onSelectionChanged: (s) => ref
                    .read(reminderSettingsProvider.notifier)
                    .setSnooze(s.first),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const TonalIcon(Icons.repeat, index: 4),
            title: Text(l.repeatReminders),
            subtitle: Text(l.repeatRemindersHint),
            value: reminders.repeat,
            onChanged: (v) =>
                ref.read(reminderSettingsProvider.notifier).setRepeat(v),
          ),
          ListTile(
            leading: const TonalIcon(Icons.send_outlined, index: 5),
            title: Text(l.testNotification),
            subtitle: _pending == null
                ? null
                : Text(l.scheduledCount(_pending!)),
            onTap: () => service.showTest(l),
          ),
          SectionTitle(l.settingsData),
          ListTile(
            leading: const TonalIcon(Icons.save_alt, index: 6),
            title: Text(l.backupExport),
            subtitle: Text(l.backupExportHint),
            onTap: _export,
          ),
          ListTile(
            leading: const TonalIcon(Icons.settings_backup_restore, index: 7),
            title: Text(l.backupImport),
            subtitle: Text(l.backupImportHint),
            onTap: _import,
          ),
          SectionTitle(l.guideTitle),
          ListTile(
            leading: const TonalIcon(Icons.menu_book_outlined, index: 8),
            title: Text(l.guideAll),
            subtitle: Text(l.guideAllSubtitle),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const GuideListScreen()),
            ),
          ),
          SectionTitle(l.about),
          if (Store.sellsPro)
            ListTile(
              leading: const TonalIcon(
                Icons.workspace_premium_outlined,
                index: 9,
              ),
              title: Text(l.proTitle),
              subtitle: Text(
                isPro ? l.proSettingsActive : l.proSettingsInactive,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showPro(context),
            ),
          if (Store.selfUpdates) ...[
            ListTile(
              leading: const TonalIcon(Icons.system_update_outlined, index: 10),
              title: Text(l.updateCheck),
              subtitle: Text(l.updateCurrent(appVersion)),
              onTap: _checkUpdate,
            ),
            SwitchListTile(
              secondary: const TonalIcon(Icons.autorenew, index: 11),
              title: Text(l.updateAuto),
              subtitle: Text(l.updateAutoHint),
              value: _autoUpdate,
              onChanged: (v) async {
                await ref
                    .read(sharedPreferencesProvider)
                    .setBool(Prefs.autoUpdateCheck, v);
                setState(() {});
              },
            ),
          ],
          ListTile(
            leading: const TonalIcon(Icons.info_outline, index: 12),
            title: const Text('Dose $appVersion'),
            subtitle: Text(l.disclaimer),
          ),
        ],
      ),
    );
  }
}

/// Display name of a sound setting.
String soundName(String? sound, String? title, AppLocalizations l) {
  if (sound == null) return l.soundDefault;
  if (sound.startsWith('raw:')) return builtInSoundName(sound.substring(4), l);
  return title ?? l.soundCustom;
}

String builtInSoundName(String name, AppLocalizations l) => switch (name) {
  'bady_chime' => l.soundChime,
  'bady_bell' => l.soundBell,
  'bady_soft' => l.soundSoft,
  'bady_pulse' => l.soundPulse,
  _ => name,
};

/// Pick the reminder sound: phone default, a Dose sound, or any sound on
/// the phone (the Android picker also lets the user add their own file).
class _SoundSheet extends ConsumerWidget {
  const _SoundSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final settings = ref.watch(reminderSettingsProvider);
    final notifier = ref.read(reminderSettingsProvider.notifier);
    final current = settings.sound;
    final isCustom = current != null && !current.startsWith('raw:');

    Future<void> choose(String? sound) async {
      await notifier.setSound(sound);
      await SoundPicker.play(sound);
    }

    Widget preview(String? sound) => IconButton(
      tooltip: l.soundPreview,
      icon: const Icon(Icons.play_circle_outline),
      onPressed: () => SoundPicker.play(sound),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: Spacing.lg),
        child: RadioGroup<String>(
          groupValue: current ?? '',
          onChanged: (v) => choose(v == null || v.isEmpty ? null : v),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Text(
                  l.settingsSound,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              RadioListTile(
                value: '',
                title: Text(l.soundDefault),
                secondary: preview(null),
              ),
              SectionTitle(l.soundBuiltIn),
              for (final name in Prefs.builtInSounds)
                RadioListTile(
                  value: 'raw:$name',
                  title: Text(builtInSoundName(name, l)),
                  secondary: preview('raw:$name'),
                ),
              if (isCustom)
                RadioListTile(
                  value: current,
                  title: Text(settings.soundTitle ?? l.soundCustom),
                  secondary: preview(current),
                ),
              const Divider(),
              ListTile(
                leading: const TonalIcon(
                  Icons.library_music_outlined,
                  index: 13,
                ),
                title: Text(l.soundPickPhone),
                subtitle: Text(l.soundPickPhoneHint),
                onTap: () async {
                  final picked = await SoundPicker.pick(current);
                  if (picked != null) {
                    await notifier.setSound(picked.sound, title: picked.title);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
