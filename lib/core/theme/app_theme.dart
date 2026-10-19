import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();

  static const Color background = Color(0xFF0E1116);
  static const Color surface = Color(0xFF171B22);
  static const Color surfaceElevated = Color(0xFF212733);
  static const Color expectedAccent = Color(0xFF38BDF8); // Azul ciano p/ "deveria estar aqui"
  static const Color lateAccent = Color(0xFFF59E0B);     // Âmbar p/ "passou do horário e ainda está na cartela"
  static const Color takenAccent = Color(0xFF22C55E);    // Verde p/ em dia

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: expectedAccent,
        secondary: takenAccent,
        surface: surface,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }
}
