import 'package:flutter/material.dart';

class Motion {
  const Motion._();

  static const Duration quick = Duration(milliseconds: 220);
  static const Duration flip = Duration(milliseconds: 560);
  static const Duration ring = Duration(milliseconds: 760);
  static const Duration fall = Duration(milliseconds: 460);
  static const Duration land = Duration(milliseconds: 1100);
  static const Duration breathe = Duration(milliseconds: 8200);

  static const Curve settle = Curves.easeOutCubic;
  static const Curve slam = Curves.easeOutBack;

  /// Accessibility: honour the system "remove animations" setting.
  static bool reduce(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}
