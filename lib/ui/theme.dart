import 'package:material_ui/material_ui.dart';

/// Design tokens. See design-system/MASTER.md.
abstract final class Spacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Space below scrolling lists so the FAB never covers the last row.
  static const fabClearance = 96.0;
}

abstract final class Radii {
  static const card = 12.0;
}

const _seed = Color(0xFF2E7D6B);

/// Small bright accents on top of the calm teal theme: dose outcomes, the
/// parts of the day, the streak flame and settings icons. Each is shown next
/// to text or a number, never as the only signal. See design-system/MASTER.md.
@immutable
class Accents extends ThemeExtension<Accents> {
  const Accents({
    required this.good,
    required this.warn,
    required this.bad,
    required this.flame,
    required this.morning,
    required this.afternoon,
    required this.evening,
    required this.night,
  });

  /// Light values are dark enough for text and icons on light surfaces.
  static const light = Accents(
    good: Color(0xFF16753E),
    warn: Color(0xFFA65F00),
    bad: Color(0xFFC4413C),
    flame: Color(0xFFE8590C),
    morning: Color(0xFFD9731A),
    afternoon: Color(0xFFB88A00),
    evening: Color(0xFF5B55D6),
    night: Color(0xFF3F64C8),
  );

  static const dark = Accents(
    good: Color(0xFF6FD39A),
    warn: Color(0xFFF5C04A),
    bad: Color(0xFFFF8A80),
    flame: Color(0xFFFFA24D),
    morning: Color(0xFFFFB36B),
    afternoon: Color(0xFFFFD45C),
    evening: Color(0xFFA9A4FF),
    night: Color(0xFF8FB4FF),
  );

  /// Taken, and days at 90% or more.
  final Color good;

  /// Skipped, and days from 60% to 89%.
  final Color warn;

  /// Not marked, and days under 60%.
  final Color bad;
  final Color flame;
  final Color morning;
  final Color afternoon;
  final Color evening;
  final Color night;

  /// Tints for settings icons, in a fixed order.
  List<Color> get tones => [night, morning, good, evening, bad, afternoon];

  /// Color for a share of doses taken (0..1).
  Color forAdherence(double fraction) => fraction >= 0.9
      ? good
      : fraction >= 0.6
      ? warn
      : bad;

  static Accents of(BuildContext context) =>
      Theme.of(context).extension<Accents>() ??
      (Theme.of(context).brightness == Brightness.dark ? dark : light);

  @override
  Accents copyWith() => this;

  @override
  Accents lerp(Accents? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return Accents(
      good: c(good, other.good),
      warn: c(warn, other.warn),
      bad: c(bad, other.bad),
      flame: c(flame, other.flame),
      morning: c(morning, other.morning),
      afternoon: c(afternoon, other.afternoon),
      evening: c(evening, other.evening),
      night: c(night, other.night),
    );
  }
}

/// A settings icon in a softly tinted circle. [index] picks the tint.
class TonalIcon extends StatelessWidget {
  const TonalIcon(this.icon, {super.key, required this.index});

  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    final tones = Accents.of(context).tones;
    final color = tones[index % tones.length];
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: color),
    );
  }
}

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  const border = OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(Radii.card)),
  );
  return base.copyWith(
    extensions: [brightness == Brightness.dark ? Accents.dark : Accents.light],
    inputDecorationTheme: const InputDecorationTheme(border: border),
    cardTheme: const CardThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Radii.card)),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: Spacing.lg),
      minVerticalPadding: Spacing.sm,
    ),
    textTheme: base.textTheme.copyWith(
      titleLarge: base.textTheme.titleLarge?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
      titleMedium: base.textTheme.titleMedium?.copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}

/// Text style for a dose time, e.g. "08:00".
TextStyle? timeStyle(BuildContext context, {bool muted = false}) {
  final theme = Theme.of(context);
  return theme.textTheme.titleMedium?.copyWith(
    fontWeight: FontWeight.w600,
    color: muted
        ? theme.colorScheme.onSurfaceVariant
        : theme.colorScheme.primary,
  );
}
