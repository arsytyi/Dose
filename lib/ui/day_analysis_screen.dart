import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/analysis.dart';
import '../domain/dose_plan.dart';
import '../domain/schedule_rule.dart';
import '../domain/stats.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'analysis_widgets.dart';
import 'dose_sheet.dart';
import 'medication_stats_screen.dart';
import 'pill_icon.dart';
import 'theme.dart';
import 'widgets.dart';

/// Everything about one day: what was due, what was taken and when, and
/// how each medication did.
class DayAnalysisScreen extends ConsumerStatefulWidget {
  const DayAnalysisScreen({super.key, required this.day});

  final DateTime day;

  @override
  ConsumerState<DayAnalysisScreen> createState() => _DayAnalysisScreenState();
}

class _DayAnalysisScreenState extends ConsumerState<DayAnalysisScreen> {
  late DateTime _day = dateOnly(widget.day);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final plan = ref.watch(activePlanProvider);
    final events = ref.watch(dayEventsProvider(_day));
    final meds = ref.watch(allMedicationsProvider).value ?? const {};
    final now = DateTime.now();
    final isFuture = _day.isAfter(dateOnly(now));

    Widget body;
    if (plan.isLoading || events.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final slots = buildDay(
        entries: toPlanEntries(plan.value ?? const []),
        logged: (events.value ?? const []).map((e) => e.toLogged()),
        day: _day,
        now: now,
      ).where((s) => meds.containsKey(s.medicationId)).toList();

      if (slots.isEmpty) {
        body = EmptyState(
          icon: Icons.event_available_outlined,
          title: l.dayEmpty,
        );
      } else {
        var counts = const DoseCounts();
        final perMed = <int, DoseCounts>{};
        var upcoming = 0;
        for (final s in slots) {
          final o = outcomeOf(s, now);
          if (o == null) upcoming++;
          final c = countsOf(o);
          counts = counts + c;
          perMed[s.medicationId] =
              (perMed[s.medicationId] ?? const DoseCounts()) + c;
        }
        final timing = timingOf(slots);
        final onCard = scheme.onSecondaryContainer;

        body = ListView(
          padding: const EdgeInsets.only(bottom: Spacing.xl),
          children: [
            Card(
              margin: const EdgeInsets.all(Spacing.lg),
              color: scheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(Spacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.statsAdherence,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: onCard,
                      ),
                    ),
                    Text(
                      counts.total == 0
                          ? '—'
                          : '${percentOf(counts.adherence)}%',
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: onCard,
                        fontWeight: FontWeight.w700,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    Text(
                      [
                        l.statsOfTotal(counts.taken, counts.total),
                        if (upcoming > 0) '${l.dayUpcoming}: $upcoming',
                        if (timing.averageMinutes case final avg?)
                          l.timingAverage(averageDelayText(avg.round(), l)),
                      ].join(' · '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onCard,
                      ),
                    ),
                    const SizedBox(height: Spacing.sm),
                    OutcomeCounts(counts: counts, color: onCard),
                  ],
                ),
              ),
            ),
            SectionTitle(l.dayDoses),
            for (final s in slots)
              DoseLogTile(
                slot: s,
                medication: meds[s.medicationId]!,
                onTap: isFuture ? null : () => showDoseSheet(context, ref, [s]),
              ),
            SectionTitle(l.statsByMedication),
            for (final e in perMed.entries)
              PercentRow(
                leading: PillAvatar(meds[e.key]!),
                label: meds[e.key]!.name,
                counts: e.value,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        MedicationStatsScreen(medication: meds[e.key]!),
                  ),
                ),
              ),
          ],
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          toBeginningOfSentenceCase(DateFormat.MMMMEEEEd(locale).format(_day)),
        ),
        actions: [
          IconButton(
            tooltip: l.prevDay,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => setState(() => _day = addDays(_day, -1)),
          ),
          IconButton(
            tooltip: l.nextDay,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => setState(() => _day = addDays(_day, 1)),
          ),
        ],
      ),
      body: body,
    );
  }
}
