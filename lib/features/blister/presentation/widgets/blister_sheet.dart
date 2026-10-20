import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../../../../core/design/paper.dart';
import '../../domain/blister_slot.dart';
import '../../domain/blister_template.dart';
import '../../domain/medication_pack.dart';
import 'embossed_cross.dart';
import 'pill_cavity.dart';

/// The prescription slip, with the aluminum blister lying on top of it.
/// Two materials: paper (3px corners) and foil (20px corners).
///
/// Static on purpose: the earlier breathing loop repainted the whole sheet
/// every frame, and an animated shadow blur repainted the blur at 60 fps.
class BlisterSheet extends StatelessWidget {
  final MedicationPack pack;
  final DateTime now;
  final ValueChanged<int> onPillTap;
  final VoidCallback onEditPack;

  const BlisterSheet({
    super.key,
    required this.pack,
    required this.now,
    required this.onPillTap,
    required this.onEditPack,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.022,
      child: RepaintBoundary(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(3)),
            boxShadow: [
              BoxShadow(
                color: Color(0x292B2418),
                blurRadius: 26,
                spreadRadius: -6,
                offset: Offset(0, 12),
              ),
              BoxShadow(
                color: Color(0x0D2B2418),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: _slip(context),
        ),
      ),
    );
  }

  Widget _slip(BuildContext context) {
    final template = pack.template;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 8),
      decoration: BoxDecoration(
        color: Paper.slip,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Paper.rule.withOpacity(0.9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  template.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Hand.display(
                    size: 14,
                    weight: 600,
                    tracking: -0.1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${pack.takenCount} de ${template.totalPills}',
                style: Hand.numeric(size: 10, color: Paper.inkFaint),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            pack.dosageLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Hand.text(size: 10.5, color: Paper.inkSoft),
          ),
          const SizedBox(height: 11),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Transform.rotate(
                angle: 0.026,
                child: _foil(template),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Semantics(
            button: true,
            label: 'Editar cartela',
            child: GestureDetector(
              onTap: onEditPack,
              behavior: HitTestBehavior.opaque,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 44),
                child: Row(
                  children: [
                    const Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: Paper.inkFaint,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Editar cartela',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Hand.text(
                          size: 11,
                          color: Paper.inkSoft,
                          weight: 600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'restam ${pack.remainingCount}',
                      style: Hand.numeric(size: 10.5, color: Paper.inkSoft),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _foil(BlisterTemplate template) {
    return Container(
      width: template.boardWidth,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E2B2418),
            blurRadius: 16,
            spreadRadius: -3,
            offset: Offset(0, 9),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: _FoilPainter(
            padH: template.boardPaddingH,
            ribs: template.hasVerticalRibs,
            columns: template.columns,
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: template.boardPaddingH,
              vertical: template.boardPaddingV - 4,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (template.stampAtTop) ...[
                  _LotStamp(code: template.stampedCode),
                  const SizedBox(height: 12),
                ],
                for (var r = 0; r < template.rows; r++) ...[
                  if (r > 0) SizedBox(height: template.rowSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (var c = 0; c < template.columns; c++)
                        _slot(template, template.grid[r][c]),
                    ],
                  ),
                ],
                if (!template.stampAtTop) ...[
                  const SizedBox(height: 13),
                  _LotStamp(code: template.stampedCode),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _slot(BlisterTemplate template, BlisterSlot slot) {
    final spec = template.pillSpec;
    final w = spec.width + 14;
    final h = spec.height + 14;

    Widget child;
    switch (slot.kind) {
      case SlotKind.empty:
        child = SizedBox(width: w, height: h);
      case SlotKind.embossedCross:
        child = SizedBox(
          width: w,
          height: h,
          child: const Center(child: EmbossedCross(size: 44)),
        );
      case SlotKind.pill:
        final index = slot.pillIndex!;
        child = PillCavity(
          pillIndex: index,
          spec: spec,
          status: pack.statusForPill(index, now),
          onTap: () => onPillTap(index),
        );
    }

    if (slot.verticalOffsetFactor != 0) {
      return Transform.translate(
        offset: Offset(0, h * slot.verticalOffsetFactor),
        child: child,
      );
    }
    return child;
  }
}

/// The lot and expiry, pressed into the foil.
class _LotStamp extends StatelessWidget {
  final String code;

  const _LotStamp({required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0x2E000000),
            Colors.white.withOpacity(0.26),
          ],
        ),
      ),
      child: Text(
        code,
        style: Hand.stamp(
          size: 8.5,
          weight: 700,
          color: const Color(0xFF5C6470).withOpacity(0.8),
          tracking: 1.9,
        ).copyWith(
          shadows: const [
            Shadow(
              color: Colors.white70,
              offset: Offset(0.6, 0.6),
              blurRadius: 0.4,
            ),
          ],
        ),
      ),
    );
  }
}

/// Brushed aluminum with a knurled diamond texture, plus the two reinforcing ribs.
class _FoilPainter extends CustomPainter {
  final double padH;
  final bool ribs;
  final int columns;

  _FoilPainter({
    required this.padH,
    required this.ribs,
    required this.columns,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment(-0.9, -1),
          end: Alignment(0.9, 1),
          colors: [
            Color(0xFFE9EDF2),
            Color(0xFFF7F8FA),
            Color(0xFFCBD2DA),
            Color(0xFFE4E8EE),
            Color(0xFFB3BCC7),
          ],
          stops: [0.0, 0.24, 0.52, 0.76, 1.0],
        ).createShader(rect),
    );

    // Knurling: two point clouds, offset like a diamond grid.
    // Step 6 keeps the texture readable while cutting the point count ~30%.
    const step = 6.0;
    final dark = <Offset>[];
    final light = <Offset>[];
    var row = 0;
    for (double y = 3; y < size.height - 3; y += step) {
      final shift = row.isEven ? 0.0 : step / 2;
      for (double x = 3 + shift; x < size.width - 3; x += step) {
        dark.add(Offset(x, y));
        light.add(Offset(x + 0.8, y + 0.8));
      }
      row++;
    }

    canvas.drawPoints(
      PointMode.points,
      dark,
      Paint()
        ..color = const Color(0xFF5F6772).withOpacity(0.16)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPoints(
      PointMode.points,
      light,
      Paint()
        ..color = Colors.white.withOpacity(0.42)
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round,
    );

    if (ribs && columns > 1) {
      final innerLeft = padH;
      final innerWidth = size.width - padH * 2;
      for (var c = 1; c < columns; c++) {
        final x = innerLeft + innerWidth * c / columns;
        final bar = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(x, size.height / 2),
            width: 6,
            height: size.height - 54,
          ),
          const Radius.circular(3),
        );

        canvas.drawRRect(
          bar.shift(const Offset(1.2, 1.4)),
          Paint()
            ..color = const Color(0x33201E18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.6),
        );
        canvas.drawRRect(
          bar,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color(0xFF8D97A4),
                Color(0xFFFBFCFD),
                Color(0xFF98A2AE),
              ],
            ).createShader(bar.outerRect),
        );
      }
    }

    // Rim light and a diagonal sheen.
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(0.7), const Radius.circular(20)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white.withOpacity(0.6),
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.12)
        ..lineTo(size.width, size.height * 0.02)
        ..lineTo(size.width, size.height * 0.16)
        ..lineTo(0, size.height * 0.26)
        ..close(),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.28),
            Colors.white.withOpacity(0.0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _FoilPainter oldDelegate) =>
      oldDelegate.ribs != ribs ||
      oldDelegate.columns != columns ||
      oldDelegate.padH != padH;
}
