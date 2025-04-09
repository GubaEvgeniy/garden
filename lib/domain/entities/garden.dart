import 'package:garden_of_feelings/domain/entities/plant.dart';

class Garden {
  final List<Plant?> grid;
  // Можно включить также размеры, уровень воды, т.д.

  Garden({required this.grid});
}