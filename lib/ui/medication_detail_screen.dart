import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/format.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'medication_form_screen.dart';
import 'medication_stats_screen.dart';
import 'schedule_editor_screen.dart';
import 'compat_widgets.dart';
import 'guide_widgets.dart';
import 'stock_widgets.dart';
import 'pill_icon.dart';
import 'theme.dart';
import 'widgets.dart';

class MedicationDetailScreen extends ConsumerWidget {
  const MedicationDetailScreen({super.key, required this.id});

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final med = ref.watch(medicationProvider(id));
    final schedules = ref.watch(schedulesProvider(id)).value ?? const [];
    final m = med.value;
    if (m == null) {
      return Scaffold(
        appBar: AppBar(),
        body: med.isLoading
            ? const Center(child: CircularProgressIndicator())
            : const SizedBox.shrink(),
      );
    }
    final db = ref.read(databaseProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    Future<void> onMenu(String action) async {
      switch (action) {
        case 'archive':
          await db.updateMedication(
            m.id,
            MedicationsCompanion(archived: Value(!m.archived)),
          );
        case 'delete':
          final ok = await confirm(
            context,
            title: l.deleteMedicationTitle,
            body: l.deleteMedicationBody,
            confirmLabel: l.delete,
            cancelLabel: l.cancel,
          );
          if (ok && context.mounted) {
            Navigator.of(context).pop();
            await db.deleteMedication(m.id);
          }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(m.name),
        actions: [
          IconButton(
            tooltip: l.edit,
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MedicationFormScreen(existing: m),
              ),
            ),
          ),
          PopupMenuButton<String>(
            onSelected: onMenu,
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'archive',
                child: Text(m.archived ? l.unarchive : l.archive),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  l.delete,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ScheduleEditorScreen(medication: m),
          ),
        ),
        icon: const Icon(Icons.add_alarm),
        label: Text(l.addSchedule),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: Spacing.fabClearance),
        children: [
          ListTile(
            leading: PillAvatar(m, size: 52),
            title: Text(
              [
                m.kind.index == 0 ? l.kindMedicine : l.kindSupplement,
                l.formName(m.form.name),
              ].join(' · '),
            ),
            subtitle: m.meal.index == 0 ? null : Text(l.mealName(m.meal.name)),
          ),
          ListTile(
            leading: const Icon(Icons.insights_outlined),
            title: Text(l.medStatsTitle),
            subtitle: Text(l.medStatsOpenHint),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MedicationStatsScreen(medication: m),
              ),
            ),
          ),
          SectionTitle(l.stockTitle),
          StockSection(medication: m),
          CompatSection(medicationId: m.id),
          GuideSection(medication: m),
          if (m.notes.isNotEmpty) ...[
            SectionTitle(l.notes),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SelectableText(m.notes),
            ),
          ],
          SectionTitle(l.schedules),
          if (schedules.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                l.noSchedules,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          for (final s in schedules)
            ListTile(
              leading: Icon(
                s.active ? Icons.alarm : Icons.alarm_off,
                color: s.active
                    ? null
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              title: Text(describeSchedule(s.rule, l, locale, m.unit)),
              subtitle: s.active ? null : Text(l.schedulePaused),
              trailing: Switch(
                value: s.active,
                onChanged: (v) => db.setScheduleActive(s.id, v),
              ),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      ScheduleEditorScreen(medication: m, existing: s),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
