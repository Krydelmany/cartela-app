import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/paper.dart';
import '../../data/preset_templates.dart';
import '../../domain/blister_template.dart';
import '../../domain/medication_pack.dart';

class PackEditorResult {
  final MedicationPack? pack;
  final bool delete;

  const PackEditorResult.saved(this.pack) : delete = false;
  const PackEditorResult.deleted()
      : pack = null,
        delete = true;
}

/// Edits one pack on a sheet of paper that slides up from the bottom.
class PackEditor extends StatefulWidget {
  final MedicationPack? initial;
  final bool canDelete;
  final DateTime now;

  const PackEditor({
    super.key,
    this.initial,
    required this.canDelete,
    required this.now,
  });

  @override
  State<PackEditor> createState() => _PackEditorState();
}

class _PackEditorState extends State<PackEditor> {
  late final TextEditingController _name;
  late Duration _interval;
  late DateTime _start;
  late BlisterTemplate _template;

  static const _intervals = [
    Duration(hours: 4),
    Duration(hours: 6),
    Duration(hours: 8),
    Duration(hours: 12),
    Duration(hours: 24),
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _name = TextEditingController(text: initial?.medicationName ?? '');
    _interval = initial?.doseInterval ?? const Duration(hours: 12);
    _start = initial?.startedAt ?? widget.now;
    _template = initial?.template ?? PresetTemplates.all.first;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _save() {
    final trimmed = _name.text.trim();
    final template = _template;
    final taken = widget.initial?.takenIndices
            .where((i) => i < template.totalPills)
            .toSet() ??
        const <int>{};

    Navigator.of(context).pop(
      PackEditorResult.saved(
        MedicationPack(
          id: widget.initial?.id ??
              'pack_${DateTime.now().microsecondsSinceEpoch}',
          medicationName: trimmed.isEmpty ? 'Cartela' : trimmed,
          template: template,
          startedAt: _start,
          doseInterval: _interval,
          takenIndices: taken,
        ),
      ),
    );
  }

  Future<void> _pickStart() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _start,
      firstDate: widget.now.subtract(const Duration(days: 365)),
      lastDate: widget.now.add(const Duration(days: 30)),
      builder: _paperPickers,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_start),
      builder: _paperPickers,
    );
    if (time == null || !mounted) return;

    setState(() {
      _start = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Widget _paperPickers(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.light(
          primary: Paper.ink,
          surface: Paper.slip,
          onSurface: Paper.ink,
        ),
        dialogTheme: const DialogTheme(backgroundColor: Paper.slip),
      ),
      child: child!,
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Paper.slip,
        title: Text(
          'Remover esta cartela?',
          style: Hand.display(size: 19, weight: 600),
        ),
        content: Text(
          'Os comprimidos marcados desta cartela são apagados. '
          'Não dá para desfazer.',
          style: Hand.text(size: 13, color: Paper.inkSoft, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Manter',
              style: Hand.text(size: 13, weight: 600, color: Paper.inkSoft),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Remover',
              style: Hand.text(size: 13, weight: 700, color: Paper.oxide),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const PackEditorResult.deleted());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.initial == null;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Paper.slip,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Color(0x332B2418),
              blurRadius: 24,
              offset: Offset(0, -6),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isNew ? 'Nova cartela' : 'Editar cartela',
                style: Hand.display(size: 23, weight: 600),
              ),
              const SizedBox(height: 18),
              _label('Nome'),
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                style: Hand.text(size: 16),
                cursorColor: Paper.ink,
                cursorRadius: const Radius.circular(1),
                decoration: _fieldDecoration('Ex.: Amoxicilina 500 mg'),
              ),
              const SizedBox(height: 18),
              _label('De quanto em quanto tempo'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final interval in _intervals)
                    _PaperChip(
                      label: interval.inHours == 24
                          ? 'ao dia'
                          : '${interval.inHours} h',
                      selected: _interval == interval,
                      onTap: () => setState(() => _interval = interval),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _label('Modelo de cartela'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final template in PresetTemplates.all)
                    _PaperChip(
                      label: template.shortLabel,
                      selected: _template.id == template.id,
                      onTap: () => setState(() => _template = template),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              _label('Primeiro comprimido'),
              const SizedBox(height: 8),
              _PaperAction(
                onTap: _pickStart,
                label: _startLabel(_start),
                icon: Icons.edit_outlined,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: Paper.ink,
                  foregroundColor: Paper.slip,
                  minimumSize: const Size.fromHeight(48),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(3)),
                  ),
                  textStyle: Hand.text(size: 14, weight: 600),
                ),
                child: Text(isNew ? 'Adicionar cartela' : 'Salvar'),
              ),
              if (widget.canDelete) ...[
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _confirmDelete,
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    foregroundColor: Paper.oxide,
                  ),
                  child: Text(
                    'Remover cartela',
                    style: Hand.text(
                      size: 13,
                      weight: 600,
                      color: Paper.oxide,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _startLabel(DateTime d) {
    const months = [
      'jan',
      'fev',
      'mar',
      'abr',
      'mai',
      'jun',
      'jul',
      'ago',
      'set',
      'out',
      'nov',
      'dez',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${months[d.month - 1]} de ${d.year}, às $hh:$mm';
  }

  Widget _label(String text) {
    return Text(
      text,
      style: Hand.text(
        size: 11.5,
        weight: 600,
        color: Paper.inkSoft,
        height: 1.2,
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    const line = UnderlineInputBorder(
      borderSide: BorderSide(color: Paper.rule, width: 1),
    );
    return InputDecoration(
      hintText: hint,
      hintStyle: Hand.text(size: 15, color: Paper.inkFaint.withOpacity(0.8)),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(vertical: 9),
      enabledBorder: line,
      border: line,
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Paper.ink, width: 1.6),
      ),
    );
  }
}

class _PaperChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PaperChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        constraints: const BoxConstraints(minHeight: 38),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? Paper.ink : Colors.transparent,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(
            color: selected ? Paper.ink : Paper.rule,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Hand.text(
            size: 12.5,
            weight: selected ? 600 : 500,
            color: selected ? Paper.slip : Paper.inkSoft,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _PaperAction extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final IconData icon;

  const _PaperAction({
    required this.onTap,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Paper.rule),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: Paper.inkFaint),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: Hand.text(size: 13, color: Paper.ink, weight: 500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
