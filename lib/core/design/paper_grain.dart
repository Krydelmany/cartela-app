import 'dart:math' as math;
import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import 'paper.dart';

/// Static paper fibre. Sits in the scaffold background (behind the scroll),
/// inside a RepaintBoundary so it is rasterised once.
class PaperGrain extends StatelessWidget {
  const PaperGrain({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          painter: _GrainPainter(),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(11);
    const step = 8.0;

    final dark = <Offset>[];
    final mid = <Offset>[];
    final light = <Offset>[];

    for (double y = 0; y < size.height; y += step) {
      for (double x = 0; x < size.width; x += step) {
        final p = Offset(
          x + rng.nextDouble() * step,
          y + rng.nextDouble() * step,
        );
        final roll = rng.nextDouble();
        if (roll < 0.55) {
          dark.add(p);
        } else if (roll < 0.85) {
          mid.add(p);
        } else {
          light.add(p);
        }
      }
    }

    void dots(List<Offset> pts, Color color, double width) {
      if (pts.isEmpty) return;
      canvas.drawPoints(
        PointMode.points,
        pts,
        Paint()
          ..color = color
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    // One draw call per opacity bucket instead of one per dot.
    dots(dark, Paper.ink.withOpacity(0.030), 1.1);
    dots(mid, Paper.ink.withOpacity(0.018), 1.4);
    dots(light, Colors.white.withOpacity(0.30), 1.6);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A line that looks drawn with a pen, not with a rule: two passes, slight wobble.
class HandDrawnRule extends StatelessWidget {
  final Color color;

  const HandDrawnRule({super.key, this.color = Paper.rule});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 6,
      child: CustomPaint(
        size: Size.infinite,
        painter: _RulePainter(color),
      ),
    );
  }
}

class _RulePainter extends CustomPainter {
  final Color color;

  _RulePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    for (var pass = 0; pass < 2; pass++) {
      final path = Path();
      final amp = pass == 0 ? 0.7 : 0.45;
      final yBase = 2.0 + pass * 1.1;
      for (double x = 0; x <= size.width; x += 4) {
        final y = yBase + math.sin(x / 37 + pass * 1.9) * amp;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = pass == 0 ? 1.2 : 0.8
          ..strokeCap = StrokeCap.round
          ..color = color.withOpacity(pass == 0 ? 0.9 : 0.35),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RulePainter oldDelegate) =>
      oldDelegate.color != color;
}
