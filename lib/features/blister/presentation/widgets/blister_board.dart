import 'package:flutter/material.dart';
import '../../domain/blister_slot.dart';
import '../../domain/medication_pack.dart';
import 'embossed_cross.dart';
import 'pill_cavity_widget.dart';

/// Renderiza a cartela física completa com textura metálica pontilhada (knurling),
/// carimbo de validade/lote em baixo-relevo, canaletas verticais e as cavidades.
class BlisterBoard extends StatelessWidget {
  final MedicationPack pack;
  final DateTime now;
  final ValueChanged<int> onPillTap;

  const BlisterBoard({
    super.key,
    required this.pack,
    required this.now,
    required this.onPillTap,
  });

  @override
  Widget build(BuildContext context) {
    final template = pack.template;

    final stampWidget = _StampedLotBar(code: template.stampedCode);

    return Center(
      child: Container(
        width: template.boardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.65),
              blurRadius: 28,
              offset: const Offset(0, 16),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.08),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: CustomPaint(
            painter: _MetallicFoilBackgroundPainter(
              hasVerticalRibs: template.hasVerticalRibs,
              columns: template.columns,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withOpacity(0.55),
                  width: 1.4,
                ),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: template.boardPaddingH,
                vertical: template.boardPaddingV - 6,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (template.stampAtTop) ...[
                    stampWidget,
                    const SizedBox(height: 12),
                  ],
                  for (var r = 0; r < template.rows; r++) ...[
                    if (r > 0) SizedBox(height: template.rowSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (var c = 0; c < template.columns; c++)
                          _buildSlot(template.grid[r][c]),
                      ],
                    ),
                  ],
                  if (!template.stampAtTop) ...[
                    const SizedBox(height: 14),
                    stampWidget,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlot(BlisterSlot slot) {
    final spec = pack.template.pillSpec;
    final slotW = spec.width + 12;
    final slotH = spec.height + 12;

    Widget child;
    switch (slot.kind) {
      case SlotKind.empty:
        child = SizedBox(width: slotW, height: slotH);
      case SlotKind.embossedCross:
        child = SizedBox(
          width: slotW,
          height: slotH,
          child: const Center(child: EmbossedCross(size: 46)),
        );
      case SlotKind.pill:
        final idx = slot.pillIndex!;
        final status = pack.statusForPill(idx, now);
        child = PillCavityWidget(
          pillIndex: idx,
          spec: spec,
          status: status,
          onTap: () => onPillTap(idx),
        );
    }

    if (slot.verticalOffsetFactor != 0) {
      return Transform.translate(
        offset: Offset(0, slotH * slot.verticalOffsetFactor),
        child: child,
      );
    }
    return child;
  }
}

/// Barra de lote e validade prensada no topo ou base da cartela.
class _StampedLotBar extends StatelessWidget {
  final String code;

  const _StampedLotBar({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.18),
            Colors.white.withOpacity(0.32),
          ],
        ),
      ),
      child: Text(
        code,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.2,
          color: const Color(0xFF4B5563).withOpacity(0.85),
          shadows: const [
            Shadow(
              color: Colors.white70,
              offset: Offset(0.8, 0.8),
              blurRadius: 0.5,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pinta o alumínio escovado + textura pontilhada (diamond knurling) + canaletas verticais.
class _MetallicFoilBackgroundPainter extends CustomPainter {
  final bool hasVerticalRibs;
  final int columns;

  _MetallicFoilBackgroundPainter({
    required this.hasVerticalRibs,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // 1. Gradiente metálico principal (reflexo diagonal de alumínio)
    final metalPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment(-0.9, -1.0),
        end: Alignment(0.9, 1.0),
        colors: [
          Color(0xFFD5DAE1),
          Color(0xFFF3F5F8),
          Color(0xFFB7C0CC),
          Color(0xFFE7EBF0),
          Color(0xFFA9B2BF),
        ],
        stops: [0.0, 0.28, 0.52, 0.78, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, metalPaint);

    // 2. Textura pontilhada de cartela (diamond knurling)
    final darkDot = Paint()..color = const Color(0xFF6B7280).withOpacity(0.18);
    final lightDot = Paint()..color = Colors.white.withOpacity(0.35);
    const step = 5.0;

    for (double y = 4; y < size.height - 4; y += step) {
      final rowShift = ((y ~/ step).isEven) ? 0.0 : step / 2;
      for (double x = 4 + rowShift; x < size.width - 4; x += step) {
        canvas.drawCircle(Offset(x, y), 0.85, darkDot);
        canvas.drawCircle(Offset(x + 0.7, y + 0.7), 0.65, lightDot);
      }
    }

    // 3. Canaletas verticais de reforço (Foto 3: entre as 3 colunas)
    if (hasVerticalRibs && columns > 1) {
      for (var c = 1; c < columns; c++) {
        final x = (size.width / columns) * c;
        final ribRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: 7,
            height: size.height - 72,
          ),
          const Radius.circular(4),
        );

        canvas.drawRRect(
          ribRect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF7B8492),
                Color(0xFFF8FAFC),
                Color(0xFF8892A0),
              ],
            ).createShader(ribRect.outerRect),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MetallicFoilBackgroundPainter oldDelegate) {
    return oldDelegate.hasVerticalRibs != hasVerticalRibs ||
        oldDelegate.columns != columns;
  }
}
