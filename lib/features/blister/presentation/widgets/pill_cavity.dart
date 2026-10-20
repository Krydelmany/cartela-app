import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/late_stamp.dart';
import '../../../../core/design/motion.dart';
import '../../../../core/design/paper.dart';
import '../../../../core/design/pencil_ring.dart';
import '../../../../core/design/shard_burst.dart';
import '../../domain/medication_pack.dart';
import '../../domain/pill_shape.dart';

/// One cavity of the blister: the pill, the plastic dome, and the torn foil
/// left behind once it is pushed through.
class PillCavity extends StatefulWidget {
  final int pillIndex;
  final PillVisualSpec spec;
  final CavityStatus status;
  final VoidCallback onTap;

  const PillCavity({
    super.key,
    required this.pillIndex,
    required this.spec,
    required this.status,
    required this.onTap,
  });

  @override
  State<PillCavity> createState() => _PillCavityState();
}

class _PillCavityState extends State<PillCavity>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fall;
  bool _wasTaken = false;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _wasTaken = widget.status == CavityStatus.taken;
    _fall = AnimationController(vsync: this, duration: Motion.fall);
    if (_wasTaken) _fall.value = 1;
  }

  @override
  void didUpdateWidget(covariant PillCavity oldWidget) {
    super.didUpdateWidget(oldWidget);
    final taken = widget.status == CavityStatus.taken;
    if (taken && !_wasTaken) {
      _fall.forward(from: 0);
    } else if (!taken && _wasTaken) {
      _fall.reverse();
    }
    _wasTaken = taken;
  }

  @override
  void dispose() {
    _fall.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.selectionClick();
    widget.onTap();
  }

  String get _semanticLabel {
    final number = widget.pillIndex + 1;
    switch (widget.status) {
      case CavityStatus.taken:
        return 'Comprimido $number, já tomado. Toque para devolver à cartela.';
      case CavityStatus.overdue:
        return 'Comprimido $number, atrasado. Toque para marcar como tomado.';
      case CavityStatus.currentTarget:
        return 'Comprimido $number, o de agora. Toque para marcar como tomado.';
      case CavityStatus.intact:
        return 'Comprimido $number, ainda na cartela. '
            'Toque para marcar como tomado.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final width = spec.width + 14;
    final height = spec.height + 14;

    final taken = widget.status == CavityStatus.taken;
    final overdue = widget.status == CavityStatus.overdue;
    final target = widget.status == CavityStatus.currentTarget;

    return Semantics(
      button: true,
      label: _semanticLabel,
      onTap: _handleTap,
      excludeSemantics: true,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _handleTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: Motion.quick,
        curve: Curves.easeOut,
        child: SizedBox(
          width: width,
          height: height,
          child: AnimatedBuilder(
            animation: _fall,
            builder: (context, _) {
              final fall = Curves.easeInCubic.transform(_fall.value);

              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(width, height),
                    painter: _BedPainter(
                      taken: taken,
                      seed: widget.pillIndex,
                    ),
                  ),

                  // The pill itself, falling out of the pack.
                  if (_fall.value < 1)
                    Opacity(
                      opacity: (1 - fall).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, 30 * fall),
                        child: Transform.rotate(
                          angle: 0.55 * fall,
                          child: _Pill(spec: spec),
                        ),
                      ),
                    ),

                  // The plastic dome. It survives the pill falling a moment longer.
                  if (!taken)
                    IgnorePointer(
                      child: _Dome(width: width, height: height),
                    ),

                  if (target)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: 1),
                      duration: Motion.ring,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, child) => PencilRing(
                        width: width + 7,
                        height: height + 7,
                        progress: value,
                        seed: widget.pillIndex,
                      ),
                    ),

                  if (overdue) ...[
                    PencilRing(
                      width: width + 7,
                      height: height + 7,
                      progress: 1,
                      seed: widget.pillIndex,
                      color: Paper.oxide,
                    ),
                    Positioned(
                      bottom: 5,
                      child: LateStamp(label: 'atrasado', size: 7),
                    ),
                  ],

                  ShardBurst(
                    progress: _fall.value,
                    seed: widget.pillIndex,
                    width: width + 34,
                    height: height + 34,
                  ),

                  Positioned(
                    right: 4,
                    bottom: 2,
                    child: IgnorePointer(
                      child: Text(
                        '${widget.pillIndex + 1}',
                        style: Hand.numeric(
                          size: 8,
                          weight: 600,
                          color: taken
                              ? Paper.inkFaint.withOpacity(0.55)
                              : Paper.ink.withOpacity(0.35),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      ),
    );
  }
}

/// The pill body: warm white light from the top-left, one groove.
class _Pill extends StatelessWidget {
  final PillVisualSpec spec;

  const _Pill({required this.spec});

  @override
  Widget build(BuildContext context) {
    final radius =
        BorderRadius.circular(math.min(spec.width, spec.height) / 2);

    return Container(
      width: spec.width,
      height: spec.height,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: LinearGradient(
          begin: Alignment(-0.7, -1),
          end: Alignment(0.6, 1),
          colors: [
            Color.lerp(spec.color, Colors.white, 0.38)!,
            spec.color,
            Color.lerp(spec.color, spec.shadowColor, 0.42)!,
          ],
          stops: const [0.0, 0.48, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: spec.shadowColor.withOpacity(0.55),
            blurRadius: 5,
            offset: const Offset(1.2, 3),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.55),
            blurRadius: 2,
            offset: const Offset(-1, -1),
          ),
        ],
      ),
      child: spec.hasScoreLine
          ? Center(
              child: Container(
                width: 2.0,
                height: spec.height * 0.8,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      spec.shadowColor.withOpacity(0.55),
                      Colors.white.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

/// A faint sheen: the pill sits under a transparent plastic bubble.
class _Dome extends StatelessWidget {
  final double width;
  final double height;

  const _Dome({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(math.min(width, height) / 2),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.42),
              Colors.white.withOpacity(0.0),
              Colors.white.withOpacity(0.12),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 0.9,
          ),
        ),
      ),
    );
  }
}

/// The seat of the cavity. Sealed = a pressed ring. Opened = torn, dark foil.
class _BedPainter extends CustomPainter {
  final bool taken;
  final int seed;

  _BedPainter({required this.taken, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(math.min(size.width, size.height) / 2);
    final bed = RRect.fromRectAndRadius(rect.deflate(3), radius);

    if (!taken) {
      // Pressed ring: shadow above, light below. Cheap, but it reads as depth.
      canvas.drawRRect(
        bed,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
          ..color = const Color(0x22221F18),
      );
      canvas.drawRRect(
        bed.shift(const Offset(0, 1.2)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.9
          ..color = Colors.white.withOpacity(0.4),
      );
      return;
    }

    canvas.save();
    canvas.clipRRect(bed);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.2, -0.25),
          radius: 0.95,
          colors: [
            Color(0xFF3A3F46),
            Color(0xFF22262B),
            Color(0xFF15181B),
          ],
        ).createShader(rect),
    );

    // Creases in the torn foil, deterministic per cavity.
    final rng = math.Random(seed * 97 + 13);
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final startX = rng.nextDouble() * size.width;
      final startY = i.isEven ? 0.0 : size.height;
      path.moveTo(startX, startY);
      path.lineTo(
        rng.nextDouble() * size.width,
        size.height * (0.25 + rng.nextDouble() * 0.5),
      );
      path.lineTo(
        rng.nextDouble() * size.width,
        i.isEven ? size.height * 0.34 : size.height * 0.66,
      );
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.5),
              Paper.foilMid.withOpacity(0.18),
            ],
          ).createShader(rect),
      );
    }

    canvas.drawRRect(
      bed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.black.withOpacity(0.6),
    );
    canvas.restore();

    canvas.drawRRect(
      bed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..color = Colors.white.withOpacity(0.5),
    );
  }

  @override
  bool shouldRepaint(covariant _BedPainter oldDelegate) =>
      oldDelegate.taken != taken || oldDelegate.seed != seed;
}
