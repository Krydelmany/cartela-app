import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_theme.dart';
import '../../data/preset_templates.dart';
import '../../domain/medication_pack.dart';
import '../widgets/blister_board.dart';

class BlisterHomePage extends StatefulWidget {
  const BlisterHomePage({super.key});

  @override
  State<BlisterHomePage> createState() => _BlisterHomePageState();
}

class _BlisterHomePageState extends State<BlisterHomePage> {
  late final DateTime _now;
  late List<MedicationPack> _packs;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _packs = PresetTemplates.createSamplePacks(_now);
  }

  MedicationPack get _currentPack => _packs[_selectedIndex];

  void _togglePill(int pillIndex) {
    HapticFeedback.lightImpact();
    setState(() {
      _packs[_selectedIndex] = _currentPack.togglePill(pillIndex);
    });
  }

  Future<void> _pickStartDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _currentPack.startedAt,
      firstDate: _now.subtract(const Duration(days: 90)),
      lastDate: _now.add(const Duration(days: 7)),
    );
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_currentPack.startedAt),
    );
    if (pickedTime == null || !mounted) return;

    final newStart = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _packs[_selectedIndex] = _currentPack.copyWith(startedAt: newStart);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pack = _currentPack;
    final total = pack.template.totalPills;
    final takenCount = pack.takenIndices.length;
    final expectedCount = pack.expectedTakenCountAt(_now);
    final diff = takenCount - expectedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Minhas Cartelas',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
            ),
            Text(
              'Toque no comprimido para destacar ou devolver',
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Ajustar início da cartela',
            onPressed: _pickStartDate,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // 1. Seletor horizontal de remédios/cartelas
            SizedBox(
              height: 46,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _packs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final item = _packs[index];
                  final selected = index == _selectedIndex;
                  return ChoiceChip(
                    label: Text(item.medicationName),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedIndex = index),
                    selectedColor: AppTheme.expectedAccent.withOpacity(0.22),
                    backgroundColor: AppTheme.surface,
                    labelStyle: TextStyle(
                      color: selected ? AppTheme.expectedAccent : Colors.white70,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    side: BorderSide(
                      color: selected
                          ? AppTheme.expectedAccent
                          : Colors.white.withOpacity(0.1),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // 2. Painel de conferência rápida (O que deveria estar na cartela agora)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _StatusBanner(
                pack: pack,
                takenCount: takenCount,
                expectedCount: expectedCount,
                total: total,
                diff: diff,
                onEditStart: _pickStartDate,
              ),
            ),

            const SizedBox(height: 12),

            // 3. A Cartela 3D Interativa
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: BlisterBoard(
                    key: ValueKey(pack.id),
                    pack: pack,
                    now: _now,
                    onPillTap: _togglePill,
                  ),
                ),
              ),
            ),

            // 4. Legenda visual no rodapé
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 6, 16, 14),
              child: _LegendRow(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final MedicationPack pack;
  final int takenCount;
  final int expectedCount;
  final int total;
  final int diff;
  final VoidCallback onEditStart;

  const _StatusBanner({
    required this.pack,
    required this.takenCount,
    required this.expectedCount,
    required this.total,
    required this.diff,
    required this.onEditStart,
  });

  @override
  Widget build(BuildContext context) {
    final remainingExpected = (total - expectedCount).clamp(0, total);
    final remainingActual = (total - takenCount).clamp(0, total);

    final Color statusColor;
    final String statusText;
    if (diff == 0) {
      statusColor = AppTheme.takenAccent;
      statusText =
          'Em dia! A cartela física deve ter $remainingExpected comp. restantes.';
    } else if (diff < 0) {
      statusColor = AppTheme.lateAccent;
      statusText =
          'Falta marcar ${diff.abs()} comp. (deveriam restar $remainingExpected na cartela, mas há $remainingActual).';
    } else {
      statusColor = AppTheme.expectedAccent;
      statusText =
          'Você destacou $diff comp. adiantado em relação ao horário.';
    }

    final startStr =
        '${pack.startedAt.day.toString().padLeft(2, '0')}/${pack.startedAt.month.toString().padLeft(2, '0')} às ${pack.startedAt.hour.toString().padLeft(2, '0')}:${pack.startedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${pack.template.name} • ${pack.dosageLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              InkWell(
                onTap: onEditStart,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Início: $startStr',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.expectedAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.88),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: const [
        _LegendItem(
          color: AppTheme.expectedAccent,
          label: 'Alvo atual (deve tomar/estar aqui)',
        ),
        _LegendItem(
          color: AppTheme.lateAccent,
          label: 'Passou da hora',
        ),
        _LegendItem(
          color: Color(0xFF374151),
          label: 'Já destacado',
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}
