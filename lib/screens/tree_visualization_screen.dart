import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:garden_of_soul/models/branch.dart';
import 'package:garden_of_soul/models/leaf.dart';
import 'package:garden_of_soul/providers/garden_provider.dart';
import 'package:garden_of_soul/theme/app_theme.dart';
import 'package:garden_of_soul/widgets/biomorphic_button.dart';
import 'package:garden_of_soul/widgets/tree_game.dart';
import 'package:provider/provider.dart';

/// Экран с интерактивной визуализацией дерева жизни
class TreeVisualizationScreen extends StatefulWidget {
  const TreeVisualizationScreen({Key? key}) : super(key: key);

  @override
  State<TreeVisualizationScreen> createState() => _TreeVisualizationScreenState();
}

class _TreeVisualizationScreenState extends State<TreeVisualizationScreen> {
  /// Референс на игру для управления её состоянием
  TreeGame? _treeGame;
  
  /// Выбранная ветвь для отображения информации
  Branch? _selectedBranch;
  
  /// Выбранный лист для отображения информации
  Leaf? _selectedLeaf;
  
  @override
  Widget build(BuildContext context) {
    return Consumer<GardenProvider>(
      builder: (context, provider, child) {
        final rootBranch = provider.rootBranch;
        final branches = provider.allBranches;
        
        // Строим карту листьев для всех ветвей
        Map<String, List<Leaf>> leavesMap = {};
        for (final branch in branches) {
          leavesMap[branch.uuid] = provider.getLeavesForBranch(branch.uuid);
        }
        
        // Если rootBranch null, показываем заглушку
        if (rootBranch == null) {
          return const Scaffold(
            body: Center(
              child: Text("Дерево еще не выросло"),
            ),
          );
        }
        
        // Создаем игру с деревом, если её еще нет
        _treeGame ??= TreeGame(
          rootBranch: rootBranch,
          branches: branches,
          leavesMap: leavesMap,
          onBranchTap: _handleBranchTap,
          onLeafTap: _handleLeafTap,
        );
        
        // Если игра уже создана, обновляем её данные
        else {
          _treeGame!.updateTree(
            rootBranch: rootBranch,
            branches: branches,
            leavesMap: leavesMap,
          );
        }
        
        return Scaffold(
          body: Stack(
            children: [
              // Фоновый градиент
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE0F7FA), Colors.white],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              
              // Игра с деревом
              GameWidget(
                game: _treeGame!,
                overlayBuilderMap: {
                  'instructions': (context, game) {
                    return Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "✓ Используйте жесты масштабирования для увеличения\n"
                          "✓ Перетаскивайте для перемещения\n"
                          "✓ Нажмите на ветвь или лист для просмотра деталей",
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.soilBrown,
                          ),
                        ),
                      ),
                    );
                  },
                },
                initialActiveOverlays: const ['instructions'],
              ),
              
              // Панель с информацией о выбранной ветви или листе
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildInfoPanel(),
              ),
              
              // Кнопка возврата к основному экрану
              Positioned(
                top: 40,
                right: 16,
                child: BiomorphicButton(
                  text: "Назад",
                  width: 100,
                  height: 40,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Построение панели с информацией о выбранной ветви или листе
  Widget _buildInfoPanel() {
    // Если ничего не выбрано, возвращаем пустой контейнер
    if (_selectedBranch == null && _selectedLeaf == null) {
      return Container();
    }
    
    // Если выбран лист, показываем информацию о нём
    if (_selectedLeaf != null) {
      return Positioned(
        bottom: 20,
        left: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Лист размышлений",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.leafGreen,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _selectedLeaf = null;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _selectedLeaf!.content,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.soilBrown,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.seedGreen,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${_selectedLeaf!.positives.length} позитивных аспектов",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.seedGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.remove_circle_outline,
                    color: AppTheme.flowerPink,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${_selectedLeaf!.negatives.length} негативных аспектов",
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.flowerPink,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: BiomorphicButton(
                  text: "Редактировать",
                  width: 180,
                  height: 40,
                  onPressed: () => _navigateToLeafDetails(_selectedLeaf!.uuid),
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    // Иначе показываем информацию о выбранной ветви
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedBranch!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.branchBrown,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    setState(() {
                      _selectedBranch = null;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _selectedBranch!.description,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.soilBrown,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.category,
                  color: AppTheme.seedGreen,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _getCategoryName(_selectedBranch!.category),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.seedGreen,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(
                  Icons.calendar_today,
                  color: AppTheme.soilBrown,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(_selectedBranch!.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.soilBrown,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BiomorphicButton(
                  text: "Открыть",
                  width: 130,
                  height: 40,
                  onPressed: () => _navigateToBranchDetails(_selectedBranch!.uuid),
                ),
                BiomorphicButton(
                  text: "Добавить лист",
                  width: 160,
                  height: 40,
                  onPressed: () => _showAddLeafDialog(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Обработка нажатия на ветвь
  void _handleBranchTap(String branchUuid) {
    final provider = Provider.of<GardenProvider>(context, listen: false);
    final branch = provider.allBranches.firstWhere(
      (branch) => branch.uuid == branchUuid,
      orElse: () => null as Branch,
    );
    
    setState(() {
      _selectedBranch = branch;
      _selectedLeaf = null;
    });
  }
  
  /// Обработка нажатия на лист
  void _handleLeafTap(String leafUuid) {
    final provider = Provider.of<GardenProvider>(context, listen: false);
    
    // Находим ветвь и лист по UUID
    Leaf? foundLeaf;
    for (final branch in provider.allBranches) {
      final leaves = provider.getLeavesForBranch(branch.uuid);
      final leaf = leaves.firstWhere(
        (leaf) => leaf.uuid == leafUuid,
        orElse: () => null as Leaf,
      );
      
      if (leaf != null) {
        foundLeaf = leaf;
        break;
      }
    }
    
    if (foundLeaf != null) {
      setState(() {
        _selectedLeaf = foundLeaf;
        _selectedBranch = null;
      });
    }
  }
  
  /// Переход к экрану с деталями ветви
  void _navigateToBranchDetails(String branchUuid) {
    final provider = Provider.of<GardenProvider>(context, listen: false);
    provider.selectBranch(branchUuid);
    Navigator.of(context).pop();
  }
  
  /// Переход к экрану с деталями листа
  void _navigateToLeafDetails(String leafUuid) {
    // Здесь можно реализовать переход к экрану с деталями листа
    // Пока просто закрываем панель
    setState(() {
      _selectedLeaf = null;
    });
  }
  
  /// Диалог добавления нового листа
  void _showAddLeafDialog(BuildContext context) {
    if (_selectedBranch == null) return;
    
    final contentController = TextEditingController();
    final positivesController = TextEditingController();
    final negativesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Новый лист размышлений",
          style: TextStyle(
            color: AppTheme.leafGreen,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: "Размышление",
                  hintText: "Опишите ваши мысли...",
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: positivesController,
                decoration: const InputDecoration(
                  labelText: "Позитивные аспекты",
                  hintText: "Перечислите через запятую",
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: negativesController,
                decoration: const InputDecoration(
                  labelText: "Негативные аспекты",
                  hintText: "Перечислите через запятую",
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Отмена",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.seedGreen,
            ),
            onPressed: () {
              if (contentController.text.isNotEmpty) {
                final provider = Provider.of<GardenProvider>(context, listen: false);
                
                // Сохраняем текущий выбор
                final selectedBranch = _selectedBranch;
                
                // Выбираем ветвь и создаем лист
                provider.selectBranch(_selectedBranch!.uuid);
                
                // Парсим позитивные и негативные аспекты
                final positives = positivesController.text.isEmpty 
                    ? <String>[] 
                    : positivesController.text.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                        
                final negatives = negativesController.text.isEmpty 
                    ? <String>[] 
                    : negativesController.text.split(',')
                        .map((e) => e.trim())
                        .where((e) => e.isNotEmpty)
                        .toList();
                
                provider.createLeaf(
                  content: contentController.text,
                  positives: positives,
                  negatives: negatives,
                );
                
                // Восстанавливаем ветвь в интерфейсе
                setState(() {
                  _selectedBranch = selectedBranch;
                });
                
                Navigator.of(context).pop();
              }
            },
            child: const Text("Создать"),
          ),
        ],
      ),
    );
  }
  
  /// Получение имени категории
  String _getCategoryName(BranchCategory category) {
    switch (category) {
      case BranchCategory.personal:
        return "Личностный рост";
      case BranchCategory.career:
        return "Карьера";
      case BranchCategory.health:
        return "Здоровье";
      case BranchCategory.creativity:
        return "Творчество";
      case BranchCategory.relationships:
        return "Отношения";
      case BranchCategory.spirituality:
        return "Духовность";
      case BranchCategory.learning:
        return "Обучение";
      case BranchCategory.other:
        return "Другое";
    }
  }
  
  /// Форматирование даты
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }
}
