import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/schedule_rule.dart';
import '../domain/stats.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'analysis_widgets.dart';
import 'history_screen.dart';
import 'medication_stats_screen.dart';
import 'pill_icon.dart';
import 'theme.dart';
import 'widgets.dart';

/// Dose log for the last year, for statistics and history.
final yearLogProvider = StreamProvider<List<DoseEvent>>((ref) {
  final now = DateTime.now();
  return ref
      .watch(databaseProvider)
      .watchEventsBetween(
        addDays(dateOnly(now), -366),
        addDays(dateOnly(now), 1),
      );
});

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen> {
  int _period = 7;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final plan = ref.watch(activePlanProvider);
    final log = ref.watch(yearLogProvider);
    final meds = ref.watch(allMedicationsProvider).value ?? const {};

    Widget body;
    if (plan.isLoading || log.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final stats = computeStats(
        entries: toPlanEntries(plan.value ?? const []),
        logged: [
          for (final e in log.value ?? const <DoseEvent>[]) e.toLogged(),
        ],
        now: DateTime.now(),
        periodDays: _period,
      );
      body = stats.isEmpty
          ? EmptyState(icon: Icons.insights_outlined, title: l.statsEmpty)
          : ListView(
              padding: const EdgeInsets.only(bottom: Spacing.xl),
              children: [
                _SummaryCard(stats: stats, period: _period),
                SectionTitle(l.statsByDay),
                DailyChart(
                  days: stats.days,
                  onOpenDay: (day) => openDayAnalysis(context, day),
                ),
                SectionTitle(l.statsByMedication),
                for (final e
                    in stats.byMedication.entries.toList()..sort(
                      (a, b) => (meds[a.key]?.name ?? '').compareTo(
                        meds[b.key]?.name ?? '',
                      ),
                    ))
                  if (meds[e.key] case final m?)
                    PercentRow(
                      leading: PillAvatar(m),
                      label: m.name,
                      counts: e.value,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => MedicationStatsScreen(
                            medication: m,
                            initialPeriod: _period,
                          ),
                        ),
                      ),
                    ),
              ],
            );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.navStats),
        actions: [
          IconButton(
            tooltip: l.historyTitle,
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const HistoryScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.sm,
              Spacing.lg,
              0,
            ),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                showSelectedIcon: false,
                segments: [
                  for (final d in const [7, 30, 90])
                    ButtonSegment(value: d, label: Text(l.statsPeriod(d))),
                ],
                selected: {_period},
                onSelectionChanged: (s) => setState(() => _period = s.first),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.stats, required this.period});

  final Stats stats;
  final int period;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final t = stats.total;
    final onCard = scheme.onSecondaryContainer;

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
              '${percentOf(t.adherence)}%',
              style: theme.textTheme.displayMedium?.copyWith(
                color: onCard,
                fontWeight: FontWeight.w700,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            Text(
              l.statsSummary(period, t.taken, t.total, percentOf(t.adherence)),
              style: theme.textTheme.bodyMedium?.copyWith(color: onCard),
            ),
            const SizedBox(height: Spacing.sm),
            OutcomeCounts(
              counts: t,
              color: onCard,
              onOpen: (o) =>
                  showDoseListSheet(context, outcome: o, periodDays: period),
            ),
            if (stats.streak > 0) ...[
              const SizedBox(height: Spacing.lg),
              Row(
                children: [
                  Icon(Icons.local_fire_department, color: onCard),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      l.statsStreak(stats.streak),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: onCard,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One bar per day: share of due doses taken. Tapping a bar selects the
/// day; [onOpenDay] opens it in detail. (Bars are too thin over 90 days to
/// open on a single tap without mistakes.)
class DailyChart extends StatefulWidget {
  const DailyChart({super.key, required this.days, this.onOpenDay});

  final List<DayStat> days;
  final ValueChanged<DateTime>? onOpenDay;

  @override
  State<DailyChart> createState() => _DailyChartState();
}

class _DailyChartState extends State<DailyChart> {
  int? _selected;

  @override
  void didUpdateWidget(DailyChart old) {
    super.didUpdateWidget(old);
    if (old.days.length != widget.days.length) _selected = null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final days = widget.days;
    final selected = _selected ?? days.length - 1;
    final sel = days[selected];
    final dateFmt = DateFormat.MMMEd(locale);
    final short = DateFormat.Md(locale);
    const chartHeight = 140.0;

    String detail(DayStat d) => d.counts.total == 0
        ? '${dateFmt.format(d.day)}: —'
        : '${dateFmt.format(d.day)}: '
              '${l.statsOfTotal(d.counts.taken, d.counts.total)} '
              '(${percentOf(d.counts.adherence)}%)';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Readout of the selected day (also announced to screen readers).
          Row(
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  child: Text(
                    detail(sel),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              if (widget.onOpenDay case final open?)
                TextButton.icon(
                  onPressed: () => open(sel.day),
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(l.statsOpenDay),
                ),
            ],
          ),
          Text(
            l.statsChartHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          SizedBox(
            height: chartHeight,
            child: Stack(
              children: [
                // Recessive gridlines at 0, 50 and 100%.
                for (final f in const [0.0, 0.5, 1.0])
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: f * (chartHeight - 1),
                    child: Container(
                      height: 1,
                      color: scheme.outlineVariant.withValues(
                        alpha: f == 0 ? 1 : 0.5,
                      ),
                    ),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final (i, d) in days.indexed)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == selected,
                          label: detail(d),
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => setState(() => _selected = i),
                            child: SizedBox(
                              height: chartHeight,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: days.length > 31 ? 0.5 : 1,
                                  ),
                                  child: _Bar(
                                    fraction: d.counts.adherence,
                                    height: chartHeight,
                                    selected: i == selected,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in [days.first, days[days.length ~/ 2], days.last])
                Text(
                  short.format(d.day),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.fraction,
    required this.height,
    required this.selected,
  });

  /// Null when nothing was due that day.
  final double? fraction;
  final double height;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (fraction == null) {
      return Container(
        height: 4,
        decoration: BoxDecoration(
          color: scheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      );
    }
    final h = (fraction! * (height - 2)).clamp(4.0, height);
    return Container(
      height: h,
      decoration: BoxDecoration(
        color: selected
            ? scheme.primary
            : scheme.primary.withValues(alpha: 0.55),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }
}
