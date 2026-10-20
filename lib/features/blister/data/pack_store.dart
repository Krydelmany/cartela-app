import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/medication_pack.dart';
import 'preset_templates.dart';

/// Packs survive the app being closed. Plain JSON in shared_preferences is
/// enough for a handful of records; move to sqflite if this ever grows.
class PackStore {
  const PackStore._();

  static const _key = 'packs_v1';

  static Future<List<MedicationPack>> load(DateTime now) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return PresetTemplates.createSamplePacks(now);

    try {
      final rows = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
      final packs = rows.map(_decode).whereType<MedicationPack>().toList();
      return packs.isEmpty ? PresetTemplates.createSamplePacks(now) : packs;
    } catch (_) {
      // Corrupt or from an older schema: fall back to the samples.
      return PresetTemplates.createSamplePacks(now);
    }
  }

  static Future<void> save(List<MedicationPack> packs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(packs.map(_encode).toList()),
    );
  }

  static Map<String, dynamic> _encode(MedicationPack pack) {
    return {
      'id': pack.id,
      'name': pack.medicationName,
      'template': pack.template.id,
      'start': pack.startedAt.toIso8601String(),
      'interval': pack.doseInterval.inMinutes,
      'taken': pack.takenIndices.toList()..sort(),
    };
  }

  static MedicationPack? _decode(Map<String, dynamic> json) {
    final template = PresetTemplates.byId(json['template'] as String? ?? '');
    if (template == null) return null;

    final taken = (json['taken'] as List? ?? const [])
        .whereType<num>()
        .map((n) => n.toInt())
        .toSet();

    return MedicationPack(
      id: json['id'] as String,
      medicationName: (json['name'] as String?)?.trim().isNotEmpty == true
          ? json['name'] as String
          : 'Cartela',
      template: template,
      startedAt: DateTime.parse(json['start'] as String),
      doseInterval: Duration(minutes: (json['interval'] as num).toInt()),
      takenIndices: taken,
    );
  }
}
