import 'package:flutter_test/flutter_test.dart';
import 'package:cartela_app/features/blister/data/preset_templates.dart';
import 'package:cartela_app/features/blister/domain/medication_pack.dart';

void main() {
  final start = DateTime(2026, 10, 10, 8);

  MedicationPack packWith(Set<int> taken) {
    return MedicationPack(
      id: 'test',
      medicationName: 'Teste',
      template: PresetTemplates.oblongYellow10,
      startedAt: start,
      doseInterval: const Duration(hours: 12),
      takenIndices: taken,
    );
  }

  test('conta quantas doses já venceram', () {
    final pack = packWith({0, 1});
    final now = start.add(const Duration(hours: 25));

    expect(pack.expectedTakenCountAt(now), 3);
    expect(pack.nextIndex, 2);
    expect(pack.statusForPill(0, now), CavityStatus.taken);
    expect(pack.statusForPill(2, now), CavityStatus.currentTarget);
    expect(pack.statusForPill(3, now), CavityStatus.intact);
  });

  test('dose pulada é marcada como atrasada', () {
    final pack = packWith({0, 2});
    final now = start.add(const Duration(hours: 25));

    expect(pack.nextIndex, 1);
    expect(pack.missedCountAt(now), 1);
    expect(pack.statusForPill(1, now), CavityStatus.overdue);
  });

  test('tocar alterna entre marcado e não marcado', () {
    final pack = packWith({0});

    expect(pack.togglePill(1).takenIndices, {0, 1});
    expect(pack.togglePill(1).togglePill(1).takenIndices, {0});
  });

  test('cartela vazia não tem próximo', () {
    final pack = packWith({0, 1, 2, 3, 4, 5, 6, 7, 8, 9});
    expect(pack.nextIndex, isNull);
  });

  test('intervalo gera o rótulo de dose', () {
    expect(
      packWith({}).copyWith(doseInterval: const Duration(hours: 24)).dosageLabel,
      '1 comprimido ao dia',
    );
    expect(packWith({}).dosageLabel, '1 comprimido a cada 12 horas');
  });
}
