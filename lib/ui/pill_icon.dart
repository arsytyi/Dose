import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

import '../data/database.dart';
import '../domain/look.dart';

/// Vector drawing of a pill, capsule, bottle and so on in the
/// medication's colors. Used in lists, the pillbox and notifications.
class PillPainter extends CustomPainter {
  PillPainter({required this.shape, required this.color, this.color2});

  final PillShape shape;
  final Color color;
  final Color? color2;

  static Color _shade(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color get _outline => color.computeLuminance() > 0.6
      ? const Color(0xFF8A8F98)
      : _shade(color, 0.22);

  Paint _fill(Color c) => Paint()
    ..color = c
    ..isAntiAlias = true;

  Paint _stroke(double w, [Color? c]) => Paint()
    ..color = c ?? _outline
    ..style = PaintingStyle.stroke
    ..strokeWidth = w
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  Paint get _shine => Paint()..color = const Color(0x73FFFFFF);

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height);
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);
    final w = s * 0.05; // outline width
    switch (shape) {
      case PillShape.roundTablet:
        final r = s * 0.38;
        canvas.drawCircle(Offset.zero, r, _fill(color));
        canvas.drawCircle(Offset.zero, r * 0.78, _stroke(w * 0.5));
        canvas.drawLine(
          Offset(-r * 0.6, 0),
          Offset(r * 0.6, 0),
          _stroke(w * 0.8),
        );
        canvas.drawCircle(Offset.zero, r, _stroke(w));
      case PillShape.ovalTablet:
        canvas.rotate(-math.pi / 6);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: s * 0.86,
          height: s * 0.46,
        );
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(s * 0.23));
        canvas.drawRRect(rr, _fill(color));
        canvas.drawLine(
          Offset(-s * 0.26, 0),
          Offset(s * 0.26, 0),
          _stroke(w * 0.8),
        );
        canvas.drawRRect(rr, _stroke(w));
      case PillShape.capsule:
        canvas.rotate(-math.pi / 5);
        final len = s * 0.9, th = s * 0.38;
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: len,
          height: th,
        );
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(th / 2));
        canvas.save();
        canvas.clipRRect(rr);
        canvas.drawRect(
          Rect.fromLTRB(rect.left, rect.top, 0, rect.bottom),
          _fill(color2 ?? _shade(color, 0.18)),
        );
        canvas.drawRect(
          Rect.fromLTRB(0, rect.top, rect.right, rect.bottom),
          _fill(color),
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(
              rect.left + th * 0.3,
              rect.top + th * 0.16,
              len - th * 0.6,
              th * 0.16,
            ),
            Radius.circular(th * 0.08),
          ),
          _shine,
        );
        canvas.restore();
        canvas.drawLine(
          Offset(0, rect.top),
          Offset(0, rect.bottom),
          _stroke(w * 0.8),
        );
        canvas.drawRRect(rr, _stroke(w));
      case PillShape.softgel:
        canvas.rotate(-math.pi / 5);
        final rect = Rect.fromCenter(
          center: Offset.zero,
          width: s * 0.78,
          height: s * 0.5,
        );
        canvas.drawOval(rect, _fill(color.withValues(alpha: 0.92)));
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(-s * 0.12, -s * 0.09),
            width: s * 0.26,
            height: s * 0.11,
          ),
          _shine,
        );
        canvas.drawOval(rect, _stroke(w));
      case PillShape.dropper:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.22, -s * 0.06, s * 0.44, s * 0.46),
          Radius.circular(s * 0.08),
        );
        final neck = Rect.fromLTWH(-s * 0.1, -s * 0.18, s * 0.2, s * 0.13);
        final bulb = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.08, -s * 0.42, s * 0.16, s * 0.25),
          Radius.circular(s * 0.08),
        );
        canvas.drawRRect(body, _fill(color));
        canvas.drawRect(neck, _fill(_shade(color, 0.1)));
        canvas.drawRRect(bulb, _fill(color2 ?? const Color(0xFF37474F)));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-s * 0.14, s * 0.06, s * 0.28, s * 0.2),
            Radius.circular(s * 0.03),
          ),
          _fill(const Color(0xE6FFFFFF)),
        );
        canvas.drawRRect(body, _stroke(w));
        canvas.drawRect(neck, _stroke(w * 0.8));
        canvas.drawRRect(bulb, _stroke(w * 0.8));
      case PillShape.bottle:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.24, -s * 0.2, s * 0.48, s * 0.6),
          Radius.circular(s * 0.1),
        );
        final cap = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.16, -s * 0.4, s * 0.32, s * 0.18),
          Radius.circular(s * 0.04),
        );
        canvas.drawRRect(body, _fill(color));
        canvas.drawRRect(cap, _fill(color2 ?? const Color(0xFF37474F)));
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(-s * 0.18, -s * 0.04, s * 0.36, s * 0.24),
            Radius.circular(s * 0.03),
          ),
          _fill(const Color(0xE6FFFFFF)),
        );
        canvas.drawRRect(body, _stroke(w));
        canvas.drawRRect(cap, _stroke(w * 0.8));
      case PillShape.sachet:
        final path = Path();
        const teeth = 6;
        final l = -s * 0.32, r = s * 0.32, t = -s * 0.38, b = s * 0.38;
        final tw = (r - l) / teeth;
        path.moveTo(l, t);
        for (var i = 0; i < teeth; i++) {
          path.lineTo(l + tw * (i + 0.5), t + s * 0.05);
          path.lineTo(l + tw * (i + 1), t);
        }
        path.lineTo(r, b);
        for (var i = teeth; i > 0; i--) {
          path.lineTo(l + tw * (i - 0.5), b - s * 0.05);
          path.lineTo(l + tw * (i - 1), b);
        }
        path.close();
        canvas.drawPath(path, _fill(color));
        canvas.drawRect(
          Rect.fromLTRB(l, -s * 0.1, r, s * 0.1),
          _fill(color2 ?? const Color(0xE6FFFFFF)),
        );
        canvas.drawPath(path, _stroke(w));
      case PillShape.syringe:
        canvas.rotate(math.pi / 4);
        final barrel = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.13, -s * 0.3, s * 0.26, s * 0.5),
          Radius.circular(s * 0.04),
        );
        // Liquid in the lower part of the barrel.
        canvas.drawRRect(barrel, _fill(const Color(0xF2FFFFFF)));
        canvas.drawRect(
          Rect.fromLTWH(-s * 0.13, -s * 0.02, s * 0.26, s * 0.22),
          _fill(color),
        );
        canvas.drawLine(
          Offset(0, -s * 0.3),
          Offset(0, -s * 0.44),
          _stroke(w * 1.4, const Color(0xFF546E7A)),
        );
        canvas.drawLine(
          Offset(-s * 0.12, -s * 0.45),
          Offset(s * 0.12, -s * 0.45),
          _stroke(w * 1.4, const Color(0xFF546E7A)),
        );
        canvas.drawLine(
          Offset(0, s * 0.2),
          Offset(0, s * 0.44),
          _stroke(w * 0.6, const Color(0xFF78909C)),
        );
        canvas.drawRRect(barrel, _stroke(w));
      case PillShape.spray:
        final body = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.18, -s * 0.12, s * 0.36, s * 0.52),
          Radius.circular(s * 0.08),
        );
        final head = RRect.fromRectAndRadius(
          Rect.fromLTWH(-s * 0.1, -s * 0.34, s * 0.2, s * 0.2),
          Radius.circular(s * 0.04),
        );
        canvas.drawRRect(body, _fill(color));
        canvas.drawRRect(head, _fill(color2 ?? const Color(0xFF37474F)));
        final mist = _fill(_outline.withValues(alpha: 0.7));
        for (final (dx, dy) in [(0.2, -0.3), (0.28, -0.24), (0.3, -0.34)]) {
          canvas.drawCircle(Offset(s * dx, s * dy), s * 0.025, mist);
        }
        canvas.drawRRect(body, _stroke(w));
        canvas.drawRRect(head, _stroke(w * 0.8));
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PillPainter old) =>
      old.shape != shape || old.color != color || old.color2 != color2;
}

class PillIcon extends StatelessWidget {
  const PillIcon({
    super.key,
    required this.shape,
    required this.color,
    this.color2,
    this.size = 32,
  });

  PillIcon.of(Medication m, {super.key, this.size = 32})
    : shape = m.pillShape,
      color = Color(m.color),
      color2 = m.color2 == null ? null : Color(m.color2!);

  final PillShape shape;
  final Color color;
  final Color? color2;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(
      painter: PillPainter(shape: shape, color: color, color2: color2),
    ),
  );
}

/// Pill drawing on a neutral circle; decorative, the name sits next to it.
class PillAvatar extends StatelessWidget {
  const PillAvatar(this.medication, {super.key, this.size = 40});

  final Medication medication;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: PillIcon.of(medication, size: size * 0.78),
    ),
  );
}

/// PNG of a pill for the notification's large icon.
Future<Uint8List> renderPillPng({
  required PillShape shape,
  required int color,
  int? color2,
  int size = 192,
}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final d = size.toDouble();
  canvas.drawCircle(
    Offset(d / 2, d / 2),
    d / 2,
    Paint()..color = const Color(0xFFEFF3F1),
  );
  PillPainter(
    shape: shape,
    color: Color(color),
    color2: color2 == null ? null : Color(color2),
  ).paint(canvas, Size(d, d));
  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}
