import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/medication_pack.dart';
import '../../domain/pill_shape.dart';

class PillCavityWidget extends StatefulWidget {
  final int pillIndex;
  final PillVisualSpec spec;
  final CavityStatus status;
  final VoidCallback onTap;

  const PillCavityWidget({
    super.key,
    required this.pillIndex,
    required this.spec,
    required this.status,
    required this.onTap,
  });

  @override
  State<PillCavityWidget> createState() => _PillCavityWidgetState();
}

class _PillCavityWidgetState extends State<PillCavityWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = widget.spec;
    final cavityW = spec.width + 12;
    final cavityH = spec.height + 12;
    final borderRadius = BorderRadius.circular(math.min(cavityW, cavityH) / 2);

    final isTaken = widget.status == CavityStatus.taken;
    final isTarget = widget.status == CavityStatus.currentTarget;
    final isOverdue = widget.status == CavityStatus.overdue;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final pulse = _pulseController.value;
          final highlightColor = isOverdue
              ? AppTheme.lateAccent
              : isTarget
                  ? AppTheme.expectedAccent
                  : Colors.transparent;

          return Container(
            width: cavityW,
            height: cavityH,
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              boxShadow: (isTarget || isOverdue)
                  ? [
                      BoxShadow(
                        color: highlightColor.withOpacity(0.35 + pulse * 0.35),
                        blurRadius: 8 + pulse * 8,
                        spreadRadius: 1 + pulse * 2.5,
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 1. Fundo da cavidade (sempre presente: anel prensado no alumínio)
                _CrushedFoilCavity(
                  width: cavityW,
                  height: cavityH,
                  seed: widget.pillIndex,
                  isTaken: isTaken,
                ),

                // 2. Comprimido + bolha plástica (some com animação ao destacar)
                AnimatedScale(
                  scale: isTaken ? 0.65 : 1.0,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  child: AnimatedOpacity(
                    opacity: isTaken ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 220),
                    child: _IntactPillBubble(
                      spec: spec,
                      cavityW: cavityW,
                      cavityH: cavityH,
                    ),
                  ),
                ),

                // 3. Anel indicador para "Qual deveria estar agora" ou "Atrasado"
                if (isTarget || isOverdue)
                  IgnorePointer(
                    child: Container(
                      width: cavityW + 4,
                      height: cavityH + 4,
                      decoration: BoxDecoration(
                        borderRadius: borderRadius,
                        border: Border.all(
                          color: highlightColor.withOpacity(0.75 + pulse * 0.25),
                          width: 2.2,
                        ),
                      ),
                    ),
                  ),

                // 4. Número discreto da ordem (ajuda a pessoa a se localizar na cartela)
                Positioned(
                  bottom: 2,
                  right: 5,
                  child: IgnorePointer(
                    child: Text(
                      '${widget.pillIndex + 1}',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        color: isTaken
                            ? Colors.white.withOpacity(0.38)
                            : Colors.black.withOpacity(0.45),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// Desenha o comprimido 3D dentro da bolha plástica transparente.
class _IntactPillBubble extends StatelessWidget {
  final PillVisualSpec spec;
  final double cavityW;
  final double cavityH;

  const _IntactPillBubble({
    required this.spec,
    required this.cavityW,
    required this.cavityH,
  });

  @override
  Widget build(BuildContext context) {
    final pillRadius =
        BorderRadius.circular(math.min(spec.width, spec.height) / 2);
    final cavityRadius =
        BorderRadius.circular(math.min(cavityW, cavityH) / 2);

    final isHorizontalScore =
        spec.kind == PillKind.ovalVertical || spec.kind == PillKind.round;

    return SizedBox(
      width: cavityW,
      height: cavityH,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sombra interna da bolha plástica
          Container(
            width: cavityW - 3,
            height: cavityH - 3,
            decoration: BoxDecoration(
              borderRadius: cavityRadius,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0x55707885),
                  Color(0x22FFFFFF),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.45),
                width: 1.0,
              ),
            ),
          ),

          // Corpo do comprimido
          Container(
            width: spec.width,
            height: spec.height,
            decoration: BoxDecoration(
              borderRadius: pillRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(spec.color, Colors.white, 0.22)!,
                  spec.color,
                  Color.lerp(spec.color, spec.shadowColor, 0.45)!,
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.38),
                  blurRadius: 4,
                  offset: const Offset(1.5, 2.5),
                ),
              ],
            ),
            child: spec.hasScoreLine
                ? Center(
                    child: Container(
                      width: isHorizontalScore ? spec.width * 0.72 : 2.2,
                      height: isHorizontalScore ? 2.2 : spec.height * 0.78,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        gradient: LinearGradient(
                          colors: [
                            spec.shadowColor.withOpacity(0.55),
                            Colors.white.withOpacity(0.5),
                          ],
                        ),
                      ),
                    ),
                  )
                : null,
          ),

          // Reflexo especular da bolha plástica por cima do comprimido
          Positioned(
            top: 4,
            left: 7,
            right: 7,
            height: cavityH * 0.32,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: cavityRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.48),
                      Colors.white.withOpacity(0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Desenha a cavidade vazia/amassada/rasgada (como nas fotos quando o remédio já saiu).
class _CrushedFoilCavity extends StatelessWidget {
  final double width;
  final double height;
  final int seed;
  final bool isTaken;

  const _CrushedFoilCavity({
    required this.width,
    required this.height,
    required this.seed,
    required this.isTaken,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: _CrushedFoilPainter(seed: seed, isTaken: isTaken),
    );
  }
}

class _CrushedFoilPainter extends CustomPainter {
  final int seed;
  final bool isTaken;

  _CrushedFoilPainter({required this.seed, required this.isTaken});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final radius = Radius.circular(math.min(size.width, size.height) / 2);
    final rrect = RRect.fromRectAndRadius(rect.deflate(1.5), radius);

    // Se ainda não foi tomado, desenha apenas o berço metálico discreto
    if (!isTaken) {
      canvas.drawRRect(
        rrect,
        Paint()..color = const Color(0xFF6B7280).withOpacity(0.35),
      );
      return;
    }

    // Cavidade destacada: fundo escuro profundo + facetas prateadas de plástico/alumínio amassado
    canvas.save();
    canvas.clipRRect(rrect);

    // Fundo escuro (rasgo/vazio da cavidade nas fotos)
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.15, -0.15),
          radius: 0.9,
          colors: [
            Color(0xFF1A1F26),
            Color(0xFF2D3440),
            Color(0xFF111418),
          ],
        ).createShader(rect),
    );

    // Facetas de plástico/alumínio amassado (determinísticas por seed para cada buraco ser único)
    final rng = math.Random(seed * 97 + 13);
    for (var i = 0; i < 3; i++) {
      final path = Path();
      final startX = rng.nextDouble() * size.width;
      final startY = (i.isEven ? 0.0 : size.height);
      path.moveTo(startX, startY);
      path.lineTo(
        rng.nextDouble() * size.width,
        size.height * (0.25 + rng.nextDouble() * 0.5),
      );
      path.lineTo(
        rng.nextDouble() * size.width,
        i.isEven ? size.height * 0.35 : size.height * 0.65,
      );
      path.close();

      canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.55),
              const Color(0xFF9CA3AF).withOpacity(0.25),
            ],
          ).createShader(rect),
      );
    }

    // Sombra interna da borda da cavidade
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..color = Colors.black.withOpacity(0.65),
    );
    canvas.restore();

    // Anel metálico externo da cavidade
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _CrushedFoilPainter oldDelegate) {
    return oldDelegate.isTaken != isTaken || oldDelegate.seed != seed;
  }
}
