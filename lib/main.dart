import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/design/paper.dart';
import 'features/blister/presentation/pages/blister_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Paper.sheet,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const CartelaApp());
}

class CartelaApp extends StatelessWidget {
  const CartelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartela',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: Paper.sheet,
        colorScheme: const ColorScheme.light(
          primary: Paper.ink,
          surface: Paper.sheet,
          onSurface: Paper.ink,
        ),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Paper.ink,
          selectionColor: Color(0x3326241E),
        ),
      ),
      home: const BlisterHomePage(),
    );
  }
}
