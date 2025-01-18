import 'package:flutter/material.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(const ExposureCalculatorApp());
}

class ExposureCalculatorApp extends StatelessWidget {
  const ExposureCalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exposure Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}
