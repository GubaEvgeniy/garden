import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:garden_of_soul/models/branch.dart';
import 'package:garden_of_soul/models/leaf.dart';

/// Сервис для работы с локальной базой данных Isar
class DatabaseService {
  late Isar _isar;
  
  /// Получение экземпляра базы данных
  Isar get isar => _isar;
  
  /// Приватный конструктор для синглтона
  DatabaseService._();
  
  /// Фабричный конструктор для инициализации базы данных
  static Future<DatabaseService> initialize() async {
    final service = DatabaseService._();
    await service._initDatabase();
    return service;
  }
  
  /// Инициализация базы данных
  Future<void> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [BranchSchema, LeafSchema],
      directory: dir.path,
    );
    
    // Проверяем наличие корня дерева, если нет - создаем
    await _initRootBranch();
  }
  
  /// Инициализация корня дерева, если его еще нет
  Future<void> _initRootBranch() async {
    // Проверяем, есть ли уже ветви в базе
    final branchCount = await _isar.branchs.count();
    
    if (branchCount == 0) {
      // Создаем корневую ветвь
      final rootBranch = Branch.root();
      
      // Сохраняем корневую ветвь в базу
      await _isar.writeTxn(() async {
        await _isar.branchs.put(rootBranch);
      });
      
      // Создаем первый лист
      final firstLeaf = rootBranch.addLeaf(
        content: "Моё первое размышление о личностном росте",
        positives: ["Начало пути", "Осознанность", "Намерение развиваться"],
        negatives: ["Неопределенность", "Страх неизвестного"],
      );
      
      // Сохраняем первый лист
      await _isar.writeTxn(() async {
        await _isar.leafs.put(firstLeaf);
      });
    }
  }
  
  /// Получение всех ветвей
  Future<List<Branch>> getAllBranches() async {
    return await _isar.branchs.where().findAll();
  }
  
  /// Получение корневой ветви
  Future<Branch?> getRootBranch() async {
    return await _isar.branchs
      .filter()
      .parentUuidIsNull()
      .findFirst();
  }
  
  /// Получение всех дочерних ветвей для заданной родительской ветви
  Future<List<Branch>> getChildBranches(String parentUuid) async {
    return await _isar.branchs
      .filter()
      .parentUuidEqualTo(parentUuid)
      .findAll();
  }
  
  /// Получение ветви по UUID
  Future<Branch?> getBranchByUuid(String uuid) async {
    return await _isar.branchs
      .filter()
      .uuidEqualTo(uuid)
      .findFirst();
  }
  
  /// Создание новой ветви
  Future<Branch> createBranch(Branch branch) async {
    await _isar.writeTxn(() async {
      await _isar.branchs.put(branch);
    });
    return branch;
  }
  
  /// Обновление существующей ветви
  Future<void> updateBranch(Branch branch) async {
    await _isar.writeTxn(() async {
      await _isar.branchs.put(branch);
    });
  }
  
  /// Удаление ветви
  Future<void> deleteBranch(Branch branch) async {
    await _isar.writeTxn(() async {
      // Сначала удаляем все листья, связанные с веткой
      final leaves = await _isar.leafs
        .filter()
        .branchUuidEqualTo(branch.uuid)
        .findAll();
        
      for (final leaf in leaves) {
        await _isar.leafs.delete(leaf.id);
      }
      
      // Затем удаляем саму ветку
      await _isar.branchs.delete(branch.id);
    });
  }
  
  /// Получение всех листьев для заданной ветви
  Future<List<Leaf>> getLeavesByBranch(String branchUuid) async {
    return await _isar.leafs
      .filter()
      .branchUuidEqualTo(branchUuid)
      .findAll();
  }
  
  /// Получение листа по UUID
  Future<Leaf?> getLeafByUuid(String uuid) async {
    return await _isar.leafs
      .filter()
      .uuidEqualTo(uuid)
      .findFirst();
  }
  
  /// Создание нового листа
  Future<Leaf> createLeaf(Leaf leaf) async {
    await _isar.writeTxn(() async {
      await _isar.leafs.put(leaf);
    });
    return leaf;
  }
  
  /// Обновление существующего листа
  Future<void> updateLeaf(Leaf leaf) async {
    await _isar.writeTxn(() async {
      await _isar.leafs.put(leaf);
    });
  }
  
  /// Удаление листа
  Future<void> deleteLeaf(Leaf leaf) async {
    await _isar.writeTxn(() async {
      await _isar.leafs.delete(leaf.id);
    });
  }
}
