import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/blister/presentation/pages/blister_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CartelaApp());
}

class CartelaApp extends StatelessWidget {
  const CartelaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minha Cartela',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const BlisterHomePage(),
    );
  }
}
