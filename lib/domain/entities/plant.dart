// lib/domain/entities/plant.dart
abstract class Plant {
  final String name;
  final String spritePath;

  Plant({required this.name, required this.spritePath});
}

class Tree extends Plant {
  Tree() : super(name: 'Tree', spritePath: 'assets/tree.png');
}

class Bush extends Plant {
  Bush() : super(name: 'Bush', spritePath: 'assets/bush.png');
}

class Flower extends Plant {
  Flower() : super(name: 'Flower', spritePath: 'assets/flower.png');
}
