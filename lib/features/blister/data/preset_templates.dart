import 'package:flutter/material.dart';
import '../domain/blister_slot.dart';
import '../domain/blister_template.dart';
import '../domain/medication_pack.dart';
import '../domain/pill_shape.dart';

class PresetTemplates {
  const PresetTemplates._();

  /// 2x5 oblongs, scored. The ochre pills of the first photo.
  static final BlisterTemplate oblongYellow10 = BlisterTemplate(
    id: 'oblong_yellow_2x5',
    name: 'Cartela 10 comprimidos',
    subtitle: 'Oblongo horizontal, com sulco',
    rows: 5,
    columns: 2,
    stampedCode: 'L 2504291   V 06/28',
    stampAtTop: true,
    boardWidth: 280,
    boardPaddingH: 20,
    boardPaddingV: 22,
    rowSpacing: 15,
    pillSpec: const PillVisualSpec(
      kind: PillKind.oblongHorizontal,
      color: Color(0xFFC9A25A),
      shadowColor: Color(0xFF7A5720),
      hasScoreLine: true,
      width: 92,
      height: 42,
    ),
    grid: List.generate(
      5,
      (r) => List.generate(2, (c) => BlisterSlot.pill(r * 2 + c)),
    ),
  );

  /// Round pills in two outer columns, with two pressed crosses down the middle.
  static final BlisterTemplate roundCross15 = BlisterTemplate(
    id: 'round_cross_15',
    name: 'Cartela 15 comprimidos',
    subtitle: 'Redondo, com dois relevos em cruz',
    rows: 6,
    columns: 3,
    stampedCode: 'V01/28   L26A987',
    stampAtTop: true,
    boardWidth: 276,
    boardPaddingH: 18,
    boardPaddingV: 22,
    rowSpacing: 9,
    pillSpec: const PillVisualSpec(
      kind: PillKind.round,
      color: Color(0xFFF2F0E8),
      shadowColor: Color(0xFF9C9788),
      hasScoreLine: true,
      width: 52,
      height: 52,
    ),
    grid: const [
      [
        BlisterSlot.pill(0),
        BlisterSlot.pill(1, verticalOffsetFactor: 0.45),
        BlisterSlot.pill(2),
      ],
      [
        BlisterSlot.pill(3),
        BlisterSlot.cross(verticalOffsetFactor: 0.45),
        BlisterSlot.pill(4),
      ],
      [
        BlisterSlot.pill(5),
        BlisterSlot.pill(6, verticalOffsetFactor: 0.45),
        BlisterSlot.pill(7),
      ],
      [
        BlisterSlot.pill(8),
        BlisterSlot.cross(verticalOffsetFactor: 0.45),
        BlisterSlot.pill(9),
      ],
      [
        BlisterSlot.pill(10),
        BlisterSlot.pill(11, verticalOffsetFactor: 0.45),
        BlisterSlot.pill(12),
      ],
      [
        BlisterSlot.pill(13),
        BlisterSlot.empty(),
        BlisterSlot.pill(14),
      ],
    ],
  );

  /// Upright capsules with two reinforcing ribs between the columns.
  static final BlisterTemplate verticalCapsule15 = BlisterTemplate(
    id: 'vertical_capsule_15',
    name: 'Cartela 15 comprimidos',
    subtitle: 'Cápsula vertical, com frisos',
    rows: 5,
    columns: 3,
    hasVerticalRibs: true,
    stampedCode: 'L26050510   V05/28',
    stampAtTop: false,
    boardWidth: 262,
    boardPaddingH: 20,
    boardPaddingV: 20,
    rowSpacing: 11,
    pillSpec: const PillVisualSpec(
      kind: PillKind.capsuleVertical,
      color: Color(0xFFEDEAE0),
      shadowColor: Color(0xFF9A9585),
      hasScoreLine: false,
      width: 36,
      height: 68,
    ),
    grid: List.generate(
      5,
      (r) => List.generate(3, (c) => BlisterSlot.pill(r * 3 + c)),
    ),
  );

  /// Dense 5x6 of small scored ovals.
  static final BlisterTemplate denseOval30 = BlisterTemplate(
    id: 'dense_oval_30',
    name: 'Cartela 30 comprimidos',
    subtitle: 'Oval compacto, com sulco',
    rows: 6,
    columns: 5,
    stampedCode: 'L2511092   V11/27',
    stampAtTop: true,
    boardWidth: 300,
    boardPaddingH: 14,
    boardPaddingV: 18,
    rowSpacing: 8,
    pillSpec: const PillVisualSpec(
      kind: PillKind.ovalVertical,
      color: Color(0xFFF4F2EA),
      shadowColor: Color(0xFFA5A091),
      hasScoreLine: true,
      width: 38,
      height: 54,
    ),
    grid: List.generate(
      6,
      (r) => List.generate(5, (c) => BlisterSlot.pill(r * 5 + c)),
    ),
  );

  static List<MedicationPack> createSamplePacks(DateTime now) {
    return [
      // Straight on schedule: the seventh dose is the one to look for.
      MedicationPack(
        id: 'pack_1',
        medicationName: 'Amarelo',
        dosageLabel: '1 comprimido a cada 12 horas',
        template: oblongYellow10,
        startedAt: now.subtract(const Duration(hours: 84)),
        doseInterval: const Duration(hours: 12),
        takenIndices: const {0, 1, 2, 3, 4, 5, 6},
      ),
      // One dose slipped by: shows the rubber stamp.
      MedicationPack(
        id: 'pack_2',
        medicationName: 'Cruz',
        dosageLabel: '1 comprimido ao dia',
        template: roundCross15,
        startedAt: now.subtract(const Duration(days: 16, hours: 4)),
        doseInterval: const Duration(hours: 24),
        takenIndices: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14},
      ),
      MedicationPack(
        id: 'pack_3',
        medicationName: 'Vertical',
        dosageLabel: '1 comprimido a cada 8 horas',
        template: verticalCapsule15,
        startedAt: now.subtract(const Duration(hours: 88)),
        doseInterval: const Duration(hours: 8),
        takenIndices: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
      ),
      MedicationPack(
        id: 'pack_4',
        medicationName: 'Oval',
        dosageLabel: '1 comprimido ao dia',
        template: denseOval30,
        startedAt: now.subtract(const Duration(days: 26)),
        doseInterval: const Duration(hours: 24),
        takenIndices: Set<int>.from(List.generate(26, (i) => i)),
      ),
    ];
  }
}
