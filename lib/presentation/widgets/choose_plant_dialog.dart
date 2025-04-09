import 'package:flutter/material.dart';
import 'package:garden_of_feelings/domain/entities/plant.dart';

class ChoosePlantDialog extends StatelessWidget {
  const ChoosePlantDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Выбери растение'),
      children: [
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, Tree()),
          child: Text('Дерево'),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, Bush()),
          child: Text('Куст'),
        ),
        SimpleDialogOption(
          onPressed: () => Navigator.pop(context, Flower()),
          child: Text('Цветок'),
        ),
      ],
    );
  }
}