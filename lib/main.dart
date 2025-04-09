import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// 1. Корневой виджет приложения
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Garden of Soul',
      theme: ThemeData(
        colorSchemeSeed: Colors.green,
        useMaterial3: true
      ),
      home: GardenScreen(gardenService: GardenService()),
    );
  }
}

// 2. Модель данных (дерево)
class Tree {
  final String id;
  final String imagePath;
  final Offset position;

  Tree({
    required this.id,
    required this.imagePath,
    required this.position,
  });
}

// 3. Сервис (упрощённая логика для хранения деревьев)
class GardenService {
  final List<Tree> _trees = [];

  List<Tree> get trees => _trees;

  void plantTree(String imagePath, Offset position) {
    _trees.add(
      Tree(
        id: DateTime.now().toString(),
        imagePath: imagePath,
        position: position,
      ),
    );
  }
}

// 4. Экран с «лужайкой» и возможностью «посадить» дерево
class GardenScreen extends StatefulWidget {
  final GardenService gardenService;
  const GardenScreen({Key? key, required this.gardenService}) : super(key: key);

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Stack(
          children: [
            // Лужайка (пиксель-арт фон)
            // Замените путь на свой asset с пиксель-артом:
            Image.asset('assets/pixel_lawn.png'),

            // Отрисовка всех «посаженных» деревьев
            for (final tree in widget.gardenService.trees)
              Positioned(
                left: tree.position.dx,
                top: tree.position.dy,
                child: Image.asset(tree.imagePath),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showPlantDialog,
        child: const Icon(Icons.nature),
      ),
    );
  }

  void _showPlantDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Выберите дерево'),
        content: SizedBox(
          height: 120,
          child: ListView(
            children: [
              ListTile(
                title: const Text('Дерево A'),
                onTap: () {
                  widget.gardenService.plantTree(
                    'assets/tree_a.png',
                    const Offset(80, 180),
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
              ListTile(
                title: const Text('Дерево B'),
                onTap: () {
                  widget.gardenService.plantTree(
                    'assets/tree_b.png',
                    const Offset(200, 150),
                  );
                  Navigator.pop(context);
                  setState(() {});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}