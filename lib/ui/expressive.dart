/// Building blocks in the Material 3 Expressive style: grouped rounded
/// tiles, connected button groups and a wavy progress ring.
library;

import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import 'theme.dart';

/// Tiles of one section as a column of rounded cards with small gaps: the
/// group has large outer corners, inner corners are small (as in the
/// Android 16 settings).
class TileGroup extends StatelessWidget {
  const TileGroup({super.key, required this.children});

  final List<Widget> children;

  static const _outer = Radius.circular(20);
  static const _inner = Radius.circular(4);

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.surfaceContainer;
    final n = children.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
      child: Column(
        children: [
          for (final (i, child) in children.indexed)
            Padding(
              padding: EdgeInsets.only(top: i == 0 ? 0 : 2),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: i == 0 ? _outer : _inner,
                  bottom: i == n - 1 ? _outer : _inner,
                ),
                child: Material(color: color, child: child),
              ),
            ),
        ],
      ),
    );
  }
}

/// One choice of a [ButtonGroup].
class GroupChoice<T> {
  const GroupChoice(this.value, this.label, {this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Connected single-choice buttons. The chosen one is filled and fully
/// rounded; the others are tonal with small inner corners.
class ButtonGroup<T> extends StatelessWidget {
  const ButtonGroup({
    super.key,
    required this.choices,
    required this.selected,
    required this.onChanged,
  });

  final List<GroupChoice<T>> choices;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    const full = Radius.circular(24);
    const inner = Radius.circular(8);
    final n = choices.length;
    return Row(
      children: [
        for (final (i, c) in choices.indexed) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: Builder(
              builder: (context) {
                final on = c.value == selected;
                final fg = on ? scheme.onPrimary : scheme.onSecondaryContainer;
                final radius = on
                    ? const BorderRadius.all(full)
                    : BorderRadius.horizontal(
                        left: i == 0 ? full : inner,
                        right: i == n - 1 ? full : inner,
                      );
                return Semantics(
                  button: true,
                  selected: on,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    height: 48,
                    decoration: BoxDecoration(
                      color: on ? scheme.primary : scheme.secondaryContainer,
                      borderRadius: radius,
                    ),
                    child: Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        customBorder: RoundedRectangleBorder(
                          borderRadius: radius,
                        ),
                        onTap: () => onChanged(c.value),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: Spacing.sm,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (c.icon case final icon?) ...[
                                  Icon(icon, size: 18, color: fg),
                                  const SizedBox(width: Spacing.xs),
                                ],
                                Flexible(
                                  child: Text(
                                    c.label,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: fg,
                                      fontWeight: on
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

/// Progress ring whose filled part is a gentle wave.
class WavyProgressRing extends StatelessWidget {
  const WavyProgressRing({
    super.key,
    required this.value,
    required this.color,
    required this.trackColor,
    this.size = 64,
  });

  final double value;
  final Color color;
  final Color trackColor;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: _WavyRingPainter(
        value: value.clamp(0, 1).toDouble(),
        color: color,
        trackColor: trackColor,
      ),
    ),
  );
}

class _WavyRingPainter extends CustomPainter {
  _WavyRingPainter({
    required this.value,
    required this.color,
    required this.trackColor,
  });

  final double value;
  final Color color;
  final Color trackColor;

  static const _stroke = 4.5;
  static const _amplitude = 1.0;
  static const _waves = 11;
  static const _gap = 0.28;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - _stroke / 2 - _amplitude;
    const start = -math.pi / 2;
    final sweep = 2 * math.pi * value;
    Paint paint(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _stroke
      ..strokeCap = StrokeCap.round;

    // Track: the rest of the circle, plain, with a small gap at both ends.
    final trackSweep = 2 * math.pi - sweep - (value > 0 ? 2 * _gap : 0);
    if (trackSweep > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        start + sweep + (value > 0 ? _gap : 0),
        trackSweep,
        false,
        paint(trackColor),
      );
    }
    if (value <= 0) return;
    final path = Path();
    const steps = 240;
    for (var i = 0; i <= steps; i++) {
      final t = start + sweep * i / steps;
      final rr = r + _amplitude * math.sin(_waves * (t - start));
      final p = c + Offset(math.cos(t), math.sin(t)) * rr;
      i == 0 ? path.moveTo(p.dx, p.dy) : path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(path, paint(color));
  }

  @override
  bool shouldRepaint(_WavyRingPainter old) =>
      old.value != value || old.color != color || old.trackColor != trackColor;
}
