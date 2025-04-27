import 'package:isar/isar.dart';
import 'package:garden_of_soul/models/branch.dart';
import 'package:uuid/uuid.dart';

part 'leaf.g.dart';

/// Модель для представления листа на ветви дерева жизни
@collection
class Leaf {
  Id id = Isar.autoIncrement;
  
  /// Уникальный идентификатор листа
  @Index(unique: true)
  late String uuid;
  
  /// Основное содержание листа (текстовое описание)
  late String content;
  
  /// Список положительных аспектов
  late List<String> positives;
  
  /// Список отрицательных аспектов или проблем
  late List<String> negatives;
  
  /// Дата создания листа
  late DateTime createdAt;
  
  /// Дата последнего обновления
  late DateTime updatedAt;
  
  /// UUID ветви, к которой прикреплен лист
  @Index()
  late String branchUuid;
  
  /// Связь с родительской веткой
  final branch = IsarLink<Branch>();
  
  /// Визуальная позиция листа относительно ветви (смещение по X)
  double offsetX = 0.0;
  
  /// Визуальная позиция листа относительно ветви (смещение по Y)
  double offsetY = 0.0;
  
  /// Размер листа
  double size = 30.0;
  
  /// Угол поворота листа
  double rotation = 0.0;
  
  /// Конструктор листа
  Leaf({
    required this.content,
    required this.positives,
    required this.negatives,
    required this.branchUuid,
    double? offsetX,
    double? offsetY,
    double? size,
    double? rotation,
  }) {
    final now = DateTime.now();
    uuid = const Uuid().v4();
    createdAt = now;
    updatedAt = now;
    
    if (offsetX != null) this.offsetX = offsetX;
    if (offsetY != null) this.offsetY = offsetY;
    if (size != null) this.size = size;
    if (rotation != null) this.rotation = rotation;
  }
  
  /// Создание случайного листа для демонстрации
  factory Leaf.sample(String branchUuid) {
    return Leaf(
      content: "Пример записи в дневнике личностного роста",
      positives: [
        "Повышение осознанности",
        "Улучшение самодисциплины",
        "Развитие новых навыков"
      ],
      negatives: [
        "Требуется время на адаптацию",
        "Возможны временные трудности"
      ],
      branchUuid: branchUuid,
      offsetX: (DateTime.now().millisecondsSinceEpoch % 100) - 50,
      offsetY: (DateTime.now().millisecondsSinceEpoch % 50),
      size: 25 + (DateTime.now().millisecondsSinceEpoch % 20),
      rotation: (DateTime.now().millisecondsSinceEpoch % 60) - 30,
    );
  }
  
  /// Обновление содержания листа
  void updateContent({
    String? content,
    List<String>? positives,
    List<String>? negatives,
  }) {
    if (content != null) this.content = content;
    if (positives != null) this.positives = positives;
    if (negatives != null) this.negatives = negatives;
    
    updatedAt = DateTime.now();
  }
  
  /// Обновление визуальных параметров листа
  void updateVisuals({
    double? offsetX,
    double? offsetY,
    double? size,
    double? rotation,
  }) {
    if (offsetX != null) this.offsetX = offsetX;
    if (offsetY != null) this.offsetY = offsetY;
    if (size != null) this.size = size;
    if (rotation != null) this.rotation = rotation;
    
    updatedAt = DateTime.now();
  }
}
