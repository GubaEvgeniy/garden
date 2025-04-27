import 'package:isar/isar.dart';
import 'package:garden_of_soul/models/leaf.dart';
import 'package:uuid/uuid.dart';

part 'branch.g.dart';

/// Категории развития ветви
enum BranchCategory {
  personal,  // Личностное развитие
  career,    // Карьера
  health,    // Здоровье
  creativity, // Творчество
  relationships, // Отношения
  spirituality, // Духовность
  learning,   // Обучение
  other,      // Другое
}

/// Модель для представления ветви в древе жизни
@collection
class Branch {
  Id id = Isar.autoIncrement;
  
  /// Уникальный идентификатор ветви
  @Index(unique: true)
  late String uuid;
  
  /// Название ветви
  late String name;
  
  /// Описание ветви
  late String description;
  
  /// Категория развития
  @enumerated
  late BranchCategory category;
  
  /// Дата создания ветви
  late DateTime createdAt;
  
  /// Последнее обновление
  late DateTime updatedAt;
  
  /// UUID родительской ветви (null для корневой ветви)
  String? parentUuid;
  
  /// Все листья, связанные с этой ветвью (обратная ссылка)
  @Backlink(to: 'branch')
  final leaves = IsarLinks<Leaf>();
  
  /// Визуальная позиция ветви на экране (X координата)
  double positionX = 0.0;
  
  /// Визуальная позиция ветви на экране (Y координата)
  double positionY = 0.0;
  
  /// Угол наклона ветви
  double angle = 0.0;
  
  /// Длина ветви
  double length = 100.0;
  
  /// Толщина ветви 
  double thickness = 10.0;
  
  /// Конструктор ветви
  Branch({
    required this.name,
    required this.description,
    required this.category,
    this.parentUuid,
    double? positionX,
    double? positionY,
    double? angle,
    double? length,
    double? thickness,
  }) {
    final now = DateTime.now();
    uuid = const Uuid().v4();
    createdAt = now;
    updatedAt = now;
    
    if (positionX != null) this.positionX = positionX;
    if (positionY != null) this.positionY = positionY;
    if (angle != null) this.angle = angle;
    if (length != null) this.length = length;
    if (thickness != null) this.thickness = thickness;
  }
  
  /// Создание начальной ветви (корень дерева)
  factory Branch.root() {
    return Branch(
      name: "Корень жизни",
      description: "Начало пути личностного роста",
      category: BranchCategory.personal,
      positionX: 0.0,
      positionY: 0.0,
      angle: -90.0, // Направлено вверх
      length: 120.0,
      thickness: 15.0,
    );
  }
  
  /// Метод для добавления нового листа к ветви
  Leaf addLeaf({
    required String content,
    required List<String> positives,
    required List<String> negatives,
  }) {
    final leaf = Leaf(
      content: content,
      positives: positives,
      negatives: negatives,
      branchUuid: uuid,
    );
    return leaf;
  }
  
  /// Метод для создания дочерней ветви
  Branch createChildBranch({
    required String name,
    required String description,
    required BranchCategory category,
    double? angle,
  }) {
    // Вычисляем позицию для новой ветви, основываясь на родительской
    final childAngle = angle ?? (this.angle + (30.0 - (60.0 * Math.random())));
    final childLength = this.length * 0.8;
    final childThickness = this.thickness * 0.7;
    
    // Конец текущей ветви становится началом новой
    final endX = positionX + length * Math.cos(this.angle * Math.pi / 180);
    final endY = positionY + length * Math.sin(this.angle * Math.pi / 180);
    
    return Branch(
      name: name,
      description: description,
      category: category,
      parentUuid: uuid,
      positionX: endX,
      positionY: endY,
      angle: childAngle,
      length: childLength,
      thickness: childThickness,
    );
  }
  
  /// Обновление ветви
  void update({
    String? name,
    String? description,
    BranchCategory? category,
    double? positionX,
    double? positionY,
    double? angle,
    double? length,
    double? thickness,
  }) {
    if (name != null) this.name = name;
    if (description != null) this.description = description;
    if (category != null) this.category = category;
    if (positionX != null) this.positionX = positionX;
    if (positionY != null) this.positionY = positionY;
    if (angle != null) this.angle = angle;
    if (length != null) this.length = length;
    if (thickness != null) this.thickness = thickness;
    
    updatedAt = DateTime.now();
  }
}

/// Вспомогательный класс для математических операций
class Math {
  static double random() {
    return DateTime.now().microsecondsSinceEpoch % 1000 / 1000;
  }
  
  static double cos(double angle) {
    return math.cos(angle);
  }
  
  static double sin(double angle) {
    return math.sin(angle);
  }
}
