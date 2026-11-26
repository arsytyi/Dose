import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/format.dart';
import '../domain/schedule_rule.dart';
import '../domain/stats.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'analysis_widgets.dart';
import 'stats_screen.dart';
import 'theme.dart';

/// Month calendar: each day shows the share of due doses taken.
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final plan = ref.watch(activePlanProvider);
    final log = ref.watch(yearLogProvider);
    final now = DateTime.now();
    final today = dateOnly(now);
    final firstMonth = DateTime(now.year - 1, now.month);
    final thisMonth = DateTime(now.year, now.month);

    final byDay = <DateTime, DayStat>{};
    if (plan.hasValue && log.hasValue) {
      final stats = computeStats(
        entries: toPlanEntries(plan.value!),
        logged: [for (final e in log.value!) e.toLogged()],
        now: now,
        periodDays: 366,
        streakLookbackDays: 0,
      );
      for (final d in stats.days) {
        byDay[d.day] = d;
      }
    }

    // Monday-first grid with leading blanks.
    final first = _month;
    final daysInMonth = DateTime(first.year, first.month + 1, 0).day;
    final lead = first.weekday - 1;
    final names = weekdayNames(locale);

    return Scaffold(
      appBar: AppBar(title: Text(l.historyTitle)),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.lg),
        children: [
          Row(
            children: [
              IconButton(
                tooltip: l.prevMonth,
                icon: const Icon(Icons.chevron_left),
                onPressed: _month.isAfter(firstMonth)
                    ? () => setState(
                        () => _month = DateTime(_month.year, _month.month - 1),
                      )
                    : null,
              ),
              Expanded(
                child: Text(
                  toBeginningOfSentenceCase(
                    DateFormat.yMMMM(locale).format(_month),
                  ),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                tooltip: l.nextMonth,
                icon: const Icon(Icons.chevron_right),
                onPressed: _month.isBefore(thisMonth)
                    ? () => setState(
                        () => _month = DateTime(_month.year, _month.month + 1),
                      )
                    : null,
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              for (final n in names)
                Expanded(
                  child: Text(
                    n,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Spacing.xs,
            crossAxisSpacing: Spacing.xs,
            childAspectRatio: 0.8,
            children: [
              for (var i = 0; i < lead; i++) const SizedBox.shrink(),
              for (var d = 1; d <= daysInMonth; d++)
                _DayCell(
                  day: DateTime(first.year, first.month, d),
                  stat: byDay[DateTime(first.year, first.month, d)],
                  isToday: DateTime(first.year, first.month, d) == today,
                  isFuture: DateTime(first.year, first.month, d).isAfter(today),
                ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Text(
            l.historyHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayCell extends ConsumerWidget {
  const _DayCell({
    required this.day,
    required this.stat,
    required this.isToday,
    required this.isFuture,
  });

  final DateTime day;
  final DayStat? stat;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final adherence = stat?.counts.adherence;
    final percent = adherence == null ? null : (adherence * 100).round();
    // One hue, light to dark: more taken, stronger color.
    final fill = adherence == null
        ? scheme.surfaceContainerLow
        : Color.lerp(
            scheme.primaryContainer.withValues(alpha: 0.35),
            scheme.primary,
            adherence,
          )!;
    final ink = adherence != null && adherence > 0.6
        ? scheme.onPrimary
        : scheme.onSurface;
    final label = percent == null
        ? '${formatDate(day, locale)}: ${l.historyNoDoses}'
        : l.historyDayLabel(formatDate(day, locale), percent);

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: fill,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: isToday
              ? BorderSide(color: scheme.primary, width: 2)
              : BorderSide.none,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openDayAnalysis(context, day),
          child: Opacity(
            opacity: isFuture ? 0.5 : 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${day.day}',
                  style: theme.textTheme.titleSmall?.copyWith(color: ink),
                ),
                if (percent != null)
                  Text(
                    '$percent%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
