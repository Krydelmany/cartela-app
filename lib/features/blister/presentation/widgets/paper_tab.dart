import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/design/paper.dart';

/// A paper index tab. The active one stands up straight out of the notebook;
/// the others lean, like dividers left in a stack.
class PaperTab extends StatelessWidget {
  final String label;
  final bool active;
  final int index;
  final VoidCallback onTap;

  const PaperTab({
    super.key,
    required this.label,
    required this.active,
    required this.index,
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
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.bottomCenter,
        transform: Matrix4.translationValues(0, active ? -5.0 : 3.0, 0)
          ..rotateZ(active ? 0.0 : (index.isEven ? -0.05 : 0.042)),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: active ? Paper.slip : Paper.sheetDeep,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(5)),
          border: Border.all(
            color: active ? Paper.rule : Paper.rule.withOpacity(0.55),
            width: 1,
          ),
          boxShadow: active
              ? const [
                  BoxShadow(
                    color: Color(0x142B2418),
                    blurRadius: 7,
                    offset: Offset(0, -2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: Hand.text(
            size: 13,
            weight: active ? 600 : 500,
            color: active ? Paper.ink : Paper.inkFaint,
            height: 1.1,
          ),
        ),
      ),
    );
  }
}
