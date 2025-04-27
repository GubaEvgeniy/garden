import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:garden_of_soul/models/branch.dart';
import 'package:garden_of_soul/models/leaf.dart';
import 'package:garden_of_soul/theme/app_theme.dart';

/// Основной класс игры для рендеринга дерева жизни
class TreeGame extends FlameGame with TapCallbacks, ScaleDetector, DragCallbacks {
  final Function(String branchUuid)? onBranchTap;
  final Function(String leafUuid)? onLeafTap;
  
  /// Корневая ветвь дерева
  Branch? rootBranch;
  
  /// Все ветви дерева
  List<Branch> branches = [];
  
  /// Все листья на дереве, сгруппированные по uuid ветви
  Map<String, List<Leaf>> leavesMap = {};
  
  /// Параметры масштабирования и перемещения
  double _scale = 1.0;
  Vector2 _position = Vector2.zero();
  bool _isDragging = false;
  
  /// Конструктор
  TreeGame({
    this.rootBranch,
    this.branches = const [],
    this.leavesMap = const {},
    this.onBranchTap,
    this.onLeafTap,
  });
  
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Если есть корневая ветвь, добавляем её компоненты
    if (rootBranch != null) {
      await _addBranchComponents(rootBranch!);
    }
    
    // Добавляем все остальные ветви
    for (final branch in branches) {
      if (branch.uuid != rootBranch?.uuid) {
        await _addBranchComponents(branch);
      }
    }
    
    // Центрируем камеру по корневой ветви
    if (rootBranch != null) {
      camera.moveTo(Vector2(rootBranch!.positionX, rootBranch!.positionY));
    }
  }
  
  /// Добавление компонентов ветви
  Future<void> _addBranchComponents(Branch branch) async {
    // Добавляем визуальный компонент ветви
    final branchComponent = BranchComponent(
      branch: branch,
      onTap: () {
        if (onBranchTap != null) {
          onBranchTap!(branch.uuid);
        }
      },
    );
    add(branchComponent);
    
    // Добавляем компоненты листьев для этой ветви
    final leaves = leavesMap[branch.uuid] ?? [];
    for (final leaf in leaves) {
      final leafComponent = LeafComponent(
        leaf: leaf,
        branchPosition: Vector2(branch.positionX, branch.positionY),
        branchAngle: branch.angle,
        onTap: () {
          if (onLeafTap != null) {
            onLeafTap!(leaf.uuid);
          }
        },
      );
      add(leafComponent);
    }
  }
  
  /// Обновление данных дерева
  void updateTree({
    Branch? rootBranch,
    List<Branch>? branches,
    Map<String, List<Leaf>>? leavesMap,
  }) {
    // Обновляем данные
    if (rootBranch != null) this.rootBranch = rootBranch;
    if (branches != null) this.branches = branches;
    if (leavesMap != null) this.leavesMap = leavesMap;
    
    // Перезагружаем компоненты
    removeAll(children);
    onLoad();
  }
  
  /// Обработка масштабирования
  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final newScale = _scale * info.scale.global.x;
    
    // Ограничиваем масштаб
    if (newScale >= 0.5 && newScale <= 2.0) {
      _scale = newScale;
      camera.zoom = _scale;
    }
  }
  
  /// Начало перетаскивания
  @override
  void onDragStart(DragStartInfo info) {
    _isDragging = true;
  }
  
  /// Обновление перетаскивания
  @override
  void onDragUpdate(DragUpdateInfo info) {
    if (_isDragging) {
      _position += info.delta.game / _scale;
      camera.moveTo(-_position);
    }
  }
  
  /// Окончание перетаскивания
  @override
  void onDragEnd(DragEndInfo info) {
    _isDragging = false;
  }
}

/// Компонент для отображения ветви
class BranchComponent extends PositionComponent with TapCallbacks {
  final Branch branch;
  final VoidCallback? onTap;
  
  BranchComponent({
    required this.branch,
    this.onTap,
  }) : super(
    position: Vector2(branch.positionX, branch.positionY),
    anchor: Anchor.topLeft,
  );
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Создаем кисть для рисования ветви
    final paint = Paint()
      ..color = AppTheme.branchBrown
      ..style = PaintingStyle.stroke
      ..strokeWidth = branch.thickness
      ..strokeCap = StrokeCap.round;
      
    // Рисуем основную линию ветви
    final endX = math.cos(branch.angle * math.pi / 180) * branch.length;
    final endY = math.sin(branch.angle * math.pi / 180) * branch.length;
    
    canvas.drawLine(
      Offset.zero,
      Offset(endX, endY),
      paint,
    );
    
    // Добавляем детали ветви (маленькие ответвления)
    final numDetails = (branch.length / 20).floor().clamp(2, 6);
    
    for (int i = 1; i <= numDetails; i++) {
      final offsetX = endX * (i / numDetails);
      final offsetY = endY * (i / numDetails);
      
      // Определяем длину детали
      final detailLength = branch.thickness * 1.5;
      
      // Направление детали (перпендикулярно ветви)
      final detailAngle = branch.angle + (i % 2 == 0 ? 90 : -90);
      final detailDirX = math.cos(detailAngle * math.pi / 180);
      final detailDirY = math.sin(detailAngle * math.pi / 180);
      
      // Рисуем деталь
      final detailPaint = Paint()
        ..color = AppTheme.branchBrown
        ..style = PaintingStyle.stroke
        ..strokeWidth = branch.thickness * 0.5
        ..strokeCap = StrokeCap.round;
        
      canvas.drawLine(
        Offset(offsetX, offsetY),
        Offset(
          offsetX + detailDirX * detailLength,
          offsetY + detailDirY * detailLength,
        ),
        detailPaint,
      );
    }
    
    // Добавляем название ветви
    final textPainter = TextPainter(
      text: TextSpan(
        text: branch.name,
        style: TextStyle(
          color: AppTheme.soilBrown,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Размещаем текст возле конца ветви
    textPainter.paint(
      canvas,
      Offset(
        endX - textPainter.width / 2,
        endY - textPainter.height - 10,
      ),
    );
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (onTap != null) {
      onTap!();
    }
  }
}

/// Компонент для отображения листа
class LeafComponent extends PositionComponent with TapCallbacks {
  final Leaf leaf;
  final Vector2 branchPosition;
  final double branchAngle;
  final VoidCallback? onTap;
  final double _flutterSpeed = 0.5; // Скорость колебания листа
  final double _flutterAmount = 0.05; // Амплитуда колебания
  
  /// Текущее время для анимации
  double _time = 0.0;
  
  /// Угол поворота листа с анимацией
  double get _animatedRotation => leaf.rotation + math.sin(_time * _flutterSpeed) * _flutterAmount;
  
  LeafComponent({
    required this.leaf,
    required this.branchPosition,
    required this.branchAngle,
    this.onTap,
  }) : super(
    position: _calculateLeafPosition(leaf, branchPosition, branchAngle),
    anchor: Anchor.center,
  );
  
  /// Вычисление позиции листа относительно ветви
  static Vector2 _calculateLeafPosition(Leaf leaf, Vector2 branchPosition, double branchAngle) {
    final branchDirX = math.cos(branchAngle * math.pi / 180);
    final branchDirY = math.sin(branchAngle * math.pi / 180);
    
    // Поворачиваем вектор смещения листа
    final rotatedOffsetX = leaf.offsetX * math.cos(branchAngle * math.pi / 180) - 
                          leaf.offsetY * math.sin(branchAngle * math.pi / 180);
    final rotatedOffsetY = leaf.offsetX * math.sin(branchAngle * math.pi / 180) + 
                          leaf.offsetY * math.cos(branchAngle * math.pi / 180);
    
    return Vector2(
      branchPosition.x + branchDirX * leaf.offsetX + rotatedOffsetX,
      branchPosition.y + branchDirY * leaf.offsetY + rotatedOffsetY,
    );
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }
  
  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Вращаем канву для анимации колебания листа
    canvas.save();
    canvas.rotate(_animatedRotation * math.pi / 180);
    
    // Создаем путь для формы листа
    final path = Path();
    
    // Размер листа
    final width = leaf.size;
    final height = leaf.size * 1.5;
    
    // Базовая форма листа (овал с заострённым кончиком)
    path.moveTo(0, -height / 2);  // Верхняя точка (кончик)
    
    // Левая сторона листа
    path.quadraticBezierTo(
      -width / 2, -height / 4,  // контрольная точка
      -width / 2, 0,            // конечная точка
    );
    path.quadraticBezierTo(
      -width / 2, height / 3,  // контрольная точка
      0, height / 2,           // конечная точка
    );
    
    // Правая сторона листа
    path.quadraticBezierTo(
      width / 2, height / 3,  // контрольная точка
      width / 2, 0,           // конечная точка
    );
    path.quadraticBezierTo(
      width / 2, -height / 4,  // контрольная точка
      0, -height / 2,          // возврат к вершине
    );
    
    // Определение цвета листа на основе соотношения позитивных и негативных аспектов
    final positiveCount = leaf.positives.length;
    final negativeCount = leaf.negatives.length;
    
    final color = positiveCount > negativeCount
        ? AppTheme.seedGreen
        : negativeCount > positiveCount
            ? AppTheme.flowerPink
            : AppTheme.skyBlue;
            
    // Создаем кисть с градиентом
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          color,
          Color.lerp(color, Colors.white, 0.2)!,
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(-width/2, -height/2, width, height));
      
    // Рисуем лист
    canvas.drawPath(path, paint);
    
    // Рисуем жилки листа
    final veins = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
      
    // Центральная жилка
    canvas.drawLine(
      Offset(0, -height / 2),
      Offset(0, height / 2),
      veins,
    );
    
    // Боковые жилки
    final numVeins = 3;
    for (int i = 0; i < numVeins; i++) {
      final y = -height / 3 + i * height / 4;
      
      // Левая жилка
      canvas.drawLine(
        Offset(0, y),
        Offset(-width / 3, y + height / 15),
        veins,
      );
      
      // Правая жилка
      canvas.drawLine(
        Offset(0, y),
        Offset(width / 3, y + height / 15),
        veins,
      );
    }
    
    canvas.restore();
  }
  
  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (onTap != null) {
      onTap!();
    }
  }
}
