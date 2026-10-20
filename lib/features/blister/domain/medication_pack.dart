import 'blister_template.dart';

enum CavityStatus {
  /// Already pushed through: the foil is torn.
  taken,

  /// A dose went by and this pill is still in the pack.
  overdue,

  /// The next pill in the pack — the one to look for right now.
  currentTarget,

  /// Still sealed, still in the future.
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

  int get takenCount => takenIndices.length;

  int get remainingCount => template.totalPills - takenCount;

  /// Doses that should have left the pack by [now]. Dose 0 is taken at [startedAt].
  int expectedTakenCountAt(DateTime now) {
    if (now.isBefore(startedAt)) return 0;
    final interval = doseInterval.inMinutes;
    if (interval <= 0) return 0;
    final count = now.difference(startedAt).inMinutes ~/ interval + 1;
    return count.clamp(0, template.totalPills);
  }

  /// The first pill still sealed — the next one physically in line.
  int? get nextIndex {
    for (var i = 0; i < template.totalPills; i++) {
      if (!takenIndices.contains(i)) return i;
    }
    return null;
  }

  /// Doses that came due strictly before the one in hand and were skipped.
  int missedCountAt(DateTime now) {
    final expected = expectedTakenCountAt(now);
    var missed = 0;
    for (var i = 0; i < expected - 1; i++) {
      if (!takenIndices.contains(i)) missed++;
    }
    return missed;
  }

  DateTime scheduledTimeFor(int pillIndex) =>
      startedAt.add(doseInterval * pillIndex);

  CavityStatus statusForPill(int pillIndex, DateTime now) {
    if (takenIndices.contains(pillIndex)) return CavityStatus.taken;

    final expected = expectedTakenCountAt(now);
    final next = nextIndex;

    // Anything older than the dose currently due was skipped.
    if (pillIndex < expected - 1) return CavityStatus.overdue;
    if (pillIndex == next) return CavityStatus.currentTarget;
    return CavityStatus.intact;
  }

  MedicationPack togglePill(int pillIndex) {
    final updated = Set<int>.from(takenIndices);
    if (!updated.remove(pillIndex)) updated.add(pillIndex);
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
