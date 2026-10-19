import 'blister_template.dart';

enum CavityStatus {
  /// Já foi tomado/destacado (mostra o fundo escuro/alumínio rasgado).
  taken,

  /// Deveria já ter sido tomado pelo horário, mas ainda está na cartela!
  overdue,

  /// É o comprimido da vez (alvo atual para conferência visual).
  currentTarget,

  /// Comprimido futuro, intacto na cartela.
  intact,
}

class MedicationPack {
  final String id;
  final String medicationName;
  final String dosageLabel;
  final BlisterTemplate template;
  final DateTime startedAt;
  final Duration doseInterval;
  final Set<int> takenIndices;

  const MedicationPack({
    required this.id,
    required this.medicationName,
    required this.dosageLabel,
    required this.template,
    required this.startedAt,
    required this.doseInterval,
    required this.takenIndices,
  });

  /// Quantos comprimidos já deveriam ter sido tomados até [now]
  /// considerando que o 1º (índice 0) é tomado no momento [startedAt].
  int expectedTakenCountAt(DateTime now) {
    if (now.isBefore(startedAt)) return 0;
    final elapsedMinutes = now.difference(startedAt).inMinutes;
    final intervalMinutes = doseInterval.inMinutes;
    if (intervalMinutes <= 0) return 0;
    final count = (elapsedMinutes ~/ intervalMinutes) + 1;
    return count.clamp(0, template.totalPills);
  }

  /// Índice (0-based) do último comprimido que já deveria ter saído da cartela,
  /// ou do próximo na fila imediata.
  int? expectedCurrentIndexAt(DateTime now) {
    final expectedCount = expectedTakenCountAt(now);
    if (expectedCount <= 0) return 0;
    if (expectedCount >= template.totalPills) return template.totalPills - 1;
    return expectedCount - 1;
  }

  /// Horário programado para um comprimido específico `pillIndex`.
  DateTime scheduledTimeFor(int pillIndex) {
    return startedAt.add(doseInterval * pillIndex);
  }

  CavityStatus statusForPill(int pillIndex, DateTime now) {
    if (takenIndices.contains(pillIndex)) {
      return CavityStatus.taken;
    }

    final expectedCount = expectedTakenCountAt(now);
    // Se expectedCount == 8, os índices 0..7 já venceram.
    // O índice 7 (expectedCount - 1) é a dose atual/recente; anteriores não tomados estão atrasados.
    if (pillIndex < expectedCount - 1) {
      return CavityStatus.overdue;
    }
    if (pillIndex == expectedCount - 1 ||
        (expectedCount == 0 && pillIndex == 0)) {
      return CavityStatus.currentTarget;
    }
    // Se já tomou todos até o esperado, destaca o próximo da fila como referência visual
    if (pillIndex == expectedCount && takenIndices.contains(expectedCount - 1)) {
      return CavityStatus.currentTarget;
    }
    return CavityStatus.intact;
  }

  MedicationPack togglePill(int pillIndex) {
    final updated = Set<int>.from(takenIndices);
    if (!updated.remove(pillIndex)) {
      updated.add(pillIndex);
    }
    return copyWith(takenIndices: updated);
  }

  MedicationPack copyWith({
    String? medicationName,
    String? dosageLabel,
    DateTime? startedAt,
    Duration? doseInterval,
    Set<int>? takenIndices,
  }) {
    return MedicationPack(
      id: id,
      medicationName: medicationName ?? this.medicationName,
      dosageLabel: dosageLabel ?? this.dosageLabel,
      template: template,
      startedAt: startedAt ?? this.startedAt,
      doseInterval: doseInterval ?? this.doseInterval,
      takenIndices: takenIndices ?? this.takenIndices,
    );
  }
}
