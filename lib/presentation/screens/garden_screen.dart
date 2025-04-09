import 'package:flutter/material.dart';
import 'package:garden_of_feelings/data/repositories/garden_repository.dart';
import 'package:garden_of_feelings/domain/entities/garden.dart';
import 'package:garden_of_feelings/domain/entities/plant.dart';
import 'package:garden_of_feelings/presentation/widgets/choose_plant_dialog.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({Key? key}) : super(key: key);

  @override
  _GardenScreenState createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  late GardenRepository _gardenRepository;
  late Future<Garden> _gardenFuture;

  @override
  void initState() {
    super.initState();
    _gardenRepository = GardenRepository();
    _gardenFuture = _gardenRepository.loadGarden();
  }

  void _onCellTap(int index, Garden garden) async {
    if (garden.grid[index] == null) {
      // показать диалог выбора растения
      final selectedPlant = await showDialog<Plant>(
        context: context,
        builder: (_) => ChoosePlantDialog(),
      );
      if (selectedPlant != null) {
        // сохранить
        garden.grid[index] = selectedPlant;
        await _gardenRepository.saveGarden(garden);
        setState(() {
          _gardenFuture = Future.value(garden);
          // или заново _gardenFuture = _gardenRepository.loadGarden();
        });
      }
    } else {
      // Можно показать инфо о растении
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мой пиксель-арт сад'),
      ),
      body: FutureBuilder<Garden>(
        future: _gardenFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final garden = snapshot.data!;
          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5, // например, 5 колонок
            ),
            itemCount: garden.grid.length,
            itemBuilder: (context, index) {
              final plant = garden.grid[index];
              return GestureDetector(
                onTap: () => _onCellTap(index, garden),
                child: plant == null
                    ? Image.asset('assets/empty_tile.png') // пустая клетка
                    : Image.asset(plant.spritePath), // растение
              );
            },
          );
        },
      ),
    );
  }
}