import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/interactions.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import '../services/files.dart';
import 'pill_icon.dart';
import 'theme.dart';
import 'widgets.dart';

String _lang(AppLocalizations l) => l.localeName.split('_').first;

/// Reference notes for the substances in [medication]; nothing when the
/// catalog has none.
class GuideSection extends ConsumerWidget {
  const GuideSection({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final catalog = ref.watch(interactionCatalogProvider).value;
    if (catalog == null) return const SizedBox.shrink();
    final m = medication;
    final keys = m.ingredients == null
        ? catalog.detect(m.name)
        : m.ingredientKeys;
    final substances = [
      for (final k in keys)
        if (catalog.substance(k) case final s? when catalog.hasGuide(s)) s,
    ];
    final product = catalog.products
        .where((p) => p.fullName == m.name)
        .firstOrNull;
    if (substances.isEmpty && product?.url == null) {
      return const SizedBox.shrink();
    }
    final lang = _lang(l);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(l.guideTitle),
        for (final s in substances)
          ListTile(
            leading: const Icon(Icons.menu_book_outlined),
            title: Text(s.name(lang)),
            subtitle: Text(
              guideSummary(catalog, s, l),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showSubstanceGuide(context, catalog, s),
          ),
        if (product?.url case final url?)
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: Text(l.guideProductPage),
            subtitle: Text(product!.amountIn(lang)),
            onTap: () => DeviceFiles.openUrl(url),
          ),
      ],
    );
  }
}

/// One line about [s] for lists: how to take it, or how many rules it has.
String guideSummary(
  InteractionCatalog catalog,
  Substance s,
  AppLocalizations l,
) =>
    s.info?.intakeIn(_lang(l)) ??
    l.guideRuleCount(catalog.rulesAbout(s.key).length);

IconData _ruleIcon(RuleType t) => switch (t) {
  RuleType.avoid => Icons.warning_amber_rounded,
  RuleType.separate => Icons.schedule,
  RuleType.together => Icons.check_circle_outline,
};

String _ruleLabel(InteractionRule r, AppLocalizations l) => switch (r.type) {
  RuleType.avoid => l.guideRuleAvoid,
  RuleType.separate => l.guideRuleSeparate(r.hours),
  RuleType.together => l.guideRuleTogether,
};

/// How to take [substance], cautions, compatibility and sources.
Future<void> showSubstanceGuide(
  BuildContext context,
  InteractionCatalog catalog,
  Substance substance,
) {
  final l = AppLocalizations.of(context);
  final lang = _lang(l);
  final info = substance.info;
  final rules = catalog.rulesAbout(substance.key)
    ..sort((a, b) => a.type.index.compareTo(b.type.index));
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheet) {
      final theme = Theme.of(sheet);
      final muted = theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      );
      Widget heading(IconData icon, String text) => Padding(
        padding: const EdgeInsets.only(top: Spacing.lg, bottom: Spacing.xs),
        child: Row(
          children: [
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: Spacing.sm),
            Text(text, style: theme.textTheme.titleSmall),
          ],
        ),
      );
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        builder: (_, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.xl,
          ),
          children: [
            Text(substance.name(lang), style: theme.textTheme.headlineSmall),
            if (info != null) ...[
              heading(Icons.schedule, l.guideIntake),
              Text(info.intakeIn(lang), style: theme.textTheme.bodyLarge),
              heading(Icons.warning_amber_rounded, l.guideCautions),
              Text(info.cautionsIn(lang), style: theme.textTheme.bodyLarge),
            ] else if (substance.kind == SubstanceKind.drug) ...[
              const SizedBox(height: Spacing.sm),
              Text(l.guideDrugNote, style: theme.textTheme.bodyLarge),
            ],
            if (rules.isNotEmpty) ...[
              heading(Icons.sync_alt, l.compatTitle),
              for (final r in rules)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _ruleIcon(r.type),
                    color: r.type == RuleType.together
                        ? theme.colorScheme.primary
                        : theme.colorScheme.error,
                  ),
                  title: Text(
                    '${catalog.substance(r.a == substance.key ? r.b : r.a)?.name(lang) ?? ''} · ${_ruleLabel(r, l)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.text(lang)),
                      Text(r.source, style: muted),
                    ],
                  ),
                  trailing: r.url == null
                      ? null
                      : const Icon(Icons.open_in_new, size: 20),
                  onTap: r.url == null
                      ? null
                      : () => DeviceFiles.openUrl(r.url!),
                ),
            ],
            if (info != null) ...[
              heading(Icons.link, l.guideSources),
              for (final s in info.sources)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(s.name),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () => DeviceFiles.openUrl(s.url),
                ),
            ],
            const SizedBox(height: Spacing.md),
            Text(l.compatDisclaimer, style: muted),
          ],
        ),
      );
    },
  );
}

/// Search field shared by the reference list and the substance picker.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        labelText: l.guideSearch,
        hintText: l.guideSearchHint,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

/// Lets the user tick substances; returns the new selection, or null when
/// dismissed.
Future<Set<String>?> showSubstancePicker(
  BuildContext context,
  InteractionCatalog catalog,
  Set<String> selected,
) => showModalBottomSheet<Set<String>>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _SubstancePicker(catalog: catalog, initial: selected),
);

class _SubstancePicker extends StatefulWidget {
  const _SubstancePicker({required this.catalog, required this.initial});

  final InteractionCatalog catalog;
  final Set<String> initial;

  @override
  State<_SubstancePicker> createState() => _SubstancePickerState();
}

class _SubstancePickerState extends State<_SubstancePicker> {
  late final Set<String> _selected = {...widget.initial};
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = _lang(l);
    final theme = Theme.of(context);
    final found = widget.catalog.searchSubstances(_query).toList()
      ..sort((a, b) => a.name(lang).compareTo(b.name(lang)));
    Iterable<Widget> group(SubstanceKind kind, String title) {
      final items = [
        for (final s in found)
          if (s.kind == kind) s,
      ];
      if (items.isEmpty) return const [];
      return [
        SectionTitle(title),
        for (final s in items)
          CheckboxListTile(
            value: _selected.contains(s.key),
            title: Text(s.name(lang)),
            onChanged: (on) => setState(
              () => on! ? _selected.add(s.key) : _selected.remove(s.key),
            ),
          ),
      ];
    }

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      builder: (_, controller) => Column(
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
                Expanded(
                  child: Text(
                    l.ingredientsPick,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: Text(l.ingredientsDone),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: _SearchField(onChanged: (q) => setState(() => _query = q)),
          ),
          Expanded(
            child: found.isEmpty
                ? EmptyState(icon: Icons.search_off, title: l.guideNothingFound)
                : ListView(
                    controller: controller,
                    children: [
                      ...group(SubstanceKind.supplement, l.guideSupplements),
                      ...group(SubstanceKind.drug, l.guideDrugs),
                      const SizedBox(height: Spacing.xl),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// One suggestion in the name field's list.
class ProductOption extends StatelessWidget {
  const ProductOption({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ListTile(
      leading: PillIcon(
        shape: product.shape,
        color: Color(product.color),
        color2: product.color2 == null ? null : Color(product.color2!),
        size: 36,
      ),
      title: Text(product.name),
      subtitle: Text('${product.brand} · ${product.amountIn(_lang(l))}'),
      onTap: onTap,
    );
  }
}

/// Every substance the reference has something for, with search and a
/// supplements / medicines switch.
class GuideListScreen extends ConsumerStatefulWidget {
  const GuideListScreen({super.key});

  @override
  ConsumerState<GuideListScreen> createState() => _GuideListScreenState();
}

class _GuideListScreenState extends ConsumerState<GuideListScreen> {
  String _query = '';
  SubstanceKind _kind = SubstanceKind.supplement;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = _lang(l);
    final catalog = ref.watch(interactionCatalogProvider).value;
    final substances = <Substance>[
      if (catalog != null)
        for (final s in catalog.searchSubstances(_query))
          if (s.kind == _kind && catalog.hasGuide(s)) s,
    ];
    substances.sort((a, b) => a.name(lang).compareTo(b.name(lang)));
    return Scaffold(
      appBar: AppBar(title: Text(l.guideAll)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              Spacing.sm,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SearchField(onChanged: (q) => setState(() => _query = q)),
                const SizedBox(height: Spacing.md),
                SegmentedButton<SubstanceKind>(
                  segments: [
                    ButtonSegment(
                      value: SubstanceKind.supplement,
                      label: Text(l.guideSupplements),
                    ),
                    ButtonSegment(
                      value: SubstanceKind.drug,
                      label: Text(l.guideDrugs),
                    ),
                  ],
                  selected: {_kind},
                  onSelectionChanged: (s) => setState(() => _kind = s.first),
                ),
              ],
            ),
          ),
          Expanded(
            child: substances.isEmpty
                ? EmptyState(icon: Icons.search_off, title: l.guideNothingFound)
                : ListView.builder(
                    itemCount: substances.length,
                    itemBuilder: (context, i) {
                      final s = substances[i];
                      return ListTile(
                        title: Text(s.name(lang)),
                        subtitle: Text(
                          guideSummary(catalog!, s, l),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => showSubstanceGuide(context, catalog, s),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
