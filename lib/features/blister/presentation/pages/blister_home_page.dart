import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/design/motion.dart';
import '../../../../core/design/paper.dart';
import '../../../../core/design/paper_grain.dart';
import '../../../../core/design/pencil_ring.dart';
import '../../data/pack_store.dart';
import '../../data/preset_templates.dart';
import '../../domain/medication_pack.dart';
import '../widgets/blister_sheet.dart';
import '../widgets/pack_editor.dart';
import '../widgets/paper_tab.dart';

class BlisterHomePage extends StatefulWidget {
  const BlisterHomePage({super.key});

  @override
  State<BlisterHomePage> createState() => _BlisterHomePageState();
}

class _BlisterHomePageState extends State<BlisterHomePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _enter;
  late List<MedicationPack> _packs;
  late DateTime _now;
  int _selected = 0;
  Timer? _ticker;
  bool _reducedChecked = false;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    // Samples paint immediately; the stored packs replace them in a tick.
    _packs = PresetTemplates.createSamplePacks(_now);
    _enter = AnimationController(vsync: this, duration: Motion.land)
      ..forward();
    _restore();
    // The schedule is time-based: refresh the reading every half minute.
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _restore() async {
    final loaded = await PackStore.load(_now);
    if (!mounted) return;
    setState(() {
      _packs = loaded;
      _selected = _selected.clamp(0, _packs.length - 1);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_reducedChecked) return;
    _reducedChecked = true;
    if (Motion.reduce(context)) _enter.value = 1;
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _enter.dispose();
    super.dispose();
  }

  MedicationPack get _pack => _packs[_selected];

  void _select(int index) {
    if (index == _selected) return;
    setState(() => _selected = index);
  }

  void _togglePill(int index) {
    setState(() => _packs[_selected] = _pack.togglePill(index));
    unawaited(PackStore.save(_packs));
  }

  Future<void> _openEditor({MedicationPack? pack, int? index}) async {
    final result = await showModalBottomSheet<PackEditorResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x3326241E),
      builder: (_) => PackEditor(
        initial: pack,
        canDelete: index != null && _packs.length > 1,
        now: _now,
      ),
    );
    if (result == null || !mounted) return;

    setState(() {
      if (result.delete) {
        final removed = index!;
        _packs.removeAt(removed);
        if (removed < _selected) _selected--;
        if (_selected >= _packs.length) _selected = _packs.length - 1;
      } else if (index == null) {
        _packs.add(result.pack!);
        _selected = _packs.length - 1;
      } else {
        _packs[index] = result.pack!;
      }
    });
    unawaited(PackStore.save(_packs));
  }

  @override
  Widget build(BuildContext context) {
    final hero = _heroCopy(_pack, _now);

    return Scaffold(
      backgroundColor: Paper.sheet,
      body: Stack(
        children: [
          const Positioned.fill(child: PaperGrain()),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    Paper.margin,
                    10,
                    Paper.margin,
                    26,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _masthead(),
                      const SizedBox(height: 3),
                      const HandDrawnRule(),
                      const SizedBox(height: 22),
                      _entrance(
                        from: 0.04,
                        to: 0.52,
                        slide: 12,
                        child: _heroBlock(hero),
                      ),
                      const SizedBox(height: 22),
                      _entrance(
                        from: 0.14,
                        to: 0.62,
                        slide: 10,
                        child: _tabs(),
                      ),
                      const SizedBox(height: 16),
                      _entrance(
                        from: 0.28,
                        to: 1.0,
                        slide: 18,
                        overshoot: true,
                        child: AnimatedSwitcher(
                          duration: Motion.flip,
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          transitionBuilder: (child, animation) =>
                              _PageFlip(animation: animation, child: child),
                          child: BlisterSheet(
                            key: ValueKey(_pack.id),
                            pack: _pack,
                            now: _now,
                            onPillTap: _togglePill,
                            onEditPack: () => _openEditor(
                              pack: _pack,
                              index: _selected,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _legend(),
                      const SizedBox(height: 14),
                      Text(
                        'Toque num comprimido para marcá-lo.',
                        textAlign: TextAlign.center,
                        style: Hand.text(
                          size: 11,
                          color: Paper.inkFaint,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _masthead() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Cartela',
          style: Hand.display(size: 17, weight: 600, tracking: -0.2),
        ),
        const SizedBox(width: 9),
        Flexible(
          child: Text(
            'um diário de comprimidos',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Hand.text(
              size: 10.5,
              color: Paper.inkFaint,
              height: 1.6,
            ),
          ),
        ),
        const Spacer(),
        Text(
          _dateLabel(_now),
          style: Hand.numeric(size: 10.5, color: Paper.inkSoft),
        ),
      ],
    );
  }

  Widget _heroBlock(_Hero hero) {
    return Semantics(
      liveRegion: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hero.lead,
            style: Hand.display(size: 39, weight: 500, height: 0.98),
          ),
          Text(
            hero.tail,
            style: Hand.display(
              size: 39,
              weight: 400,
              italic: true,
              height: 1.02,
            ),
          ),
          const SizedBox(height: 9),
          Text(hero.note, style: Hand.text(size: 12.5, color: Paper.inkSoft)),
        ],
      ),
    );
  }

  Widget _tabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            for (var i = 0; i < _packs.length; i++) ...[
              if (i > 0) const SizedBox(width: 7),
              PaperTab(
                label: _packs[i].medicationName,
                index: i,
                active: i == _selected,
                onTap: () => _select(i),
              ),
            ],
            const SizedBox(width: 7),
            _AddTab(onTap: () => _openEditor()),
          ],
        ),
      ),
    );
  }

  Widget _legend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const PencilRing(width: 14, height: 14, progress: 1, seed: 3),
        const SizedBox(width: 6),
        Text(
          'o de agora',
          style: Hand.text(size: 10.5, color: Paper.inkFaint),
        ),
        const SizedBox(width: 18),
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            border: Border.all(color: Paper.oxide, width: 1.3),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'atrasado',
          style: Hand.text(size: 10.5, color: Paper.inkFaint),
        ),
      ],
    );
  }

  /// One orchestrated entrance: text rises, tabs settle, the pack lands.
  Widget _entrance({
    required double from,
    required double to,
    required double slide,
    required Widget child,
    bool overshoot = false,
  }) {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, child) {
        final v = _enter.value;
        final o = Interval(from, to, curve: Curves.easeOut)
            .transform(v)
            .clamp(0.0, 1.0);
        final s = Interval(
          from,
          to,
          curve: overshoot ? Curves.easeOutBack : Curves.easeOutCubic,
        ).transform(v);
        final scale = overshoot ? 0.94 + 0.06 * s : 1.0;

        return Opacity(
          opacity: o,
          child: Transform.translate(
            offset: Offset(0, (1 - o) * slide),
            child: Transform.scale(scale: scale, child: child!),
          ),
        );
      },
      child: child,
    );
  }
}

class _AddTab extends StatelessWidget {
  final VoidCallback onTap;

  const _AddTab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Adicionar cartela',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Paper.sheetDeep.withOpacity(0.6),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
            border: Border.all(color: Paper.rule.withOpacity(0.55)),
          ),
          child: const Icon(
            Icons.add,
            size: 17,
            color: Paper.inkSoft,
          ),
        ),
      ),
    );
  }
}

class _Hero {
  final String lead;
  final String tail;
  final String note;

  const _Hero(this.lead, this.tail, this.note);
}

_Hero _heroCopy(MedicationPack pack, DateTime now) {
  final next = pack.nextIndex;
  if (next == null) {
    return _Hero(
      'Cartela',
      'vazia.',
      'Você tomou os ${pack.template.totalPills} comprimidos desta cartela.',
    );
  }

  final due = pack.scheduledTimeFor(next);
  final remaining = pack.remainingCount;
  final late = now.difference(due) > const Duration(minutes: 30);

  if (late) {
    return _Hero(
      'Uma dose ficou',
      'para trás.',
      'Era para as ${_hhmm(due)}, há ${_gap(now.difference(due))}. '
      'O comprimido ${next + 1} ainda está na cartela.',
    );
  }

  if (due.difference(now).inMinutes <= 30) {
    return _Hero(
      'Um comprimido',
      'agora.',
      'Previsto para as ${_hhmm(due)}. Restam $remaining nesta cartela.',
    );
  }

  return _Hero(
    'O próximo é',
    'às ${_hhmm(due)}.',
    'Daqui a ${_gap(due.difference(now))}. Restam $remaining nesta cartela.',
  );
}

String _hhmm(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

String _gap(Duration d) {
  if (d.inMinutes < 60) return '${d.inMinutes} min';
  if (d.inHours < 24) return '${d.inHours} h';
  final days = d.inDays;
  return days == 1 ? '1 dia' : '$days dias';
}

String _dateLabel(DateTime d) {
  const weekdays = ['seg', 'ter', 'qua', 'qui', 'sex', 'sáb', 'dom'];
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
  return '${weekdays[d.weekday - 1]}, ${d.day} ${months[d.month - 1]}';
}

/// Switching packs turns the page, it does not cross-fade.
class _PageFlip extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _PageFlip({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform(
            alignment: Alignment.centerLeft,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY((1 - t) * -0.55),
            child: child!,
          ),
        );
      },
      child: child,
    );
  }
}
