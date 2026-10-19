import 'package:flutter/material.dart';
import '../domain/blister_slot.dart';
import '../domain/blister_template.dart';
import '../domain/medication_pack.dart';
import '../domain/pill_shape.dart';

class PresetTemplates {
  const PresetTemplates._();

  /// FOTO 1: Cartela 2x5 (10 comprimidos oblongos horizontais amarelos com vinco).
  static final BlisterTemplate oblongYellow10 = BlisterTemplate(
    id: 'oblong_yellow_2x5',
    name: 'Cartela 10 comp. (2×5)',
    subtitle: 'Oblongo amarelo horizontal c/ vinco',
    rows: 5,
    columns: 2,
    stampedCode: 'L 2504291  V 06/28',
    stampAtTop: true,
    boardWidth: 290,
    rowSpacing: 16,
    pillSpec: const PillVisualSpec(
      kind: PillKind.oblongHorizontal,
      color: Color(0xFFD2A152), // Amarelo ocre/mostarda fiel à foto 1
      shadowColor: Color(0xFF7D581E),
      hasScoreLine: true,
      width: 92,
      height: 44,
    ),
    grid: List.generate(
      5,
      (r) => List.generate(2, (c) => BlisterSlot.pill(r * 2 + c)),
    ),
  );

  /// FOTO 2: Cartela 14 comp. redondos brancos + 2 cruzes (+) prensadas na coluna central.
  static final BlisterTemplate roundCross14 = BlisterTemplate(
    id: 'round_cross_14',
    name: 'Cartela 14 comp. (Especial +)',
    subtitle: 'Redondo branco c/ relevo central em cruz',
    rows: 6,
    columns: 3,
    stampedCode: 'V01/28  L26A987',
    stampAtTop: true,
    boardWidth: 280,
    rowSpacing: 10,
    pillSpec: const PillVisualSpec(
      kind: PillKind.round,
      color: Color(0xFFF3F4F6),
      shadowColor: Color(0xFF9CA3AF),
      hasScoreLine: true,
      width: 54,
      height: 54,
    ),
    grid: const [
      // Linha 1: Esq (0), Meio deslocado p/ baixo (1), Dir (2)
      [
        BlisterSlot.pill(0),
        BlisterSlot.pill(1, verticalOffsetFactor: 0.45),
        BlisterSlot.pill(2),
      ],
      // Linha 2: Esq (3), Cruz 1 no meio, Dir (4)
      [
        BlisterSlot.pill(3),
        BlisterSlot.cross(verticalOffsetFactor: 0.45),
        BlisterSlot.pill(4),
      ],
      // Linha 3: Esq (5), Meio deslocado (6), Dir (7)
      [
        BlisterSlot.pill(5),
        BlisterSlot.pill(6, verticalOffsetFactor: 0.45),
        BlisterSlot.pill(7),
      ],
      // Linha 4: Esq (8), Cruz 2 no meio, Dir (9)
      [
        BlisterSlot.pill(8),
        BlisterSlot.cross(verticalOffsetFactor: 0.45),
        BlisterSlot.pill(9),
      ],
      // Linha 5: Esq (10), Meio deslocado (11), Dir (12)
      [
        BlisterSlot.pill(10),
        BlisterSlot.pill(11, verticalOffsetFactor: 0.45),
        BlisterSlot.pill(12),
      ],
      // Linha 6: Esq (13), Meio vazio, Dir (14 -> total 14 se contar 0..13 ou 15 slots)
      [
        BlisterSlot.pill(13),
        BlisterSlot.empty(),
        BlisterSlot.pill(14),
      ],
    ],
  );

  /// FOTO 3: Cartela 3x5 (15 cápsulas/comprimidos brancos verticais + 2 canaletas metálicas).
  static final BlisterTemplate verticalCapsule15 = BlisterTemplate(
    id: 'vertical_capsule_3x5',
    name: 'Cartela 15 comp. (3×5)',
    subtitle: 'Cápsula vertical branca c/ frisos',
    rows: 5,
    columns: 3,
    hasVerticalRibs: true,
    stampedCode: 'L26050510  V05/28',
    stampAtTop: false,
    boardWidth: 295,
    rowSpacing: 12,
    pillSpec: const PillVisualSpec(
      kind: PillKind.capsuleVertical,
      color: Color(0xFFECEBE6),
      shadowColor: Color(0xFF9E9D95),
      hasScoreLine: false,
      width: 38,
      height: 72,
    ),
    grid: List.generate(
      5,
      (r) => List.generate(3, (c) => BlisterSlot.pill(r * 3 + c)),
    ),
  );

  /// FOTO 4: Cartela 5x6 (30 comprimidos ovais brancos pequenos c/ vinco).
  static final BlisterTemplate denseOval30 = BlisterTemplate(
    id: 'dense_oval_5x6',
    name: 'Cartela 30 comp. (5×6)',
    subtitle: 'Oval compacto vertical c/ vinco',
    rows: 6,
    columns: 5,
    stampedCode: 'L2511092  V11/27',
    stampAtTop: true,
    boardWidth: 325,
    boardPaddingH: 14,
    rowSpacing: 10,
    pillSpec: const PillVisualSpec(
      kind: PillKind.ovalVertical,
      color: Color(0xFFF4F5F7),
      shadowColor: Color(0xFF9FA6B2),
      hasScoreLine: true,
      width: 40,
      height: 56,
    ),
    grid: List.generate(
      6,
      (r) => List.generate(5, (c) => BlisterSlot.pill(r * 5 + c)),
    ),
  );

  /// Cria os pacotes iniciais exatamente no estado das 4 fotos enviadas.
  static List<MedicationPack> createSamplePacks(DateTime now) {
    return [
      // Foto 1: 8 tomados, restam os 2 últimos amarelos
      MedicationPack(
        id: 'pack_1',
        medicationName: 'Remédio 1 (Amarelo)',
        dosageLabel: '1 comp. a cada 12h',
        template: oblongYellow10,
        startedAt: now.subtract(const Duration(hours: 12 * 8 + 2)),
        doseInterval: const Duration(hours: 12),
        takenIndices: {0, 1, 2, 3, 4, 5, 6, 7},
      ),
      // Foto 2: todos tomados menos o inferior esquerdo (índice 13)
      MedicationPack(
        id: 'pack_2',
        medicationName: 'Remédio 2 (Cruz +)',
        dosageLabel: '1 comp. ao dia',
        template: roundCross14,
        startedAt: now.subtract(const Duration(days: 13, hours: 3)),
        doseInterval: const Duration(hours: 24),
        takenIndices: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14},
      ),
      // Foto 3: 11 tomados, restam o da direita na 4ª linha (11) e os 3 da 5ª linha (12, 13, 14)
      MedicationPack(
        id: 'pack_3',
        medicationName: 'Remédio 3 (Vertical)',
        dosageLabel: '1 comp. a cada 8h',
        template: verticalCapsule15,
        startedAt: now.subtract(const Duration(hours: 8 * 11 + 1)),
        doseInterval: const Duration(hours: 8),
        takenIndices: {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10},
      ),
      // Foto 4: 26 tomados (5 primeiras linhas + 1º da 6ª linha), restam os 4 últimos
      MedicationPack(
        id: 'pack_4',
        medicationName: 'Remédio 4 (30 comp.)',
        dosageLabel: '1 comp. ao dia',
        template: denseOval30,
        startedAt: now.subtract(const Duration(days: 26, hours: 2)),
        doseInterval: const Duration(hours: 24),
        takenIndices: Set<int>.from(List.generate(26, (i) => i)),
      ),
    ];
  }
}
