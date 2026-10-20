import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'paper.dart';

/// The aluminum foil tears when a pill is pushed through. This paints the shards.
class ShardBurst extends StatelessWidget {
  final double progress;
  final int seed;
  final double width;
  final double height;

  const ShardBurst({
    super.key,
    required this.progress,
    required this.seed,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: _ShardPainter(
          progress: progress.clamp(0.0, 1.0),
          seed: seed,
        ),
      ),
    );
  }
}

class _ShardPainter extends CustomPainter {
  final double progress;
  final int seed;

  _ShardPainter({required this.progress, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;

    final rng = math.Random(seed * 53 + 101);
    final center = Offset(size.width / 2, size.height / 2);
    final spread = Curves.easeOutCubic.transform(progress);
    final fade = (1 - progress).clamp(0.0, 1.0);

    for (var i = 0; i < 9; i++) {
      final angle = rng.nextDouble() * math.pi * 2;
      final distance = (10 + rng.nextDouble() * 26) * spread;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * distance;
      final side = (2.2 + rng.nextDouble() * 4.2) * (0.4 + fade);
      final spin = angle + progress * (3 + rng.nextDouble() * 5);

      final path = Path()
        ..moveTo(0, -side)
        ..lineTo(side * 0.8, side * 0.6)
        ..lineTo(-side * 0.7, side * 0.35)
        ..close();

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(spin);
      canvas.drawPath(
        path,
        Paint()
          ..color = Color.lerp(Paper.foilHi, Paper.foilLo, rng.nextDouble())!
              .withOpacity(fade * 0.95),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ShardPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.seed != seed;
}
