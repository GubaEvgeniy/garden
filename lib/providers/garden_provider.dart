import 'package:flutter/foundation.dart';
import 'package:garden_of_soul/models/branch.dart';
import 'package:garden_of_soul/models/leaf.dart';
import 'package:garden_of_soul/services/database_service.dart';

/// Провайдер для управления состоянием дерева жизни
class GardenProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  
  // Текущее состояние
  Branch? _rootBranch;
  Branch? _selectedBranch;
  Leaf? _selectedLeaf;
  List<Branch> _allBranches = [];
  Map<String, List<Leaf>> _leavesMap = {};
  
  // Флаги загрузки
  bool _isLoading = false;
  String? _error;
  
  // Геттеры
  Branch? get rootBranch => _rootBranch;
  Branch? get selectedBranch => _selectedBranch;
  Leaf? get selectedLeaf => _selectedLeaf;
  List<Branch> get allBranches => _allBranches;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Получение листьев для ветви
  List<Leaf> getLeavesForBranch(String branchUuid) {
    return _leavesMap[branchUuid] ?? [];
  }
  
  // Конструктор
  GardenProvider(this._databaseService) {
    _initialize();
  }
  
  // Инициализация данных
  Future<void> _initialize() async {
    _setLoading(true);
    try {
      await _loadRootBranch();
      await _loadAllBranches();
      // Устанавливаем корневую ветвь как выбранную по умолчанию
      if (_rootBranch != null) {
        await selectBranch(_rootBranch!.uuid);
      }
    } catch (e) {
      _setError('Ошибка инициализации: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Загрузка корневой ветви
  Future<void> _loadRootBranch() async {
    _rootBranch = await _databaseService.getRootBranch();
    
    // Если корневой ветви нет, создаем ее
    if (_rootBranch == null) {
      _rootBranch = Branch.root();
      await _databaseService.createBranch(_rootBranch!);
    }
    
    // Загружаем листья для корневой ветви
    await _loadLeavesForBranch(_rootBranch!.uuid);
    
    notifyListeners();
  }
  
  // Загрузка всех ветвей
  Future<void> _loadAllBranches() async {
    _allBranches = await _databaseService.getAllBranches();
    notifyListeners();
  }
  
  // Загрузка листьев для ветви
  Future<void> _loadLeavesForBranch(String branchUuid) async {
    final leaves = await _databaseService.getLeavesByBranch(branchUuid);
    _leavesMap[branchUuid] = leaves;
    notifyListeners();
  }
  
  // Выбор ветви
  Future<void> selectBranch(String branchUuid) async {
    _setLoading(true);
    try {
      final branch = await _databaseService.getBranchByUuid(branchUuid);
      if (branch != null) {
        _selectedBranch = branch;
        _selectedLeaf = null;
        
        // Загружаем листья, если еще не загружены
        if (!_leavesMap.containsKey(branchUuid)) {
          await _loadLeavesForBranch(branchUuid);
        }
      }
    } catch (e) {
      _setError('Ошибка при выборе ветви: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Выбор листа
  void selectLeaf(String leafUuid) {
    if (_selectedBranch == null) return;
    
    final leaves = _leavesMap[_selectedBranch!.uuid] ?? [];
    _selectedLeaf = leaves.firstWhere(
      (leaf) => leaf.uuid == leafUuid,
      orElse: () => null as Leaf,
    );
    
    notifyListeners();
  }
  
  // Создание новой ветви
  Future<Branch?> createBranch({
    required String name,
    required String description,
    required BranchCategory category,
    required String parentUuid,
  }) async {
    _setLoading(true);
    Branch? newBranch;
    
    try {
      final parentBranch = await _databaseService.getBranchByUuid(parentUuid);
      if (parentBranch == null) {
        _setError('Родительская ветвь не найдена');
        return null;
      }
      
      newBranch = parentBranch.createChildBranch(
        name: name,
        description: description,
        category: category,
      );
      
      await _databaseService.createBranch(newBranch);
      await _loadAllBranches();
      
      // Выбираем новую ветвь
      await selectBranch(newBranch.uuid);
    } catch (e) {
      _setError('Ошибка при создании ветви: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    
    return newBranch;
  }
  
  // Обновление ветви
  Future<void> updateBranch({
    required String uuid,
    String? name,
    String? description,
    BranchCategory? category,
  }) async {
    _setLoading(true);
    
    try {
      final branch = await _databaseService.getBranchByUuid(uuid);
      if (branch == null) {
        _setError('Ветвь не найдена');
        return;
      }
      
      branch.update(
        name: name,
        description: description,
        category: category,
      );
      
      await _databaseService.updateBranch(branch);
      
      // Обновляем список всех ветвей
      await _loadAllBranches();
      
      // Если обновляемая ветвь была выбрана, обновляем выбранную ветвь
      if (_selectedBranch?.uuid == uuid) {
        _selectedBranch = branch;
      }
      
      // Если обновляемая ветвь - корневая, обновляем её
      if (_rootBranch?.uuid == uuid) {
        _rootBranch = branch;
      }
    } catch (e) {
      _setError('Ошибка при обновлении ветви: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Удаление ветви
  Future<void> deleteBranch(String uuid) async {
    _setLoading(true);
    
    try {
      // Нельзя удалить корневую ветвь
      if (_rootBranch?.uuid == uuid) {
        _setError('Нельзя удалить корневую ветвь');
        return;
      }
      
      final branch = await _databaseService.getBranchByUuid(uuid);
      if (branch == null) {
        _setError('Ветвь не найдена');
        return;
      }
      
      // Находим родительскую ветвь
      final parentBranch = branch.parentUuid != null 
          ? await _databaseService.getBranchByUuid(branch.parentUuid!)
          : null;
          
      await _databaseService.deleteBranch(branch);
      
      // Обновляем список всех ветвей
      await _loadAllBranches();
      
      // Если удаляемая ветвь была выбрана, выбираем родительскую или корневую
      if (_selectedBranch?.uuid == uuid) {
        if (parentBranch != null) {
          await selectBranch(parentBranch.uuid);
        } else if (_rootBranch != null) {
          await selectBranch(_rootBranch!.uuid);
        }
      }
      
      // Удаляем листья из кэша
      _leavesMap.remove(uuid);
    } catch (e) {
      _setError('Ошибка при удалении ветви: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Создание нового листа
  Future<Leaf?> createLeaf({
    required String content,
    required List<String> positives,
    required List<String> negatives,
  }) async {
    if (_selectedBranch == null) {
      _setError('Не выбрана ветвь для добавления листа');
      return null;
    }
    
    _setLoading(true);
    Leaf? newLeaf;
    
    try {
      newLeaf = _selectedBranch!.addLeaf(
        content: content,
        positives: positives,
        negatives: negatives,
      );
      
      await _databaseService.createLeaf(newLeaf);
      
      // Обновляем список листьев для ветви
      await _loadLeavesForBranch(_selectedBranch!.uuid);
      
      // Выбираем созданный лист
      _selectedLeaf = newLeaf;
    } catch (e) {
      _setError('Ошибка при создании листа: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
    
    return newLeaf;
  }
  
  // Обновление листа
  Future<void> updateLeaf({
    required String uuid,
    String? content,
    List<String>? positives,
    List<String>? negatives,
  }) async {
    _setLoading(true);
    
    try {
      final leaf = await _databaseService.getLeafByUuid(uuid);
      if (leaf == null) {
        _setError('Лист не найден');
        return;
      }
      
      leaf.updateContent(
        content: content,
        positives: positives,
        negatives: negatives,
      );
      
      await _databaseService.updateLeaf(leaf);
      
      // Обновляем список листьев для ветви
      if (_leavesMap.containsKey(leaf.branchUuid)) {
        await _loadLeavesForBranch(leaf.branchUuid);
      }
      
      // Если обновляемый лист был выбран, обновляем его
      if (_selectedLeaf?.uuid == uuid) {
        _selectedLeaf = leaf;
      }
    } catch (e) {
      _setError('Ошибка при обновлении листа: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Удаление листа
  Future<void> deleteLeaf(String uuid) async {
    _setLoading(true);
    
    try {
      final leaf = await _databaseService.getLeafByUuid(uuid);
      if (leaf == null) {
        _setError('Лист не найден');
        return;
      }
      
      final branchUuid = leaf.branchUuid;
      
      await _databaseService.deleteLeaf(leaf);
      
      // Обновляем список листьев для ветви
      if (_leavesMap.containsKey(branchUuid)) {
        await _loadLeavesForBranch(branchUuid);
      }
      
      // Если удаляемый лист был выбран, сбрасываем выбор
      if (_selectedLeaf?.uuid == uuid) {
        _selectedLeaf = null;
      }
    } catch (e) {
      _setError('Ошибка при удалении листа: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }
  
  // Вспомогательные методы
  void _setLoading(bool loading) {
    _isLoading = loading;
    if (loading) {
      _error = null;
    }
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
