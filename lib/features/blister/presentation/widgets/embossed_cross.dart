import 'package:flutter/material.dart';
import '../../../../core/design/paper.dart';

/// The pressed cross relief found between the blisters of one of the packs.
class EmbossedCross extends StatelessWidget {
  final double size;

  const EmbossedCross({super.key, this.size = 44});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _CrossPainter()),
    );
  }
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final armLength = size.width * 0.76;
    final armThickness = size.width * 0.24;
    final radius = Radius.circular(armThickness / 2);

    final horizontal = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: armLength, height: armThickness),
      radius,
    );
    final vertical = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: armThickness, height: armLength),
      radius,
    );
    final path = Path()
      ..addRRect(horizontal)
      ..addRRect(vertical);

    // The relief sits in a shadow, like it is pressed into the foil.
    canvas.save();
    canvas.translate(1.2, 1.6);
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0x55201E18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.2),
    );
    canvas.restore();

    final rect = Offset.zero & size;
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Paper.foilLo, Paper.foilHi, Paper.foilMid],
        ).createShader(rect),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = Colors.white.withOpacity(0.6),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
