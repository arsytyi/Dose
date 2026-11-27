import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/dose_plan.dart';
import '../domain/format.dart';
import '../domain/schedule_rule.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'dose_sheet.dart';
import 'pill_icon.dart';
import 'stock_widgets.dart';
import 'theme.dart';
import 'widgets.dart';

/// The "pillbox": what to take today, what has been taken, and swiping
/// between days.
class TodayScreen extends ConsumerStatefulWidget {
  const TodayScreen({super.key});

  @override
  ConsumerState<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends ConsumerState<TodayScreen> {
  /// Page index for today; pages to the left are past days.
  static const _todayPage = 10000;

  final _controller = PageController(initialPage: _todayPage);
  int _page = _todayPage;

  DateTime get _today => dateOnly(DateTime.now());
  DateTime _dateFor(int page) => addDays(_today, page - _todayPage);
  DateTime get _selected => _dateFor(_page);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pending = ref.read(focusRequestProvider);
      if (pending != null) _handleFocus(pending);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goTo(DateTime day) {
    final page = _todayPage + daysBetween(_today, day);
    if (!_controller.hasClients) return;
    if ((page - _page).abs() > 3) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _pickDate() async {
    final today = _today;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected,
      currentDate: today,
      firstDate: addDays(today, -366),
      lastDate: addDays(today, 366),
    );
    if (picked != null && mounted) _goTo(dateOnly(picked));
  }

  Future<void> _handleFocus(FocusRequest request) async {
    ref.read(focusRequestProvider.notifier).clear();
    _goTo(dateOnly(request.doseTime));
    // Let the page settle and data load before opening the sheet.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    final day = dateOnly(request.doseTime);
    final slots = await _slotsFor(day);
    final group = slots.where((s) => s.time == request.doseTime).toList();
    if (group.isEmpty || !mounted) return;
    await showDoseSheet(context, ref, group);
  }

  Future<List<DoseSlot>> _slotsFor(DateTime day) async {
    final plan = await ref.read(activePlanProvider.future);
    final events = await ref.read(dayEventsProvider(day).future);
    return buildDay(
      entries: toPlanEntries(plan),
      logged: events.map((e) => e.toLogged()),
      day: day,
      now: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    ref.listen(focusRequestProvider, (_, next) {
      if (next != null) _handleFocus(next);
    });
    ref.listen(todayTabTapsProvider, (_, _) => _goTo(_today));
    final isToday = _selected == _today;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isToday
              ? l.navToday
              : toBeginningOfSentenceCase(
                  DateFormat.MMMMEEEEd(locale).format(_selected),
                ),
        ),
        actions: [
          IconButton(
            tooltip: l.pickDate,
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            tooltip: l.prevDay,
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _goTo(addDays(_selected, -1)),
          ),
          IconButton(
            tooltip: l.nextDay,
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _goTo(addDays(_selected, 1)),
          ),
        ],
      ),
      body: Column(
        children: [
          _WeekStrip(selected: _selected, today: _today, onSelect: _goTo),
          const Divider(height: 1),
          Expanded(
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (p) => setState(() => _page = p),
              itemBuilder: (context, page) =>
                  _DayView(key: ValueKey(page), day: _dateFor(page)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  const _WeekStrip({
    required this.selected,
    required this.today,
    required this.onSelect,
  });

  final DateTime selected;
  final DateTime today;
  final ValueChanged<DateTime> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final monday = addDays(selected, 1 - selected.weekday);
    final names = weekdayNames(locale);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.xs,
      ),
      child: Row(
        children: [
          for (var i = 0; i < 7; i++)
            Expanded(
              child: Builder(
                builder: (context) {
                  final day = addDays(monday, i);
                  final isSelected = day == selected;
                  final isToday = day == today;
                  return Semantics(
                    button: true,
                    selected: isSelected,
                    label: DateFormat.MMMMEEEEd(locale).format(day),
                    excludeSemantics: true,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(Radii.card),
                      onTap: () => onSelect(day),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 56),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              names[i],
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              width: 32,
                              height: 32,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? scheme.primary : null,
                                border: isToday && !isSelected
                                    ? Border.all(
                                        color: scheme.primary,
                                        width: 2,
                                      )
                                    : null,
                              ),
                              child: Text(
                                '${day.day}',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? scheme.onPrimary
                                      : scheme.onSurface,
                                  fontWeight: isToday || isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _DayView extends ConsumerWidget {
  const _DayView({super.key, required this.day});

  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final plan = ref.watch(activePlanProvider);
    final events = ref.watch(dayEventsProvider(day));
    final meds = ref.watch(allMedicationsProvider).value ?? const {};

    if (plan.isLoading || events.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final now = DateTime.now();
    final slots = buildDay(
      entries: toPlanEntries(plan.value ?? const []),
      logged: (events.value ?? const []).map((e) => e.toLogged()),
      day: day,
      now: now,
    ).where((s) => meds.containsKey(s.medicationId)).toList();

    final asNeeded = [
      for (final p in plan.value ?? const <PlannedSchedule>[])
        if (p.schedule.rule.dayPattern == DayPattern.asNeeded) p.medication,
    ];
    final isToday = day == dateOnly(now);
    final isFuture = day.isAfter(dateOnly(now));

    if (slots.isEmpty && (asNeeded.isEmpty || !isToday)) {
      return EmptyState(
        icon: Icons.event_available_outlined,
        title: isToday ? l.todayEmpty : l.dayEmpty,
        subtitle: meds.isEmpty ? l.todayHint : null,
      );
    }

    final parts = <DayPart, List<DoseSlot>>{};
    for (final s in slots) {
      parts.putIfAbsent(dayPartOf(s.time), () => []).add(s);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: Spacing.xl),
      children: [
        if (isToday) const RestockBanner(),
        if (slots.isNotEmpty)
          _ProgressCard(summary: summarize(slots), future: isFuture),
        for (final part in DayPart.values)
          if (parts[part] case final list?)
            _PartSection(
              part: part,
              slots: list,
              meds: meds,
              canAct: !isFuture,
            ),
        if (isToday && asNeeded.isNotEmpty) ...[
          SectionTitle(l.asNeededSection),
          for (final m in asNeeded)
            ListTile(
              leading: PillAvatar(m),
              title: Text(m.name),
              trailing: OutlinedButton.icon(
                icon: const Icon(Icons.check),
                label: Text(l.logNow),
                onPressed: () async {
                  await ref
                      .read(databaseProvider)
                      .logUnscheduled(m.id, 1, DateTime.now());
                },
              ),
            ),
        ],
      ],
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.summary, required this.future});

  final DaySummary summary;
  final bool future;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = summary.pending == 0 && summary.taken > 0;
    final percent = (summary.progress * 100).round();

    return Card(
      margin: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.lg,
        Spacing.sm,
      ),
      color: scheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Row(
          children: [
            SizedBox.square(
              dimension: 64,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.square(
                    dimension: 64,
                    child: CircularProgressIndicator(
                      value: future ? 0 : summary.progress,
                      strokeWidth: 6,
                      color: Accents.of(context).good,
                      backgroundColor: scheme.surface,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  if (done)
                    Icon(Icons.check, color: Accents.of(context).good, size: 32)
                  else
                    Text(
                      future ? '${summary.total}' : l.progressPercent(percent),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    future
                        ? l.progressPlanned(summary.total)
                        : done
                        ? l.allDone
                        : l.progressTaken(summary.taken, summary.total),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.onSecondaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!future) ...[
                    const SizedBox(height: Spacing.xs),
                    Text(
                      l.progressDetails(summary.skipped, summary.pending),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PartSection extends ConsumerWidget {
  const _PartSection({
    required this.part,
    required this.slots,
    required this.meds,
    required this.canAct,
  });

  final DayPart part;
  final List<DoseSlot> slots;
  final Map<int, Medication> meds;
  final bool canAct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final (label, icon) = switch (part) {
      DayPart.night => (l.partNight, Icons.bedtime_outlined),
      DayPart.morning => (l.partMorning, Icons.wb_twilight),
      DayPart.afternoon => (l.partAfternoon, Icons.wb_sunny_outlined),
      DayPart.evening => (l.partEvening, Icons.nights_stay_outlined),
    };
    final accents = Accents.of(context);
    final iconColor = switch (part) {
      DayPart.night => accents.night,
      DayPart.morning => accents.morning,
      DayPart.afternoon => accents.afternoon,
      DayPart.evening => accents.evening,
    };
    final pending = slots
        .where((s) => s.isPending && s.scheduledAt != null)
        .toList();

    final byTime = <DateTime, List<DoseSlot>>{};
    for (final s in slots) {
      byTime.putIfAbsent(s.time, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.sm,
            0,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: iconColor),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ),
              if (canAct && pending.length > 1)
                TextButton.icon(
                  onPressed: () => takeSlots(context, ref, pending),
                  icon: const Icon(Icons.done_all, size: 18),
                  label: Text(l.takeAll),
                ),
            ],
          ),
        ),
        for (final e in byTime.entries)
          for (final (i, s) in e.value.indexed)
            DoseCard(
              slot: s,
              medication: meds[s.medicationId]!,
              showTime: i == 0,
              onTap: canAct ? () => showDoseSheet(context, ref, [s]) : null,
            ),
      ],
    );
  }
}

/// One dose in the pillbox.
class DoseCard extends StatelessWidget {
  const DoseCard({
    super.key,
    required this.slot,
    required this.medication,
    required this.showTime,
    this.onTap,
  });

  final DoseSlot slot;
  final Medication medication;
  final bool showTime;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final done = slot.state == DoseState.taken;
    final skipped = slot.state == DoseState.skipped;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.xs, Spacing.lg, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 52,
            child: Padding(
              padding: const EdgeInsets.only(top: Spacing.lg),
              child: showTime
                  ? Text(
                      formatTime(slot.time.hour, slot.time.minute),
                      style: timeStyle(context, muted: done || skipped),
                    )
                  : null,
            ),
          ),
          Expanded(
            child: Card(
              margin: EdgeInsets.zero,
              elevation: 0,
              color: done
                  ? scheme.surfaceContainerLow
                  : scheme.surfaceContainerHighest,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.md),
                  child: Row(
                    children: [
                      PillAvatar(medication, size: 44),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              medication.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                decoration: skipped
                                    ? TextDecoration.lineThrough
                                    : null,
                              ),
                            ),
                            Text(
                              [
                                formatDoseWithUnit(
                                  slot.dose,
                                  medication.unit,
                                  l,
                                ),
                                if (medication.meal.index != 0)
                                  l.mealName(medication.meal.name),
                              ].join(' · '),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: Spacing.xs),
                            StatusChip(slot: slot),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon + text so state never relies on color alone.
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.slot});

  final DoseSlot slot;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    String hm(DateTime? t) => t == null ? '' : formatTime(t.hour, t.minute);
    final (icon, text, color) = switch (slot.state) {
      DoseState.taken => (
        Icons.check_circle,
        slot.actualAt == null
            ? l.stateTaken
            : l.stateTakenAt(hm(slot.actualAt)),
        Accents.of(context).good,
      ),
      DoseState.skipped => (
        Icons.block,
        l.stateSkipped,
        scheme.onSurfaceVariant,
      ),
      DoseState.snoozed => (
        Icons.snooze,
        l.stateSnoozedUntil(hm(slot.actualAt)),
        scheme.tertiary,
      ),
      DoseState.overdue => (Icons.error_outline, l.stateOverdue, scheme.error),
      DoseState.planned => (
        Icons.schedule,
        l.statePlanned,
        scheme.onSurfaceVariant,
      ),
    };
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: Spacing.xs),
        Flexible(
          child: Text(
            slot.scheduledAt == null ? '$text · ${l.unscheduled}' : text,
            style: theme.textTheme.labelLarge?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
