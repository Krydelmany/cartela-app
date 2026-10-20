import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'paper.dart';

/// A penciled circle around the dose that is due. It draws itself, the way a
/// person circles something on a prescription with a pen: two passes, uneven.
class PencilRing extends StatelessWidget {
  final double width;
  final double height;
  final double progress;
  final int seed;
  final Color color;

  const PencilRing({
    super.key,
    required this.width,
    required this.height,
    required this.progress,
    required this.seed,
    this.color = Paper.ink,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _RingPainter(
        progress: progress.clamp(0.0, 1.0),
        seed: seed,
        color: color,
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final int seed;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.seed,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rng = math.Random(seed * 31 + 7);
    final phase1 = rng.nextDouble() * math.pi * 2;
    final phase2 = rng.nextDouble() * math.pi * 2;

    final cx = size.width / 2;
    final cy = size.height / 2;
    final rx = size.width / 2 - 2.5;
    final ry = size.height / 2 - 2.5;

    Path oval(double wobbleScale) {
      final path = Path();
      const steps = 72;
      for (var i = 0; i <= steps; i++) {
        final t = i / steps;
        final a = -0.6 + t * math.pi * 2;
        final wob = wobbleScale *
            (1 +
                0.038 * math.sin(a * 3 + phase1) +
                0.022 * math.sin(a * 5 + phase2));
        final x = cx + math.cos(a) * rx * wob;
        final y = cy + math.sin(a) * ry * wob;
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      path.close();
      return path;
    }

    void drawUpTo(Path path, double fraction, Paint paint) {
      for (final metric in path.computeMetrics()) {
        final clip = metric.length * fraction;
        if (clip <= 0) continue;
        canvas.drawPath(metric.extractPath(0, clip), paint);
      }
    }

    // Second, fainter pass, slightly larger and lagging — the pen went twice.
    drawUpTo(
      oval(1.035),
      (progress * 0.94).clamp(0.0, 1.0),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.22),
    );

    drawUpTo(
      oval(1.0),
      progress,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.55
        ..strokeCap = StrokeCap.round
        ..color = color.withOpacity(0.82),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.seed != seed ||
      oldDelegate.color != color;
}
