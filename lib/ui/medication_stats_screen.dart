import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/analysis.dart';
import '../domain/format.dart';
import '../domain/schedule_rule.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'analysis_widgets.dart';
import 'pill_icon.dart';
import 'stats_screen.dart';
import 'stock_widgets.dart';
import 'theme.dart';
import 'widgets.dart';

/// Everything the app knows about how one medication has been taken.
class MedicationStatsScreen extends ConsumerStatefulWidget {
  const MedicationStatsScreen({
    super.key,
    required this.medication,
    this.initialPeriod = 30,
  });

  final Medication medication;

  /// 7, 30, 90, or 0 for all of the history.
  final int initialPeriod;

  @override
  ConsumerState<MedicationStatsScreen> createState() =>
      _MedicationStatsScreenState();
}

class _MedicationStatsScreenState extends ConsumerState<MedicationStatsScreen> {
  late int _period = widget.initialPeriod;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = ref.watch(activePlanProvider);
    final log = ref.watch(yearLogProvider);
    final meds = ref.watch(allMedicationsProvider).value ?? const {};
    final m = meds[widget.medication.id] ?? widget.medication;
    final now = DateTime.now();
    final today = dateOnly(now);

    Widget body;
    if (plan.isLoading || log.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final schedules = [
        for (final p in plan.value ?? const <PlannedSchedule>[])
          if (p.medication.id == m.id) p,
      ];
      final logged = [
        for (final e in log.value ?? const <DoseEvent>[])
          if (e.medicationId == m.id) e.toLogged(),
      ];
      // From when the medication was added (or its first logged dose),
      // a year back at most.
      var start = dateOnly(m.createdAt);
      for (final e in logged) {
        final t = e.scheduledAt ?? e.actualAt;
        if (t != null && t.isBefore(start)) start = dateOnly(t);
      }
      for (final p in schedules) {
        final s = dateOnly(p.schedule.rule.startDate);
        if (s.isBefore(start) && !s.isAfter(today)) start = s;
      }
      final yearAgo = addDays(today, -365);
      if (start.isBefore(yearAgo)) start = yearAgo;
      final historyDays = daysBetween(start, today) + 1;

      final a = analyzeMedication(
        entries: toPlanEntries(schedules),
        logged: logged,
        now: now,
        historyStart: start,
        periodDays: _period == 0 ? historyDays : _period,
      );
      final rules = [for (final p in schedules) p.schedule.rule];

      body = ListView(
        padding: const EdgeInsets.only(bottom: Spacing.xl),
        children: [
          _Header(medication: m, rules: rules),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  for (final d in const [7, 30, 90])
                    ButtonSegment(value: d, label: Text(l.statsPeriod(d))),
                  ButtonSegment(value: 0, label: Text(l.periodAll)),
                ],
                selected: {_period},
                onSelectionChanged: (s) => setState(() => _period = s.first),
              ),
            ),
          ),
          if (a.isEmpty)
            Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Text(
                l.statsEmpty,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            )
          else ...[
            _AdherenceCard(analysis: a, medicationId: m.id),
            _DaysCard(analysis: a),
          ],
          SectionTitle(l.stockTitle),
          StockSection(medication: m),
          _CourseNeed(medication: m, rules: rules),
          if (!a.isEmpty) ...[
            const SizedBox(height: Spacing.sm),
            _Expandable(
              icon: Icons.bar_chart,
              title: l.chartsTitle,
              children: [_Charts(analysis: a)],
            ),
            _Expandable(
              icon: Icons.schedule,
              title: l.timingTitle,
              children: [_TimingView(timing: a.timing)],
            ),
            _AmountView(analysis: a, unit: m.unit),
          ],
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.medStatsTitle)),
      body: body,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.medication, required this.rules});

  final Medication medication;
  final List<ScheduleRule> rules;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final m = medication;
    final now = DateTime.now();
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    String course(ScheduleRule r) {
      final start = dateOnly(r.startDate);
      if (start.isAfter(dateOnly(now))) {
        return l.courseNotStarted(formatDate(start, locale));
      }
      final p = courseProgress(r, now);
      final last = r.lastDay;
      if (last == null || p.length == null) return l.courseOngoing(p.day);
      if (last.isBefore(dateOnly(now))) {
        return l.courseFinished(formatDate(last, locale));
      }
      return l.courseDayOf(p.day, p.length!, formatDate(last, locale));
    }

    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              PillAvatar(m, size: 52),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name, style: theme.textTheme.titleLarge),
                    Text(
                      [
                        m.kind.index == 0 ? l.kindMedicine : l.kindSupplement,
                        l.formName(m.form.name),
                        if (m.meal.index != 0) l.mealName(m.meal.name),
                      ].join(' · '),
                      style: muted,
                    ),
                    Text(
                      l.medStatsSince(formatDate(m.createdAt, locale)),
                      style: muted,
                    ),
                  ],
                ),
              ),
            ],
          ),
          for (final r in rules) ...[
            const SizedBox(height: Spacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.event_repeat,
                  size: 20,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        describeSchedule(r, l, locale, m.unit),
                        style: theme.textTheme.bodyLarge,
                      ),
                      Text(course(r), style: muted),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AdherenceCard extends StatelessWidget {
  const _AdherenceCard({required this.analysis, required this.medicationId});

  final MedicationAnalysis analysis;
  final int medicationId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onCard = scheme.onSecondaryContainer;
    final a = analysis;
    final pct = percentOf(a.counts.adherence);

    String? trend;
    IconData? trendIcon;
    if (a.previous case final p? when p.total > 0) {
      final diff = pct - percentOf(p.adherence);
      if (diff > 0) {
        trend = l.trendUp(diff);
        trendIcon = Icons.trending_up;
      } else if (diff < 0) {
        trend = l.trendDown(-diff);
        trendIcon = Icons.trending_down;
      } else {
        trend = l.trendSame;
        trendIcon = Icons.trending_flat;
      }
    }

    Widget streak(String label, int days) => Expanded(
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: onCard, size: 20),
          const SizedBox(width: Spacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(color: onCard),
                ),
                Text(
                  l.statsPeriod(days),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: onCard,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Card(
      margin: const EdgeInsets.all(Spacing.lg),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.statsAdherence,
              style: theme.textTheme.titleSmall?.copyWith(color: onCard),
            ),
            Text(
              '$pct%',
              style: theme.textTheme.displayMedium?.copyWith(
                color: onCard,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              l.statsSummary(a.periodDays, a.counts.taken, a.counts.total, pct),
              style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
            ),
            if (trend != null) ...[
              const SizedBox(height: Spacing.xs),
              Row(
                children: [
                  Icon(trendIcon, size: 18, color: onCard),
                  const SizedBox(width: Spacing.xs),
                  Expanded(
                    child: Text(
                      trend,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: onCard,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: Spacing.sm),
            OutcomeCounts(
              counts: a.counts,
              color: onCard,
              onOpen: (o) => showDoseListSheet(
                context,
                outcome: o,
                periodDays: a.periodDays,
                medicationId: medicationId,
              ),
            ),
            const SizedBox(height: Spacing.md),
            Row(
              children: [
                streak(l.streakCurrent, a.streaks.current),
                const SizedBox(width: Spacing.sm),
                streak(l.streakBest, a.streaks.best),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DaysCard extends StatelessWidget {
  const _DaysCard({required this.analysis});

  final MedicationAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final a = analysis;

    Widget item(IconData icon, String label, int value) => Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(height: Spacing.xs),
          Text(
            '$value',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l.daysTitle),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            children: [
              item(Icons.check_circle, l.daysFull, a.fullDays),
              item(Icons.timelapse, l.daysPartial, a.partialDays),
              item(Icons.cancel_outlined, l.daysNone, a.emptyDays),
            ],
          ),
        ),
      ],
    );
  }
}

/// How much is still needed to finish a course with an end date.
class _CourseNeed extends StatelessWidget {
  const _CourseNeed({required this.medication, required this.rules});

  final Medication medication;
  final List<ScheduleRule> rules;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    if (rules.isEmpty) return const SizedBox.shrink();
    final remaining = remainingCourseAmount(rules, DateTime.now());
    if (remaining == null || remaining <= 0) return const SizedBox.shrink();
    final packs = packsToFinish(
      remaining: remaining,
      stock: medication.stock,
      packSize: medication.packSize,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.sm, Spacing.lg, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l.courseRemaining(
              formatDoseWithUnit(remaining, medication.unit, l),
            ),
            style: theme.textTheme.bodyMedium,
          ),
          if (packs != null)
            Text(
              l.packsToFinish(packs),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}

class _Expandable extends StatelessWidget {
  const _Expandable({
    required this.icon,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    leading: Icon(icon),
    title: Text(title),
    shape: const Border(),
    collapsedShape: const Border(),
    childrenPadding: const EdgeInsets.only(bottom: Spacing.md),
    expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
    children: children,
  );
}

class _Charts extends StatelessWidget {
  const _Charts({required this.analysis});

  final MedicationAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final a = analysis;
    final names = weekdayNames(locale);

    // The weekday with the lowest adherence, if it stands out.
    int? worst;
    for (final e in a.byWeekday.entries) {
      final v = e.value.adherence;
      if (v == null || v >= 1) continue;
      if (worst == null || v < a.byWeekday[worst]!.adherence!) worst = e.key;
    }
    final times = a.byTime.keys.toList()..sort();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DailyChart(
          days: a.days,
          onOpenDay: (day) => openDayAnalysis(context, day),
        ),
        SectionTitle(l.byWeekday),
        if (worst != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text(
              l.weekdayWorst(names[worst - 1]),
              style: theme.textTheme.bodyMedium,
            ),
          ),
        for (var d = 1; d <= 7; d++)
          if (a.byWeekday[d] case final c?)
            PercentRow(label: names[d - 1], counts: c),
        if (times.isNotEmpty) ...[
          SectionTitle(l.byDoseTime),
          for (final t in times)
            PercentRow(
              label: formatTime(t ~/ 60, t % 60),
              counts: a.byTime[t]!,
            ),
        ],
      ],
    );
  }
}

class _TimingView extends StatelessWidget {
  const _TimingView({required this.timing});

  final Timing timing;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final t = timing;
    if (t.count == 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: Text(l.timingNone, style: theme.textTheme.bodyMedium),
      );
    }

    Widget row(String label, int n) => ListTile(
      dense: true,
      title: Text(label, style: theme.textTheme.bodyLarge),
      trailing: Text(
        '$n · ${(n * 100 / t.count).round()}%',
        style: theme.textTheme.titleSmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Text(
            l.timingAverage(averageDelayText(t.averageMinutes!.round(), l)),
            style: theme.textTheme.titleMedium,
          ),
        ),
        row(l.timingOnTime, t.onTime),
        row(l.timingEarly, t.early),
        row(l.timingLate, t.late),
        row(l.timingVeryLate, t.veryLate),
        if (t.maxLateMinutes case final m?)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text(
              l.timingMax(formatMinutes(m, l)),
              style: theme.textTheme.bodyMedium,
            ),
          ),
      ],
    );
  }
}

class _AmountView extends StatelessWidget {
  const _AmountView({required this.analysis, required this.unit});

  final MedicationAnalysis analysis;
  final String unit;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = analysis;
    String amount(double v) => formatDoseWithUnit(v, unit, l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l.amountTitle),
        ListTile(
          title: Text(l.amountPeriod),
          subtitle: Text(l.statsPeriod(a.periodDays)),
          trailing: Text(amount(a.takenAmount)),
        ),
        ListTile(
          title: Text(l.amountPerDay),
          trailing: Text(amount(_round(a.averagePerDay))),
        ),
        ListTile(
          title: Text(l.amountAll),
          subtitle: Text(l.dosesCount(a.takenCountAll)),
          trailing: Text(amount(a.takenAmountAll)),
        ),
      ],
    );
  }
}

double _round(double v) => (v * 10).round() / 10;
