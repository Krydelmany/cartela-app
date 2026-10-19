enum SlotKind {
  /// Cavidade real com comprimido (ou já destacada).
  pill,

  /// Espaço liso de alumínio (sem cavidade).
  empty,

  /// Relevo prensado em formato de cruz '+' no centro (Foto 2).
  embossedCross,
}

class BlisterSlot {
  final SlotKind kind;

  /// Índice sequencial de tomada (0-based). Nulo quando [kind] != [SlotKind.pill].
  final int? pillIndex;

  /// Deslocamento vertical opcional (em fração da altura da linha) para
  /// cartelas com coluna central deslocada/intercalada como na Foto 2.
  final double verticalOffsetFactor;

  const BlisterSlot.pill(
    this.pillIndex, {
    this.verticalOffsetFactor = 0.0,
  }) : kind = SlotKind.pill;

  const BlisterSlot.empty()
      : kind = SlotKind.empty,
        pillIndex = null,
        verticalOffsetFactor = 0.0;

  const BlisterSlot.cross({this.verticalOffsetFactor = 0.0})
      : kind = SlotKind.embossedCross,
        pillIndex = null;
}
