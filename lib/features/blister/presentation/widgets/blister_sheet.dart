import 'dart:ui' show PointMode;
import 'package:flutter/material.dart';
import '../../../../core/design/motion.dart';
import '../../../../core/design/paper.dart';
import '../../domain/blister_slot.dart';
import '../../domain/blister_template.dart';
import '../../domain/medication_pack.dart';
import 'embossed_cross.dart';
import 'pill_cavity.dart';

/// The prescription slip, with the aluminum blister lying on top of it.
/// Two materials: paper (3px corners) and foil (20px corners).
class BlisterSheet extends StatefulWidget {
  final MedicationPack pack;
  final DateTime now;
  final ValueChanged<int> onPillTap;
  final VoidCallback onEditStart;

  const BlisterSheet({
    super.key,
    required this.pack,
    required this.now,
    required this.onPillTap,
    required this.onEditStart,
  });

  @override
  State<BlisterSheet> createState() => _BlisterSheetState();
}

class _BlisterSheetState extends State<BlisterSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;
  Offset _tilt = Offset.zero;
  bool _breathStarted = false;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(vsync: this, duration: Motion.breathe);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_breathStarted) return;
    _breathStarted = true;
    // The pack is a loose object on a desk: it moves a fraction of a degree.
    if (!Motion.reduce(context)) _breath.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  void _pointDown(PointerDownEvent event) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final local = box.globalToLocal(event.position);
    final nx = (local.dx / box.size.width) * 2 - 1;
    final ny = (local.dy / box.size.height) * 2 - 1;
    setState(() {
      _tilt = Offset(nx.clamp(-1.0, 1.0), ny.clamp(-1.0, 1.0));
    });
  }

  void _pointUp() {
    if (_tilt == Offset.zero) return;
    setState(() => _tilt = Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _pointDown,
      onPointerUp: (_) => _pointUp(),
      onPointerCancel: (_) => _pointUp(),
      child: AnimatedBuilder(
        animation: _breath,
        builder: (context, child) {
          final b = _breath.value;
          final angle = -0.024 + b * 0.010;
          final shadowBlur = 18.0 + b * 9;

          return TweenAnimationBuilder<Offset>(
            tween: Tween(begin: Offset.zero, end: _tilt),
            duration: const Duration(milliseconds: 420),
            curve: Curves.easeOutCubic,
            builder: (context, tilt, child) {
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateX(-tilt.dy * 0.07)
                  ..rotateY(tilt.dx * 0.07),
                child: child,
              );
            },
            child: Transform.rotate(
              angle: angle,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B2418).withOpacity(0.16),
                      blurRadius: shadowBlur,
                      spreadRadius: -6,
                      offset: const Offset(0, 12),
                    ),
                    const BoxShadow(
                      color: Color(0x0D2B2418),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: child!,
              ),
            ),
          );
        },
        child: _buildSlip(),
      ),
    );
  }

  Widget _buildSlip() {
    final template = widget.pack.template;

    return Container(
      padding: const EdgeInsets.fromLTRB(13, 12, 13, 10),
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
                  style: Hand.display(
                    size: 14,
                    weight: 600,
                    tracking: -0.1,
                  ),
                ),
              ),
              Text(
                '${widget.pack.takenCount} de ${template.totalPills}',
                style: Hand.numeric(size: 10, color: Paper.inkFaint),
              ),
            ],
          ),
          const SizedBox(height: 1),
          Text(
            '${template.subtitle} · ${widget.pack.dosageLabel}',
            style: Hand.text(size: 10.5, color: Paper.inkSoft),
          ),
          const SizedBox(height: 10),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Transform.rotate(
                angle: 0.026,
                child: _buildFoil(template),
              ),
            ),
          ),
          const SizedBox(height: 9),
          GestureDetector(
            onTap: widget.onEditStart,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                const Icon(
                  Icons.edit_outlined,
                  size: 12,
                  color: Paper.inkFaint,
                ),
                const SizedBox(width: 5),
                Text(
                  'iniciada em ${_shortDate(widget.pack.startedAt)}',
                  style: Hand.text(
                    size: 10.5,
                    color: Paper.inkFaint,
                    weight: 500,
                  ),
                ),
                const Spacer(),
                Text(
                  'restam ${widget.pack.remainingCount}',
                  style: Hand.numeric(size: 10.5, color: Paper.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoil(BlisterTemplate template) {
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
                        _buildSlot(template, template.grid[r][c]),
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

  Widget _buildSlot(BlisterTemplate template, BlisterSlot slot) {
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
          status: widget.pack.statusForPill(index, widget.now),
          onTap: () => widget.onPillTap(index),
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

  static String _shortDate(DateTime d) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]}, $hh:$mm';
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
    const step = 5.0;
    final dark = <Offset>[];
    final light = <Offset>[];
    var row = 0;
    for (double y = 3; y < size.height - 3; y += step) {
      final shift = row.isEven ? 0.0 : step / 2;
      for (double x = 3 + shift; x < size.width - 3; x += step) {
        dark.add(Offset(x, y));
        light.add(Offset(x + 0.75, y + 0.75));
      }
      row++;
    }

    canvas.drawPoints(
      PointMode.points,
      dark,
      Paint()
        ..color = const Color(0xFF5F6772).withOpacity(0.16)
        ..strokeWidth = 1.15
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPoints(
      PointMode.points,
      light,
      Paint()
        ..color = Colors.white.withOpacity(0.42)
        ..strokeWidth = 1.0
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
