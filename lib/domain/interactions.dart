/// Supplement and medicine compatibility, from assets/interactions.json.
library;

import 'enums.dart';
import 'look.dart';
import 'schedule_rule.dart';

enum RuleType { avoid, separate, together }

/// Whether a substance is a supplement or a medicine.
enum SubstanceKind { supplement, drug }

/// Text in [uk], [en] and, when translated, Russian and Spanish; other
/// languages fall back to English.
String _pick(String code, String uk, String en, Map<String, String> more) =>
    switch (code) {
      'uk' => uk,
      'en' => en,
      _ => more[code] ?? en,
    };

Map<String, String> _moreLanguages(Map<String, dynamic> json) => {
  for (final code in const ['ru', 'es'])
    if (json[code] case final String t) code: t,
};

class Substance {
  const Substance({
    required this.key,
    required this.uk,
    required this.en,
    this.more = const {},
    this.aliases = const [],
    this.info,
    this.kind = SubstanceKind.supplement,
  });

  final String key;
  final String uk;
  final String en;

  /// Names in further languages (ru, es).
  final Map<String, String> more;
  final List<String> aliases;
  final SubstanceKind kind;

  /// How to take it and what to watch for, when the catalog has it.
  final SubstanceInfo? info;

  String name(String languageCode) => _pick(languageCode, uk, en, more);
}

/// A named reference with a link.
class Source {
  const Source({required this.name, required this.url});

  final String name;
  final String url;
}

/// Reference notes about a substance, in Ukrainian and English and,
/// when translated, Russian and Spanish.
class SubstanceInfo {
  const SubstanceInfo({
    required this.intake,
    required this.cautions,
    required this.sources,
  });

  factory SubstanceInfo.fromJson(Map<String, dynamic> json) => SubstanceInfo(
    intake: {
      for (final lang in const ['uk', 'en', 'ru', 'es'])
        if (json[lang] case final Map<String, dynamic> t)
          lang: t['intake'] as String,
    },
    cautions: {
      for (final lang in const ['uk', 'en', 'ru', 'es'])
        if (json[lang] case final Map<String, dynamic> t)
          lang: t['cautions'] as String,
    },
    sources: [
      for (final s in json['sources'] as List)
        Source(name: s['name'] as String, url: s['url'] as String),
    ],
  );

  final Map<String, String> intake;
  final Map<String, String> cautions;
  final List<Source> sources;

  String intakeIn(String languageCode) => intake[languageCode] ?? intake['en']!;

  String cautionsIn(String languageCode) =>
      cautions[languageCode] ?? cautions['en']!;
}

/// A ready-made supplement or medicine offered while typing a name.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.amount,
    required this.substances,
    required this.form,
    required this.shape,
    required this.color,
    this.color2,
    this.meal = MealRelation.any,
    this.url,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'] as String,
    name: json['name'] as String,
    brand: json['brand'] as String,
    amount: {
      for (final e in (json['amount'] as Map<String, dynamic>).entries)
        e.key: e.value as String,
    },
    substances: [for (final s in json['substances'] as List) s as String],
    form: MedForm.values.byName(json['form'] as String),
    shape: PillShape.values.byName(json['shape'] as String),
    color: int.parse(json['color'] as String),
    color2: switch (json['color2']) {
      final String c => int.parse(c),
      _ => null,
    },
    meal: MealRelation.values.byName((json['meal'] as String?) ?? 'any'),
    url: json['url'] as String?,
  );

  final String id;
  final String name;
  final String brand;

  /// What one unit holds, by language code.
  final Map<String, String> amount;
  final List<String> substances;
  final MedForm form;
  final PillShape shape;
  final int color;
  final int? color2;
  final MealRelation meal;

  /// The product's page.
  final String? url;

  /// Name to save, e.g. "Quercetin 500 mg (Best Naturals)".
  String get fullName => '$name ($brand)';

  String amountIn(String languageCode) => amount[languageCode] ?? amount['en']!;
}

class InteractionRule {
  const InteractionRule({
    required this.a,
    required this.b,
    required this.type,
    this.hours = 0,
    required this.uk,
    required this.en,
    this.more = const {},
    this.source = '',
    this.url,
  });

  final String a;
  final String b;
  final RuleType type;

  /// Minimum gap for [RuleType.separate].
  final int hours;
  final String uk;
  final String en;

  /// Text in further languages (ru, es).
  final Map<String, String> more;
  final String source;
  final String? url;

  String text(String languageCode) => _pick(languageCode, uk, en, more);
}

class InteractionCatalog {
  InteractionCatalog({
    required this.substances,
    required this.rules,
    this.products = const [],
  }) : _byKey = {for (final s in substances) s.key: s};

  factory InteractionCatalog.fromJson(Map<String, dynamic> json) =>
      InteractionCatalog(
        substances: [
          for (final s in json['substances'] as List)
            Substance(
              key: s['key'] as String,
              uk: s['uk'] as String,
              en: s['en'] as String,
              more: _moreLanguages(s as Map<String, dynamic>),
              aliases: [for (final a in s['aliases'] as List) a as String],
              kind: SubstanceKind.values.byName(
                (s['kind'] as String?) ?? 'supplement',
              ),
              info: switch (s['info']) {
                final Map<String, dynamic> info => SubstanceInfo.fromJson(info),
                _ => null,
              },
            ),
        ],
        rules: [
          for (final r in json['rules'] as List)
            InteractionRule(
              a: r['a'] as String,
              b: r['b'] as String,
              type: RuleType.values.byName(r['type'] as String),
              hours: (r['hours'] as int?) ?? 0,
              uk: r['uk'] as String,
              en: r['en'] as String,
              more: _moreLanguages(r as Map<String, dynamic>),
              source: (r['source'] as String?) ?? '',
              url: r['url'] as String?,
            ),
        ],
        products: [
          for (final p in (json['products'] as List?) ?? const [])
            Product.fromJson(p as Map<String, dynamic>),
        ],
      );

  final List<Substance> substances;
  final List<InteractionRule> rules;
  final List<Product> products;
  final Map<String, Substance> _byKey;

  Substance? substance(String key) => _byKey[key];

  /// Substances whose names appear in a medication name, e.g.
  /// "Магній B6" -> magnesium. An alias must start a word (after a space or
  /// a hyphen, so "Кальцій-Д3" finds vitamin D but "spironolactone" doesn't
  /// find iron); short aliases must match a whole word.
  Set<String> detect(String name) {
    final text =
        ' ${name.toLowerCase().replaceAll(RegExp(r'[^\p{L}\p{N}\-\x27]+', unicode: true), ' ')} ';
    bool has(String a) => a.length <= 3
        ? text.contains(' $a ') || text.contains('-$a ')
        : text.contains(' $a') || text.contains('-$a');
    return {
      for (final s in substances)
        if (s.aliases.any(has)) s.key,
    };
  }

  /// Rules that involve [key], for the reference page.
  List<InteractionRule> rulesAbout(String key) => [
    for (final r in rules)
      if (r.a == key || r.b == key) r,
  ];

  /// Substances where every word of [query] starts a word of the name or an
  /// alias; all of them for an empty query.
  List<Substance> searchSubstances(String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return substances;
    return [
      for (final s in substances)
        if (_substanceMatches(s, words)) s,
    ];
  }

  bool _substanceMatches(Substance s, List<String> words) {
    final haystack = [
      s.uk,
      s.en,
      ...s.aliases,
    ].join(' ').toLowerCase().split(RegExp(r'[\s(),-]+'));
    return words.every((w) => haystack.any((t) => t.startsWith(w)));
  }

  /// Whether the reference has anything to show for [s].
  bool hasGuide(Substance s) => s.info != null || rulesAbout(s.key).isNotEmpty;

  /// Products where every word of [query] starts a word of the product's
  /// name, brand or substance names.
  List<Product> searchProducts(String query) {
    final words = query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return const [];
    return [
      for (final p in products)
        if (_matches(p, words)) p,
    ];
  }

  bool _matches(Product p, List<String> words) {
    final haystack = [
      p.name,
      p.brand,
      for (final key in p.substances) ...[
        ?_byKey[key]?.uk,
        ?_byKey[key]?.en,
        ...?_byKey[key]?.more.values,
        ...?_byKey[key]?.aliases,
      ],
    ].join(' ').toLowerCase().split(RegExp(r'[\s()]+'));
    return words.every((w) => haystack.any((t) => t.startsWith(w)));
  }

  List<InteractionRule> rulesFor(Set<String> a, Set<String> b) => [
    for (final r in rules)
      if ((a.contains(r.a) && b.contains(r.b)) ||
          (a.contains(r.b) && b.contains(r.a)))
        r,
  ];
}

/// A medication as the checker sees it.
class InteractionMed {
  const InteractionMed({
    required this.id,
    required this.name,
    required this.substances,
    required this.rules,
  });

  final int id;
  final String name;
  final Set<String> substances;

  /// Active schedules.
  final List<ScheduleRule> rules;

  List<DoseTime> get times => [
    for (final r in rules)
      if (r.dayPattern != DayPattern.asNeeded) ...r.times,
  ];
}

class InteractionIssue {
  const InteractionIssue({
    required this.a,
    required this.b,
    required this.rule,
    this.timeA,
    this.timeB,
  });

  final InteractionMed a;
  final InteractionMed b;
  final InteractionRule rule;

  /// For [RuleType.separate]: the two dose times that are too close.
  final DoseTime? timeA;
  final DoseTime? timeB;

  bool get isWarning => rule.type != RuleType.together;

  bool involves(int id) => a.id == id || b.id == id;

  /// The other medication from [id]'s point of view.
  InteractionMed other(int id) => a.id == id ? b : a;

  /// Earliest time for [id]'s dose that keeps the gap, if it is the same day.
  DoseTime? suggestionFor(int id) {
    if (timeA == null || timeB == null) return null;
    final mine = a.id == id ? timeA! : timeB!;
    final theirs = a.id == id ? timeB! : timeA!;
    final gap = rule.hours * 60;
    final later = theirs.minuteOfDay + gap;
    final earlier = theirs.minuteOfDay - gap;
    // Move the way that needs the smaller shift.
    final candidates = [if (later < 24 * 60) later, if (earlier >= 0) earlier]
      ..sort(
        (x, y) => (x - mine.minuteOfDay).abs().compareTo(
          (y - mine.minuteOfDay).abs(),
        ),
      );
    if (candidates.isEmpty) return null;
    final m = candidates.first;
    return DoseTime(hour: m ~/ 60, minute: m % 60, dose: mine.dose);
  }
}

int _gapMinutes(DoseTime x, DoseTime y) {
  final d = (x.minuteOfDay - y.minuteOfDay).abs();
  return d < 24 * 60 - d ? d : 24 * 60 - d;
}

/// Every rule that applies between pairs of [meds]. A "separate" rule is
/// reported only when two dose times are closer than its gap (the closest
/// pair is shown).
List<InteractionIssue> findInteractions(
  InteractionCatalog catalog,
  List<InteractionMed> meds,
) {
  final issues = <InteractionIssue>[];
  for (var i = 0; i < meds.length; i++) {
    for (var j = i + 1; j < meds.length; j++) {
      final a = meds[i];
      final b = meds[j];
      for (final rule in catalog.rulesFor(a.substances, b.substances)) {
        if (rule.type != RuleType.separate) {
          issues.add(InteractionIssue(a: a, b: b, rule: rule));
          continue;
        }
        (DoseTime, DoseTime)? closest;
        var best = 1 << 30;
        for (final ta in a.times) {
          for (final tb in b.times) {
            final g = _gapMinutes(ta, tb);
            if (g < rule.hours * 60 && g < best) {
              best = g;
              closest = (ta, tb);
            }
          }
        }
        if (closest != null) {
          issues.add(
            InteractionIssue(
              a: a,
              b: b,
              rule: rule,
              timeA: closest.$1,
              timeB: closest.$2,
            ),
          );
        }
      }
    }
  }
  return issues;
}
