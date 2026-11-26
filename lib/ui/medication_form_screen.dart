import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/enums.dart';
import '../domain/interactions.dart';
import '../domain/look.dart';
import '../l10n/app_localizations.dart';
import '../providers.dart';
import 'guide_widgets.dart';
import 'medication_detail_screen.dart';
import 'pill_icon.dart';
import 'theme.dart';

/// Create or edit a medication's details (not its schedules).
class MedicationFormScreen extends ConsumerStatefulWidget {
  const MedicationFormScreen({super.key, this.existing});

  final Medication? existing;

  @override
  ConsumerState<MedicationFormScreen> createState() =>
      _MedicationFormScreenState();
}

/// Value of the unit dropdown that switches to free text.
const _customUnit = '__custom__';

class _MedicationFormScreenState extends ConsumerState<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  final _nameFocus = FocusNode();
  late final TextEditingController _customUnitText;
  late final TextEditingController _notes;
  late MedKind _kind;
  late MedForm _form;
  late MealRelation _meal;
  late int _color;
  int? _color2;
  PillShape? _shape;

  /// Chosen substances; null follows what the name says.
  Set<String>? _ingredients;

  /// Stored unit (`@name`) or [_customUnit].
  late String _unitChoice;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final m = widget.existing;
    _name = TextEditingController(text: m?.name ?? '');
    _notes = TextEditingController(text: m?.notes ?? '');
    _kind = m?.kind ?? MedKind.supplement;
    _form = m?.form ?? MedForm.tablet;
    _meal = m?.meal ?? MealRelation.any;
    _color = m?.color ?? pillColors.first;
    _color2 = m?.color2;
    _shape = m?.shape;
    if (m?.ingredients != null) _ingredients = m!.ingredientKeys;
    _name.addListener(() {
      if (_ingredients == null) setState(() {});
    });
    final stored = m?.unit ?? '';
    final parsed = parseUnit(stored);
    if (parsed != null) {
      _unitChoice = storeUnit(parsed);
      _customUnitText = TextEditingController();
    } else if (stored.trim().isNotEmpty) {
      _unitChoice = _customUnit;
      _customUnitText = TextEditingController(text: stored);
    } else {
      _unitChoice = storeUnit(unitsFor(_form).first);
      _customUnitText = TextEditingController();
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    _customUnitText.dispose();
    _notes.dispose();
    super.dispose();
  }

  PillShape get _effectiveShape => _shape ?? defaultShapeFor(_form);

  Set<String> get _effectiveIngredients =>
      _ingredients ??
      ref.read(interactionCatalogProvider).value?.detect(_name.text) ??
      const {};

  List<String> get _unitOptions {
    final list = [for (final u in unitsFor(_form)) storeUnit(u)];
    // Keep a built-in unit chosen earlier even if the form changed.
    if (_unitChoice != _customUnit && !list.contains(_unitChoice)) {
      list.add(_unitChoice);
    }
    return [...list, _customUnit];
  }

  void _setForm(MedForm f) {
    setState(() {
      final wasDefaultUnit =
          _unitChoice == storeUnit(unitsFor(_form).first) ||
          _unitChoice == _customUnit && _customUnitText.text.trim().isEmpty;
      _form = f;
      if (wasDefaultUnit) _unitChoice = storeUnit(unitsFor(f).first);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final db = ref.read(databaseProvider);
    final unit = _unitChoice == _customUnit
        ? _customUnitText.text.trim()
        : _unitChoice;
    final entry = MedicationsCompanion(
      name: Value(_name.text.trim()),
      kind: Value(_kind),
      form: Value(_form),
      unit: Value(unit),
      meal: Value(_meal),
      notes: Value(_notes.text.trim()),
      color: Value(_color),
      color2: Value(_effectiveShape == PillShape.capsule ? _color2 : null),
      shape: Value(_shape),
      ingredients: Value(_effectiveIngredients.join(',')),
    );
    final nav = Navigator.of(context);
    if (widget.existing case final m?) {
      await db.updateMedication(m.id, entry);
      nav.pop();
    } else {
      final id = await db.insertMedication(entry);
      nav.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => MedicationDetailScreen(id: id)),
      );
    }
  }

  /// Fills the form from a ready-made product.
  void _applyProduct(Product p) {
    final l = AppLocalizations.of(context);
    _setForm(p.form);
    setState(() {
      _kind = MedKind.supplement;
      _shape = p.shape;
      _color = p.color;
      _color2 = p.color2;
      _meal = p.meal;
      _ingredients = p.substances.toSet();
      if (_notes.text.trim().isEmpty) {
        _notes.text = p.amountIn(l.localeName.split('_').first);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existing == null ? l.addMedication : l.editMedication,
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(Spacing.lg),
          children: [
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: PillIcon(
                  shape: _effectiveShape,
                  color: Color(_color),
                  color2: _color2 == null ? null : Color(_color2!),
                  size: 72,
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            RawAutocomplete<Product>(
              textEditingController: _name,
              focusNode: _nameFocus,
              displayStringForOption: (p) => p.fullName,
              optionsBuilder: (value) {
                final catalog = ref.read(interactionCatalogProvider).value;
                if (catalog == null || value.text.trim().length < 2) {
                  return const [];
                }
                return catalog
                    .searchProducts(value.text)
                    .where((p) => p.fullName != value.text);
              },
              onSelected: _applyProduct,
              fieldViewBuilder: (context, controller, focusNode, _) =>
                  TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: widget.existing == null,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: '${l.fieldName} *',
                      helperText: l.productHint,
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? l.fieldNameRequired
                        : null,
                  ),
              optionsViewBuilder: (context, onSelected, options) => Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 320,
                      maxWidth:
                          MediaQuery.sizeOf(context).width - 2 * Spacing.lg,
                    ),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        for (final p in options)
                          ProductOption(product: p, onTap: () => onSelected(p)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: Spacing.lg),
            SegmentedButton<MedKind>(
              segments: [
                ButtonSegment(
                  value: MedKind.medicine,
                  label: Text(l.kindMedicine),
                ),
                ButtonSegment(
                  value: MedKind.supplement,
                  label: Text(l.kindSupplement),
                ),
              ],
              selected: {_kind},
              onSelectionChanged: (s) => setState(() => _kind = s.first),
            ),
            const SizedBox(height: Spacing.lg),
            DropdownButtonFormField<MedForm>(
              initialValue: _form,
              decoration: InputDecoration(labelText: l.fieldForm),
              items: [
                for (final f in MedForm.values)
                  DropdownMenuItem(value: f, child: Text(l.formName(f.name))),
              ],
              onChanged: (f) => _setForm(f!),
            ),
            const SizedBox(height: Spacing.lg),
            DropdownButtonFormField<String>(
              key: ValueKey('unit-${_form.name}'),
              initialValue: _unitChoice,
              decoration: InputDecoration(labelText: l.fieldUnit),
              isExpanded: true,
              items: [
                for (final u in _unitOptions)
                  DropdownMenuItem(
                    value: u,
                    child: Text(
                      u == _customUnit
                          ? l.unitOther
                          : l.unitName(parseUnit(u)!.name),
                    ),
                  ),
              ],
              onChanged: (u) => setState(() => _unitChoice = u!),
            ),
            if (_unitChoice == _customUnit) ...[
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _customUnitText,
                decoration: InputDecoration(
                  labelText: l.unitCustom,
                  hintText: l.fieldUnitHint,
                ),
              ),
            ],
            const SizedBox(height: Spacing.lg),
            DropdownButtonFormField<MealRelation>(
              initialValue: _meal,
              decoration: InputDecoration(labelText: l.fieldMeal),
              items: [
                for (final m in MealRelation.values)
                  DropdownMenuItem(value: m, child: Text(l.mealName(m.name))),
              ],
              onChanged: (m) => setState(() => _meal = m!),
            ),
            const SizedBox(height: Spacing.xl),
            Text(l.fieldLook, style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            _ShapePicker(
              selected: _effectiveShape,
              color: _color,
              color2: _color2,
              onSelected: (s) => setState(() => _shape = s),
            ),
            const SizedBox(height: Spacing.xl),
            Text(l.fieldColor, style: theme.textTheme.titleSmall),
            const SizedBox(height: Spacing.sm),
            _ColorPicker(
              selected: _color,
              onSelected: (c) => setState(() => _color = c),
            ),
            if (_effectiveShape == PillShape.capsule) ...[
              const SizedBox(height: Spacing.xl),
              Text(l.fieldColor2, style: theme.textTheme.titleSmall),
              const SizedBox(height: Spacing.sm),
              _ColorPicker(
                selected: _color2,
                onSelected: (c) => setState(() => _color2 = c),
              ),
            ],
            const SizedBox(height: Spacing.xl),
            Text(l.fieldIngredients, style: theme.textTheme.titleSmall),
            Text(
              l.ingredientsHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            if (ref.watch(interactionCatalogProvider).value case final catalog?)
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.xs,
                children: [
                  for (final key in _effectiveIngredients)
                    if (catalog.substance(key) case final sub?)
                      InputChip(
                        label: Text(sub.name(l.localeName.split('_').first)),
                        onDeleted: () => setState(() {
                          _ingredients = {..._effectiveIngredients}
                            ..remove(key);
                        }),
                        deleteButtonTooltipMessage: l.ingredientsRemove,
                      ),
                  ActionChip(
                    avatar: const Icon(Icons.add),
                    label: Text(l.ingredientsAdd),
                    onPressed: () async {
                      final picked = await showSubstancePicker(
                        context,
                        catalog,
                        _effectiveIngredients,
                      );
                      if (picked != null && mounted) {
                        setState(() => _ingredients = picked);
                      }
                    },
                  ),
                ],
              ),
            const SizedBox(height: Spacing.xl),
            TextFormField(
              controller: _notes,
              minLines: 3,
              maxLines: 8,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                labelText: l.fieldNotes,
                hintText: l.fieldNotesHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: Spacing.xl),
          ],
        ),
      ),
    );
  }
}

class _ShapePicker extends StatelessWidget {
  const _ShapePicker({
    required this.selected,
    required this.color,
    required this.color2,
    required this.onSelected,
  });

  final PillShape selected;
  final int color;
  final int? color2;
  final ValueChanged<PillShape> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final shape in PillShape.values)
          Semantics(
            button: true,
            selected: shape == selected,
            label: l.shapeName(shape.name),
            excludeSemantics: true,
            child: Tooltip(
              message: l.shapeName(shape.name),
              child: InkWell(
                borderRadius: BorderRadius.circular(Radii.card),
                onTap: () => onSelected(shape),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: shape == selected
                        ? scheme.secondaryContainer
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Radii.card),
                    border: Border.all(
                      width: 2,
                      color: shape == selected
                          ? scheme.primary
                          : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: PillIcon(
                    shape: shape,
                    color: Color(color),
                    color2: color2 == null ? null : Color(color2!),
                    size: 44,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ColorPicker extends StatelessWidget {
  const _ColorPicker({required this.selected, required this.onSelected});

  final int? selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Wrap(
      spacing: Spacing.sm,
      runSpacing: Spacing.sm,
      children: [
        for (final (i, c) in pillColors.indexed)
          Semantics(
            button: true,
            selected: c == selected,
            label: l.colorOption(i + 1),
            excludeSemantics: true,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onSelected(c),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Color(c),
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: c == selected ? 3 : 1,
                    color: c == selected
                        ? scheme.primary
                        : scheme.outlineVariant,
                  ),
                ),
                child: c == selected
                    ? Icon(
                        Icons.check,
                        color: Color(c).computeLuminance() > 0.5
                            ? Colors.black87
                            : Colors.white,
                      )
                    : null,
              ),
            ),
          ),
      ],
    );
  }
}
