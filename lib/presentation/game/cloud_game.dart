import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class CloudsGame extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Добавляем облачные компоненты с разными параметрами (позиция, смещение, размер)
    add(CloudComponent(
      top: 50,
      extraOffset: 0,
      width: 200,
      asset: 'prod/cloud1.png',
    ));
    add(CloudComponent(
      top: 70,
      extraOffset: -200,
      width: 50,
      asset: 'prod/cloud1.png',
    ));
    add(CloudComponent(
      top: 100,
      extraOffset: -100,
      width: 120,
      asset: 'prod/cloud1.png',
    ));
  }
}

/// Компонент облака, который двигается слева направо с циклическим перемещением.
/// Каждый компонент стартует с позиции: (-200 + extraOffset) и движется вправо с фиксированной скоростью,
/// так чтобы полный проход экрана занимал примерно 20 секунд.
class CloudComponent extends SpriteComponent with HasGameRef<CloudsGame> {
  final double extraOffset;
  final String asset;
  double speed = 0;

  /// [top] – вертикальная позиция компонента (y),
  /// [extraOffset] – смещение, чтобы задать разный старт для каждого облака,
  /// [width] – ширина облака. Высота рассчитывается пропорционально (можно откорректировать под ваш ассет).
  CloudComponent({
    required double top,
    required this.extraOffset,
    required double width,
    required this.asset,
  }) : super(
    position: Vector2(-200 + extraOffset, top),
    size: Vector2(width, width * 0.5),
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(asset);
    // При необходимости можно откорректировать размер, основываясь на соотношении сторон ассета.
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Расчитываем скорость так, чтобы облако проходило экран (и дополнительное расстояние)
    // за 20 секунд. При этом учитывается ширина экрана gameRef.size.x.
    speed = (gameRef.size.x + 200) / 20;
    position.x += speed * dt;
    // Если облако вышло за правую границу, сбрасываем его на левую (начальная позиция = -200 + extraOffset)
    if (position.x > gameRef.size.x) {
      position.x = -200 + extraOffset;
    }
  }
}