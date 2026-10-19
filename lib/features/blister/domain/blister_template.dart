import 'blister_slot.dart';
import 'pill_shape.dart';

/// Define a estrutura física e visual de um modelo de cartela (blister).
class BlisterTemplate {
  final String id;
  final String name;
  final String subtitle;
  final int rows;
  final int columns;
  final PillVisualSpec pillSpec;

  /// Matriz [rows x columns] descrevendo o que há em cada posição.
  final List<List<BlisterSlot>> grid;

  /// Exibe canaletas verticais metálicas entre as colunas (como na Foto 3).
  final bool hasVerticalRibs;

  /// Texto prensado no alumínio (lote/validade) no topo ou base da cartela.
  final String stampedCode;
  final bool stampAtTop;

  /// Proporção largura/altura aproximada da folha de alumínio.
  final double boardWidth;
  final double boardPaddingH;
  final double boardPaddingV;
  final double rowSpacing;

  const BlisterTemplate({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.rows,
    required this.columns,
    required this.pillSpec,
    required this.grid,
    this.hasVerticalRibs = false,
    this.stampedCode = 'L26050510  V05/28',
    this.stampAtTop = true,
    this.boardWidth = 310,
    this.boardPaddingH = 22,
    this.boardPaddingV = 24,
    this.rowSpacing = 14,
  });

  int get totalPills {
    var count = 0;
    for (final row in grid) {
      for (final slot in row) {
        if (slot.kind == SlotKind.pill) count++;
      }
    }
    return count;
  }
}
