import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/analysis.dart';
import '../domain/dose_plan.dart';
import '../domain/format.dart';
import '../domain/stats.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'day_analysis_screen.dart';
import 'pill_icon.dart';
import 'stats_screen.dart';
import 'theme.dart';
import 'accents.dart';
import 'today_screen.dart';
import 'widgets.dart';

int percentOf(double? v) => ((v ?? 0) * 100).round();

/// "40 хв", "1 год 5 хв".
String formatMinutes(int minutes, AppLocalizations l) {
  final m = minutes.abs();
  if (m < 60) return l.durationMinutes(m);
  return m % 60 == 0
      ? l.durationHours(m ~/ 60)
      : l.durationHoursMinutes(m ~/ 60, m % 60);
}

/// "на 40 хв пізніше" for a taken dose; null when its time is unknown.
String? delayText(DoseSlot s, AppLocalizations l) {
  final d = delayMinutes(s);
  if (d == null) return null;
  if (d.abs() <= Timing.tolerance) return l.delayOnTime;
  return d > 0
      ? l.delayLate(formatMinutes(d, l))
      : l.delayEarly(formatMinutes(d, l));
}

/// "вчасно" / "на 10 хв пізніше" for an average offset in minutes.
String averageDelayText(int minutes, AppLocalizations l) {
  if (minutes.abs() <= Timing.tolerance) return l.delayOnTime;
  return minutes > 0
      ? l.delayLate(formatMinutes(minutes, l))
      : l.delayEarly(formatMinutes(minutes, l));
}

String outcomeLabel(DoseOutcome o, AppLocalizations l) => switch (o) {
  DoseOutcome.taken => l.statsTaken,
  DoseOutcome.skipped => l.statsSkipped,
  DoseOutcome.missed => l.statsMissed,
};

IconData outcomeIcon(DoseOutcome o) => switch (o) {
  DoseOutcome.taken => Icons.check_circle_outline,
  DoseOutcome.skipped => Icons.block,
  DoseOutcome.missed => Icons.error_outline,
};

/// One dose in an analysis list: medication, planned time, status and how
/// far off the planned time it was taken.
class DoseLogTile extends StatelessWidget {
  const DoseLogTile({
    super.key,
    required this.slot,
    required this.medication,
    this.onTap,
  });

  final DoseSlot slot;
  final Medication medication;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = slot.scheduledAt ?? slot.time;
    final delay = delayText(slot, l);
    return ListTile(
      onTap: onTap,
      leading: PillAvatar(medication),
      title: Text(medication.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            [
              if (slot.scheduledAt != null)
                l.plannedAt(formatTime(t.hour, t.minute))
              else
                l.unscheduled,
              formatDoseWithUnit(slot.dose, medication.unit, l),
            ].join(' · '),
          ),
          const SizedBox(height: Spacing.xs),
          Wrap(
            spacing: Spacing.sm,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(slot: slot),
              if (delay != null)
                Text(
                  delay,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
      trailing: onTap == null ? null : const Icon(Icons.chevron_right),
    );
  }
}

/// Lists the doses with [outcome] over the last [periodDays] days, grouped
/// by day, optionally for one medication. Tapping a dose opens its day.
Future<void> showDoseListSheet(
  BuildContext context, {
  required DoseOutcome outcome,
  required int periodDays,
  int? medicationId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, controller) => _DoseList(
        controller: controller,
        outcome: outcome,
        periodDays: periodDays,
        medicationId: medicationId,
      ),
    ),
  );
}

class _DoseList extends ConsumerWidget {
  const _DoseList({
    required this.controller,
    required this.outcome,
    required this.periodDays,
    required this.medicationId,
  });

  final ScrollController controller;
  final DoseOutcome outcome;
  final int periodDays;
  final int? medicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final plan = ref.watch(activePlanProvider).value ?? const [];
    final log = ref.watch(yearLogProvider).value ?? const <DoseEvent>[];
    final meds = ref.watch(allMedicationsProvider).value ?? const {};
    final id = medicationId;

    final doses = dosesWithOutcome(
      entries: toPlanEntries([
        for (final p in plan)
          if (id == null || p.medication.id == id) p,
      ]),
      logged: [
        for (final e in log)
          if (id == null || e.medicationId == id) e.toLogged(),
      ],
      now: DateTime.now(),
      periodDays: periodDays,
      outcome: outcome,
    ).where((s) => meds.containsKey(s.medicationId)).toList();

    final byDay = <DateTime, List<DoseSlot>>{};
    for (final s in doses) {
      byDay
          .putIfAbsent(
            DateTime(s.time.year, s.time.month, s.time.day),
            () => [],
          )
          .add(s);
    }
    final dayFmt = DateFormat.MMMMEEEEd(locale);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.sm,
          ),
          child: Row(
            children: [
              Icon(outcomeIcon(outcome), color: theme.colorScheme.primary),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  l.listTitle(
                    outcomeLabel(outcome, l),
                    l.statsPeriod(periodDays),
                  ),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Text(
                '${doses.length}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (doses.isEmpty)
          Padding(
            padding: const EdgeInsets.all(Spacing.xl),
            child: Text(
              l.noDoses,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
        for (final e in byDay.entries) ...[
          SectionTitle(toBeginningOfSentenceCase(dayFmt.format(e.key))),
          for (final s in e.value)
            DoseLogTile(
              slot: s,
              medication: meds[s.medicationId]!,
              onTap: () {
                Navigator.of(context).pop();
                openDayAnalysis(context, e.key);
              },
            ),
        ],
      ],
    );
  }
}

/// Opens the analysis of [day].
void openDayAnalysis(BuildContext context, DateTime day) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => DayAnalysisScreen(day: day)));
}

/// Taken / skipped / missed counts; each one opens its list when
/// [onOpen] is given.
class OutcomeCounts extends StatelessWidget {
  const OutcomeCounts({
    super.key,
    required this.counts,
    required this.color,
    this.onOpen,
    this.iconColors,
  });

  final DoseCounts counts;
  final Color color;
  final List<Color>? iconColors;
  final void Function(DoseOutcome outcome)? onOpen;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);

    Widget item(DoseOutcome o, int value) {
      final label = outcomeLabel(o, l);
      final content = ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 72),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                outcomeIcon(o),
                size: accentsOn ? 24 : 20,
                color: iconColors?[o.index] ?? color,
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                '$value',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: color,
                      ),
                    ),
                  ),
                  if (onOpen != null)
                    Icon(Icons.chevron_right, size: 16, color: color),
                ],
              ),
            ],
          ),
        ),
      );
      return Expanded(
        child: onOpen == null
            ? content
            : Semantics(
                button: true,
                label: '$label: $value',
                hint: l.statsCountHint,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(Radii.card),
                  onTap: () => onOpen!(o),
                  child: content,
                ),
              ),
      );
    }

    return Row(
      children: [
        item(DoseOutcome.taken, counts.taken),
        item(DoseOutcome.skipped, counts.skipped),
        item(DoseOutcome.missed, counts.missed),
      ],
    );
  }
}

/// A label with a progress bar and "85% · 17 з 20".
class PercentRow extends StatelessWidget {
  const PercentRow({
    super.key,
    required this.label,
    required this.counts,
    this.leading,
    this.onTap,
    this.barColor,
  });

  final Color? barColor;
  final String label;
  final DoseCounts counts;
  final Widget? leading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final pct = percentOf(counts.adherence);
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: Text(label),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: Spacing.xs),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: counts.adherence ?? 0,
            minHeight: 8,
            color:
                barColor ??
                (accentVariant == 'a'
                    ? Accents(context).byFraction(counts.adherence)
                    : null),
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                counts.total == 0 ? '—' : '$pct%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              Text(
                l.statsOfTotal(counts.taken, counts.total),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (onTap != null) ...[
            const SizedBox(width: Spacing.xs),
            const Icon(Icons.chevron_right),
          ],
        ],
      ),
    );
  }
}
