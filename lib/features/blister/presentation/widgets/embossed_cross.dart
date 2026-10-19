import 'package:flutter/material.dart';

/// Desenha o relevo estrutural em formato de cruz (+) prensado no plástico/alumínio
/// como visto no centro da Foto 2.
class EmbossedCross extends StatelessWidget {
  final double size;

  const EmbossedCross({
    super.key,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _EmbossedCrossPainter(),
      ),
    );
  }
}

class _EmbossedCrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final armLength = size.width * 0.78;
    final armThickness = size.width * 0.26;
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

    // Sombra externa escura do baixo-relevo
    canvas.save();
    canvas.translate(1.5, 2.0);
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withOpacity(0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.restore();

    // Corpo metálico prensado
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9EA6B2),
            Color(0xFFE2E6EC),
            Color(0xFF8B93A0),
          ],
        ).createShader(rect),
    );

    // Brilho especular na borda interna
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.65),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
