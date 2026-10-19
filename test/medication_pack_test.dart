import 'package:flutter_test/flutter_test.dart';
import 'package:cartela_app/features/blister/data/preset_templates.dart';
import 'package:cartela_app/features/blister/domain/medication_pack.dart';

void main() {
  test('Calcula corretamente quantos comprimidos deveriam ter saído da cartela', () {
    final start = DateTime(2026, 10, 10, 8, 0);
    final pack = MedicationPack(
      id: 't1',
      medicationName: 'Teste 12h',
      dosageLabel: '12/12h',
      template: PresetTemplates.oblongYellow10,
      startedAt: start,
      doseInterval: const Duration(hours: 12),
      takenIndices: const {0, 1},
    );

    // Após 25 horas (0h, 12h, 24h) -> 3 comprimidos já deveriam ter sido tomados (índices 0, 1, 2)
    final now = start.add(const Duration(hours: 25));
    expect(pack.expectedTakenCountAt(now), 3);

    // 0 e 1 foram tomados
    expect(pack.statusForPill(0, now), CavityStatus.taken);
    expect(pack.statusForPill(1, now), CavityStatus.taken);

    // Índice 2 é o comprimido esperado da vez
    expect(pack.statusForPill(2, now), CavityStatus.currentTarget);

    // Índice 3 ainda está intacto para o futuro
    expect(pack.statusForPill(3, now), CavityStatus.intact);
  });
}
