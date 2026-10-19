import 'package:flutter/material.dart';

/// Geometria visual do comprimido dentro da bolha plástica.
enum PillKind {
  /// Comprimido comprido na horizontal (Foto 1 - amarelo com vinco).
  oblongHorizontal,

  /// Comprimido/cápsula comprido na vertical (Foto 3 - branco liso).
  capsuleVertical,

  /// Comprimido circular (Foto 2 - branco com vinco).
  round,

  /// Comprimido oval compacto na vertical (Foto 4 - 30 comp. com vinco).
  ovalVertical,
}

class PillVisualSpec {
  final PillKind kind;
  final Color color;
  final Color shadowColor;
  final bool hasScoreLine; // Sulco/vinco de partir no meio
  final double width;
  final double height;

  const PillVisualSpec({
    required this.kind,
    required this.color,
    required this.shadowColor,
    this.hasScoreLine = false,
    required this.width,
    required this.height,
  });
}
