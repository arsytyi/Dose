import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/format.dart';
import '../domain/stock.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'medication_detail_screen.dart';
import 'theme.dart';
import '../services/pro.dart';
import 'pro_screen.dart';

double? _parse(String s) => double.tryParse(s.trim().replaceAll(',', '.'));

/// "Lasts 12 days · until 30 Nov", or "Out of stock".
String stockForecastText(
  StockForecast f,
  AppLocalizations l,
  String locale,
  DateTime now,
) {
  if (f.isEmpty) return l.stockEmpty;
  final days = f.daysLeft;
  if (days == null) return '';
  return '${l.stockDaysLeft(days)} · '
      '${l.stockRunsOut(formatDate(f.runsOutOn(now)!, locale))}';
}

/// A small "Running low" label with an icon, so color is never the only cue.
class LowStockChip extends StatelessWidget {
  const LowStockChip({super.key, required this.empty});

  final bool empty;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: scheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 16,
            color: scheme.onErrorContainer,
          ),
          const SizedBox(width: Spacing.xs),
          Text(
            empty ? l.stockEmpty : l.stockLow,
            style: Theme.of(context).textTheme.labelMedium
                ?.copyWith(color: scheme.onErrorContainer),
          ),
        ],
      ),
    );
  }
}

/// Stock block on the medication screen.
class StockSection extends ConsumerWidget {
  const StockSection({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final m = medication;
    final locale = Localizations.localeOf(context).toLanguageTag();

    if (!ref.watch(isProProvider)) {
      return ProLockedTile(
        icon: Icons.inventory_2_outlined,
        title: l.proFeatureStock,
      );
    }

    if (m.stock == null) {
      return ListTile(
        leading: const Icon(Icons.inventory_2_outlined),
        title: Text(l.stockNotTracked),
        trailing: TextButton(
          onPressed: () => showStockSettings(context, ref, m),
          child: Text(l.stockSetUp),
        ),
      );
    }

    final f = ref.watch(stockForecastsProvider)[m.id];
    final forecast = f == null
        ? ''
        : stockForecastText(f, l, locale, DateTime.now());
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.md,
          Spacing.sm,
          Spacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2_outlined),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.stockLeft(formatDoseWithUnit(m.stock!, m.unit, l)),
                        style: theme.textTheme.titleMedium,
                      ),
                      if (forecast.isNotEmpty)
                        Text(
                          forecast,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: l.stockSettings,
                  icon: const Icon(Icons.tune),
                  onPressed: () => showStockSettings(context, ref, m),
                ),
              ],
            ),
            if (f?.isLow ?? false) ...[
              const SizedBox(height: Spacing.sm),
              LowStockChip(empty: f!.isEmpty),
            ],
            const SizedBox(height: Spacing.sm),
            Wrap(
              spacing: Spacing.sm,
              children: [
                FilledButton.tonalIcon(
                  onPressed: () => showBoughtSheet(context, ref, m),
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text(l.stockBought),
                ),
                TextButton(
                  onPressed: () => showStockSettings(context, ref, m),
                  child: Text(l.stockCorrect),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Bought more": add one pack or any amount.
Future<void> showBoughtSheet(
  BuildContext context,
  WidgetRef ref,
  Medication m,
) async {
  final l = AppLocalizations.of(context);
  final db = ref.read(databaseProvider);
  final pack = m.packSize;
  final amount = await showModalBottomSheet<double>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (pack != null && pack > 0)
            ListTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: Text(l.stockAddPack(formatDoseWithUnit(pack, m.unit, l))),
              onTap: () => Navigator.of(sheet).pop(pack),
            ),
          ListTile(
            leading: const Icon(Icons.edit_outlined),
            title: Text(l.stockAddAmount),
            onTap: () async {
              final v = await _askNumber(sheet, l.stockAmountToAdd);
              if (v != null && sheet.mounted) Navigator.of(sheet).pop(v);
            },
          ),
        ],
      ),
    ),
  );
  if (amount != null && amount > 0) await db.addStock(m.id, amount);
}

Future<double?> _askNumber(BuildContext context, String title) {
  final l = AppLocalizations.of(context);
  final controller = TextEditingController();
  final formKey = GlobalKey<FormState>();
  void submit(BuildContext dialog) {
    if (formKey.currentState!.validate()) {
      Navigator.of(dialog).pop(_parse(controller.text));
    }
  }

  return showDialog<double>(
    context: context,
    builder: (dialog) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
          ],
          validator: (v) {
            final n = _parse(v ?? '');
            return n == null || n <= 0 ? l.stockInvalid : null;
          },
          onFieldSubmitted: (_) => submit(dialog),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialog).pop(),
          child: Text(l.cancel),
        ),
        FilledButton(onPressed: () => submit(dialog), child: Text(l.save)),
      ],
    ),
  ).whenComplete(controller.dispose);
}

Future<void> showStockSettings(
  BuildContext context,
  WidgetRef ref,
  Medication m,
) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _StockSettingsSheet(medication: m),
);

class _StockSettingsSheet extends ConsumerStatefulWidget {
  const _StockSettingsSheet({required this.medication});

  final Medication medication;

  @override
  ConsumerState<_StockSettingsSheet> createState() =>
      _StockSettingsSheetState();
}

class _StockSettingsSheetState extends ConsumerState<_StockSettingsSheet> {
  final _form = GlobalKey<FormState>();
  late bool _track;
  late final TextEditingController _stock;
  late final TextEditingController _pack;
  late final TextEditingController _warn;

  String _num(double? v) => v == null ? '' : formatDose(v);

  @override
  void initState() {
    super.initState();
    final m = widget.medication;
    _track = true;
    _stock = TextEditingController(text: _num(m.stock));
    _pack = TextEditingController(text: _num(m.packSize));
    _warn = TextEditingController(text: '${m.lowStockDays}');
  }

  @override
  void dispose() {
    _stock.dispose();
    _pack.dispose();
    _warn.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    await ref
        .read(databaseProvider)
        .setStockSettings(
          widget.medication.id,
          stock: _track ? _parse(_stock.text) : null,
          packSize: _parse(_pack.text),
          lowStockDays: int.tryParse(_warn.text.trim()) ?? 7,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final unit = unitLabel(widget.medication.unit, l);
    final numberKeyboard = const TextInputType.numberWithOptions(decimal: true);
    final numberFilter = [
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
    ];
    String? required(String? v) {
      final n = _parse(v ?? '');
      return n == null || n < 0 ? l.stockInvalid : null;
    }

    String? optional(String? v) =>
        (v ?? '').trim().isEmpty ? null : required(v);

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.lg,
          ),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l.stockSettings,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l.stockTrack),
                  subtitle: Text(l.stockTrackHint),
                  value: _track,
                  onChanged: (v) => setState(() => _track = v),
                ),
                if (_track) ...[
                  const SizedBox(height: Spacing.sm),
                  TextFormField(
                    controller: _stock,
                    autofocus: widget.medication.stock == null,
                    keyboardType: numberKeyboard,
                    inputFormatters: numberFilter,
                    decoration: InputDecoration(
                      labelText: l.stockCurrent,
                      suffixText: unit,
                    ),
                    validator: required,
                  ),
                  const SizedBox(height: Spacing.md),
                  TextFormField(
                    controller: _pack,
                    keyboardType: numberKeyboard,
                    inputFormatters: numberFilter,
                    decoration: InputDecoration(
                      labelText: l.stockPackSize,
                      helperText: l.stockPackSizeHint,
                      suffixText: unit,
                    ),
                    validator: optional,
                  ),
                  const SizedBox(height: Spacing.md),
                  TextFormField(
                    controller: _warn,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(labelText: l.stockWarnDays),
                    validator: (v) => int.tryParse((v ?? '').trim()) == null
                        ? l.stockInvalid
                        : null,
                  ),
                ],
                const SizedBox(height: Spacing.lg),
                FilledButton(onPressed: _save, child: Text(l.save)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// On Today: medications that are running low, each opening its screen.
class RestockBanner extends ConsumerWidget {
  const RestockBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final forecasts = ref.watch(stockForecastsProvider);
    final meds = ref.watch(medicationsProvider).value ?? const [];
    final low = [
      for (final m in meds)
        if (forecasts[m.id] case final f? when f.isLow) (m, f),
    ];
    if (low.isEmpty) return const SizedBox.shrink();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final onCard = theme.colorScheme.onErrorContainer;
    return Card(
      margin: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
      color: theme.colorScheme.errorContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.md,
              Spacing.lg,
              0,
            ),
            child: Row(
              children: [
                Icon(Icons.add_shopping_cart, color: onCard),
                const SizedBox(width: Spacing.sm),
                Text(
                  l.stockBanner,
                  style: theme.textTheme.titleSmall?.copyWith(color: onCard),
                ),
              ],
            ),
          ),
          for (final (m, f) in low)
            ListTile(
              textColor: onCard,
              iconColor: onCard,
              title: Text(m.name),
              subtitle: Text(stockForecastText(f, l, locale, now)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => MedicationDetailScreen(id: m.id),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
