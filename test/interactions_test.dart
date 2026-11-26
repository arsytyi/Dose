import 'dart:convert';
import 'dart:io';

import 'package:bady/domain/interactions.dart';
import 'package:bady/domain/schedule_rule.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final catalog = InteractionCatalog.fromJson(
    jsonDecode(File('assets/interactions.json').readAsStringSync())
        as Map<String, dynamic>,
  );

  ScheduleRule at(int hour, [int minute = 0]) => ScheduleRule(
    startDate: DateTime(2026, 11, 1),
    times: [DoseTime(hour: hour, minute: minute)],
  );

  InteractionMed med(int id, String name, Set<String> s, List<int> hours) =>
      InteractionMed(
        id: id,
        name: name,
        substances: s,
        rules: [for (final h in hours) at(h)],
      );

  test('every rule names known substances and has a source', () {
    final keys = {for (final s in catalog.substances) s.key};
    for (final r in catalog.rules) {
      expect(keys, contains(r.a));
      expect(keys, contains(r.b));
      expect(r.source, isNotEmpty);
      if (r.type == RuleType.separate) expect(r.hours, greaterThan(0));
    }
  });

  test('notes and products are complete and point at known substances', () {
    final keys = {for (final s in catalog.substances) s.key};
    expect(catalog.substances.length, keys.length, reason: 'duplicate keys');
    for (final s in catalog.substances) {
      final info = s.info;
      if (info == null) continue;
      for (final lang in ['uk', 'en']) {
        expect(info.intake[lang], isNotEmpty, reason: '${s.key} intake');
        expect(info.cautions[lang], isNotEmpty, reason: '${s.key} cautions');
      }
      expect(info.sources, isNotEmpty, reason: '${s.key} sources');
      for (final src in info.sources) {
        expect(src.url, startsWith('https://'));
      }
    }
    final ids = <String>{};
    for (final p in catalog.products) {
      expect(ids.add(p.id), isTrue, reason: 'duplicate product ${p.id}');
      expect(keys, containsAll(p.substances));
      expect(p.amount.keys, containsAll(['uk', 'en']));
      for (final k in p.substances) {
        expect(catalog.substance(k)!.info, isNotNull, reason: k);
      }
    }
  });

  test('finds products while typing', () {
    List<String> find(String q) => [
      for (final p in catalog.searchProducts(q)) p.id,
    ];
    expect(find('кверц'), ['best-naturals-quercetin-500']);
    expect(find('quercetin'), ['best-naturals-quercetin-500']);
    expect(find('ашваг'), ['swanson-ashwagandha-450']);
    expect(find('куркум'), ['doctors-best-curcumin-500']);
    expect(find("doctor's best"), hasLength(3));
    expect(find('вітамін d'), ['now-d3-5000']);
    expect(find('zinc 50'), ['le-zinc-50']);
    expect(find(' '), isEmpty);
  });

  test('detects new supplements from names', () {
    expect(catalog.detect('Куркумін з піперином'), {'curcumin', 'piperine'});
    expect(catalog.detect('Коензим Q10'), {'coq10'});
    expect(catalog.detect('Альфа-ліпоєва кислота 600'), {'alpha_lipoic_acid'});
    expect(catalog.detect('Ашваганда KSM-66'), {'ashwagandha'});
  });

  test('detects substances from names', () {
    expect(catalog.detect('Магній B6'), {'magnesium', 'vitamin_b6'});
    expect(catalog.detect('Кальцій D3 Нікомед'), {'calcium', 'vitamin_d'});
    expect(catalog.detect('Вітамін D3 2000 МО'), {'vitamin_d'});
    expect(catalog.detect('Сорбіфер Дурулес'), {'iron'});
    expect(catalog.detect('Omega-3'), {'omega3'});
    // Short aliases need a whole word: "Fe" is not inside "Coffee".
    expect(catalog.detect('Coffee'), isEmpty);
    expect(catalog.detect('Еутирокс 50'), {'levothyroxine'});
  });

  test('every alias finds its own substance', () {
    for (final s in catalog.substances) {
      for (final a in s.aliases) {
        expect(a, a.toLowerCase(), reason: '${s.key}: aliases are lowercase');
        expect(catalog.detect(a), contains(s.key), reason: '${s.key}: $a');
      }
    }
  });

  test('detects medicines by Ukrainian brand names', () {
    expect(catalog.detect('Ксарелто 20 мг'), {'doac'});
    expect(catalog.detect('Аторвастатин 20'), {'statin'});
    expect(catalog.detect('Нурофєн Форте'), {'nsaid'});
    expect(catalog.detect('Цитрамон-Дарниця'), {'aspirin', 'paracetamol'});
    expect(catalog.detect('Трипліксам'), {'ace_inhibitor', 'thiazide'});
    expect(catalog.detect('Олідетрим 2000'), {'vitamin_d'});
    expect(catalog.detect('Кальцій-Д3 Нікомед'), {'calcium', 'vitamin_d'});
    expect(catalog.detect('Магне-B6'), {'magnesium', 'vitamin_b6'});
    expect(catalog.detect('Атоксіл'), {'enterosorbent'});
    // "iron" inside a longer word is not iron.
    expect(catalog.detect('Spironolactone'), {'potassium_sparing'});
  });

  test('medicines are marked as drugs', () {
    for (final k in ['statin', 'doac', 'warfarin', 'levothyroxine', 'nsaid']) {
      expect(catalog.substance(k)!.kind, SubstanceKind.drug, reason: k);
    }
    expect(catalog.substance('magnesium')!.kind, SubstanceKind.supplement);
  });

  test('every substance has something to show in the guide', () {
    for (final s in catalog.substances) {
      expect(catalog.hasGuide(s), isTrue, reason: s.key);
    }
  });

  test('searches substances by name, alias and brand', () {
    List<String> keys(String q) => [
      for (final s in catalog.searchSubstances(q)) s.key,
    ];
    expect(keys('ксарел'), ['doac']);
    expect(keys('вітамін b12'), ['vitamin_b12']);
    expect(keys('звіробій'), ['st_johns_wort']);
    expect(catalog.searchSubstances(''), hasLength(catalog.substances.length));
  });

  test('two painkillers with paracetamol are flagged', () {
    final issues = findInteractions(catalog, [
      med(1, 'Цитрамон', catalog.detect('Цитрамон'), [9]),
      med(2, 'Колдрекс', catalog.detect('Колдрекс'), [9]),
    ]);
    expect(issues.map((i) => i.rule.a), contains('paracetamol'));
  });

  test('St. John\'s wort and an antidepressant are flagged', () {
    final issues = findInteractions(catalog, [
      med(1, 'Звіробій', {'st_johns_wort'}, [9]),
      med(2, 'Золофт', catalog.detect('Золофт 50'), [21]),
    ]);
    expect(issues.single.rule.type, RuleType.avoid);
  });

  test('iron and calcium too close in time are flagged with a fix', () {
    final iron = med(1, 'Залізо', {'iron'}, [9]);
    final calcium = med(2, 'Кальцій', {'calcium'}, [10]);
    final issues = findInteractions(catalog, [iron, calcium]);
    expect(issues, hasLength(1));
    final i = issues.single;
    expect(i.isWarning, isTrue);
    expect(i.rule.hours, 2);
    expect(i.suggestionFor(2), const DoseTime(hour: 11, minute: 0));
    expect(i.suggestionFor(1), const DoseTime(hour: 8, minute: 0));
  });

  test('far enough apart is fine', () {
    final issues = findInteractions(catalog, [
      med(1, 'Залізо', {'iron'}, [9]),
      med(2, 'Кальцій', {'calcium'}, [21]),
    ]);
    expect(issues, isEmpty);
  });

  test('gaps wrap around midnight', () {
    final issues = findInteractions(catalog, [
      med(1, 'Залізо', {'iron'}, [23]),
      med(2, 'Кальцій', {'calcium'}, [0]),
    ]);
    expect(issues, hasLength(1));
  });

  test('avoid rules apply regardless of time; good pairs are tips', () {
    final issues = findInteractions(catalog, [
      med(1, 'Варфарин', {'warfarin'}, [8]),
      med(2, 'K2', {'vitamin_k', 'vitamin_d'}, [20]),
      med(3, 'Кальцій', {'calcium'}, [13]),
    ]);
    final types = {for (final i in issues) i.rule.type};
    expect(types, {RuleType.avoid, RuleType.together});
    expect(issues.where((i) => i.isWarning), hasLength(1));
  });
}
