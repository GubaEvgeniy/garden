import 'package:flutter/material.dart';
import 'presentation/screens/garden_screen.dart';

void main() {
  runApp(const GardenApp());
}

class GardenApp extends StatelessWidget {
  const GardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Мой Сад',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const GardenScreen(),
    );
  }
}
