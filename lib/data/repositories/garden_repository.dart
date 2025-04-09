import 'package:garden_of_feelings/domain/entities/garden.dart';
import 'package:garden_of_feelings/domain/entities/plant.dart';

class GardenRepository {
  Future<Garden> loadGarden() async {
    return Future.value(Garden(grid: [null, Tree(), null, Bush(), Flower()]));
  }

  Future<void> saveGarden(Garden garden) async {
    // Сохраняем
  }
}
