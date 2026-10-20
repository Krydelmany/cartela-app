import 'package:flutter/material.dart';
import 'paper.dart';

/// A rubber stamp that slams onto the page, ink uneven at the edges.
class LateStamp extends StatelessWidget {
  final String label;
  final double size;

  const LateStamp({
    super.key,
    this.label = 'atrasado',
    this.size = 8,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.85, end: 1.0),
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final ink = ((1.85 - value) / 0.85).clamp(0.0, 1.0);
        return Opacity(
          opacity: ink,
          child: Transform.rotate(
            angle: -0.10,
            child: Transform.scale(scale: value, child: child),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: size * 1.2,
          vertical: size * 0.42,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Paper.oxide.withOpacity(0.85), width: 1.3),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Stack(
          children: [
            // Double impression: stamp pressed twice.
            Positioned(
              left: 0.5,
              top: 0.4,
              child: Text(
                label,
                style: Hand.stamp(
                  size: size,
                  weight: 800,
                  color: Paper.oxide.withOpacity(0.45),
                  tracking: 1.6,
                ),
              ),
            ),
            Text(
              label,
              style: Hand.stamp(
                size: size,
                weight: 800,
                color: Paper.oxide,
                tracking: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
