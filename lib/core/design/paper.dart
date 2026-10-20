import 'dart:ui' show FontFeature, FontVariation;
import 'package:flutter/material.dart';

/// The app is made of two materials: warm paper and cold aluminum.
/// Radii encode material: paper 3, index card top-only, blister 20.
class Paper {
  const Paper._();

  static const Color sheet = Color(0xFFF4F0E5);
  static const Color sheetDeep = Color(0xFFEAE4D4);
  static const Color slip = Color(0xFFFBF7EC);
  static const Color ink = Color(0xFF26241E);
  static const Color inkSoft = Color(0xFF554F43);
  static const Color inkFaint = Color(0xFF6F6859);
  static const Color rule = Color(0xFFD3CBB7);
  static const Color oxide = Color(0xFFA8432A);

  static const Color foilHi = Color(0xFFEDF0F4);
  static const Color foilMid = Color(0xFFC3CAD3);
  static const Color foilLo = Color(0xFF949EAB);

  static const double margin = 22;

  static const List<BoxShadow> sheetShadow = [
    BoxShadow(
      color: Color(0x1C2B2418),
      blurRadius: 20,
      spreadRadius: -6,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0D2B2418),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];
}

/// Type has two voices: a soft serif that speaks, and a compact sans that labels.
class Hand {
  const Hand._();

  static TextStyle display({
    double size = 40,
    double weight = 500,
    bool italic = false,
    Color color = Paper.ink,
    double height = 1.04,
    double tracking = -1.0,
  }) {
    return TextStyle(
      fontFamily: 'Fraunces',
      fontSize: size,
      height: height,
      letterSpacing: tracking,
      color: color,
      fontStyle: italic ? FontStyle.italic : FontStyle.normal,
      fontVariations: [
        FontVariation('wght', weight),
        FontVariation('opsz', size.clamp(9, 144).toDouble()),
        const FontVariation('SOFT', 32),
        const FontVariation('WONK', 1),
      ],
    );
  }

  static TextStyle text({
    double size = 15,
    double weight = 400,
    Color color = Paper.ink,
    double height = 1.45,
    double tracking = 0,
  }) {
    return TextStyle(
      fontFamily: 'InstrumentSans',
      fontSize: size,
      height: height,
      color: color,
      letterSpacing: tracking,
      fontVariations: [
        FontVariation('wght', weight),
        const FontVariation('wdth', 100),
      ],
    );
  }

  static TextStyle numeric({
    double size = 12,
    double weight = 500,
    Color color = Paper.inkSoft,
    double tracking = 0.2,
  }) {
    return text(size: size, weight: weight, color: color, tracking: tracking)
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
  }

  /// Lettra prensada: used for lot codes and the rubber stamp.
  static TextStyle stamp({
    double size = 9,
    double weight = 700,
    Color color = Paper.inkSoft,
    double tracking = 2.4,
  }) {
    return text(
      size: size,
      weight: weight,
      color: color,
      tracking: tracking,
      height: 1.2,
    );
  }
}
