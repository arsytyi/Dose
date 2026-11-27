import 'package:material_ui/material_ui.dart';

/// PROTOTYPE: accent variants for screenshots ('now', 'a', 'b').
const accentVariant = String.fromEnvironment(
  'SHOTS_VARIANT',
  defaultValue: 'now',
);
bool get accentsOn => accentVariant != 'now';

class Accents {
  Accents(BuildContext context)
    : dark = Theme.of(context).brightness == Brightness.dark;

  final bool dark;

  Color get good => dark ? const Color(0xFF6FD39A) : const Color(0xFF2E9E5B);
  Color get warn => dark ? const Color(0xFFF5C04A) : const Color(0xFFC77700);
  Color get bad => dark ? const Color(0xFFFF8A80) : const Color(0xFFD9534F);
  Color get flame => dark ? const Color(0xFFFFA24D) : const Color(0xFFF26B1D);
  Color get morning =>
      dark ? const Color(0xFFFFB36B) : const Color(0xFFE8862A);
  Color get afternoon =>
      dark ? const Color(0xFFFFD45C) : const Color(0xFFD9A400);
  Color get evening =>
      dark ? const Color(0xFFA9A4FF) : const Color(0xFF5B55D6);
  Color get night => dark ? const Color(0xFF8FB4FF) : const Color(0xFF3F64C8);

  Color byFraction(double? f) => f == null
      ? Colors.transparent
      : f >= 0.9
      ? good
      : f >= 0.6
      ? warn
      : bad;

  /// Tonal circle colors for settings icons.
  List<Color> get tones => dark
      ? const [
          Color(0xFF8FB4FF),
          Color(0xFFFFB36B),
          Color(0xFF6FD39A),
          Color(0xFFA9A4FF),
          Color(0xFFFF8A80),
          Color(0xFFFFD45C),
        ]
      : const [
          Color(0xFF3F64C8),
          Color(0xFFE8862A),
          Color(0xFF2E9E5B),
          Color(0xFF5B55D6),
          Color(0xFFD9534F),
          Color(0xFFC79100),
        ];
}

/// Settings leading icon in a tinted circle.
class ToneIcon extends StatelessWidget {
  const ToneIcon(this.icon, this.index, {super.key});
  final IconData icon;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (!accentsOn) return Icon(icon);
    final tones = Accents(context).tones;
    final c = tones[index % tones.length];
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.16),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: c),
    );
  }
}
