import 'package:garden_of_feelings/data/repositories/garden_repository.dart';
import 'package:garden_of_feelings/domain/entities/plant.dart';

class PlantSeedUseCase {
  final GardenRepository gardenRepository;

  PlantSeedUseCase(this.gardenRepository);

  Future<void> execute(int cellIndex, Plant plant) async {
    final garden = await gardenRepository.loadGarden();
    if (garden.grid[cellIndex] == null) {
      // посадить растение
      garden.grid[cellIndex] = plant;
      await gardenRepository.saveGarden(garden);
    } else {
      // ячейка занята, ошибка/уведомление
    }
  }
}