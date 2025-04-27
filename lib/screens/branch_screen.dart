import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:garden_of_soul/models/branch.dart';
import 'package:garden_of_soul/models/leaf.dart';
import 'package:garden_of_soul/providers/garden_provider.dart';
import 'package:garden_of_soul/theme/app_theme.dart';
import 'package:garden_of_soul/widgets/biomorphic_card.dart';
import 'package:garden_of_soul/widgets/biomorphic_button.dart';
import 'package:provider/provider.dart';

/// Экран с отображением ветви и её листьев
class BranchScreen extends StatefulWidget {
  const BranchScreen({Key? key}) : super(key: key);

  @override
  State<BranchScreen> createState() => _BranchScreenState();
}

class _BranchScreenState extends State<BranchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _growAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Анимация роста ветвей
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    
    _growAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GardenProvider>(
      builder: (context, provider, child) {
        final selectedBranch = provider.selectedBranch;
        final isLoading = provider.isLoading;
        final error = provider.error;
        
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: Text(selectedBranch?.name ?? "Дерево жизни"),
            backgroundColor: AppTheme.seedGreen,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                tooltip: "Добавить новый лист",
                onPressed: () => _showAddLeafDialog(context),
              ),
              IconButton(
                icon: const Icon(Icons.account_tree),
                tooltip: "Показать все ветви",
                onPressed: () => _showBranchesDialog(context),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Фоновый градиент
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
              ),
              
              // Основное содержимое
              if (isLoading)
                const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.seedGreen,
                  ),
                )
              else if (error != null)
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.soilBrown,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.clearError(),
                        child: const Text("Понятно"),
                      ),
                    ],
                  ),
                )
              else if (selectedBranch == null)
                const Center(
                  child: Text(
                    "Выберите ветвь дерева жизни",
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.soilBrown,
                    ),
                  ),
                )
              else
                _buildBranchContent(context, provider, selectedBranch),
            ],
          ),
          floatingActionButton: selectedBranch != null ? FloatingActionButton(
            onPressed: () => _showAddChildBranchDialog(context),
            backgroundColor: AppTheme.seedGreen,
            child: const Icon(Icons.nature),
            tooltip: "Создать новую ветвь",
          ) : null,
        );
      },
    );
  }
  
  /// Построение основного содержимого ветви
  Widget _buildBranchContent(
    BuildContext context, 
    GardenProvider provider, 
    Branch branch
  ) {
    final leaves = provider.getLeavesForBranch(branch.uuid);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Информация о ветви
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: BiomorphicCard(
            height: 150,
            width: double.infinity,
            color: AppTheme.leafGreen.withOpacity(0.9),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  branch.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Категория: ${_getCategoryName(branch.category)}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  branch.description,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const Spacer(),
                Text(
                  "Создано: ${_formatDate(branch.createdAt)}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Заголовок листьев
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const Text(
                "Листья размышлений",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.soilBrown,
                ),
              ),
              const Spacer(),
              Text(
                "${leaves.length} ${_getLeafCountSuffix(leaves.length)}",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.soilBrown,
                ),
              ),
            ],
          ),
        ),
        
        // Листья
        if (leaves.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "На этой ветви пока нет листьев.\nНажмите + чтобы добавить свое первое размышление.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.soilBrown,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          )
        else
          Expanded(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return _buildLeavesList(context, leaves);
              },
            ),
          ),
      ],
    );
  }
  
  /// Построение списка листьев с анимацией
  Widget _buildLeavesList(BuildContext context, List<Leaf> leaves) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: leaves.length,
      itemBuilder: (context, index) {
        final leaf = leaves[index];
        
        // Вычисляем задержку анимации для каждого листа
        final delay = index * 0.2;
        final animationValue = _growAnimation.value > delay ? 
            math.min(1.0, (_growAnimation.value - delay) * 5) : 0.0;
        
        return Opacity(
          opacity: animationValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animationValue)),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: _buildLeafCard(context, leaf),
            ),
          ),
        );
      },
    );
  }
  
  /// Построение карточки листа
  Widget _buildLeafCard(BuildContext context, Leaf leaf) {
    // Выбираем цвет для листа на основе содержания
    final leafColor = _getLeafColor(leaf);
    
    return BiomorphicCard(
      color: leafColor,
      onTap: () => _showLeafDetailsDialog(context, leaf),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            leaf.content.length > 100 ? '${leaf.content.substring(0, 100)}...' : leaf.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.add_circle_outline,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "${leaf.positives.length} позитивных аспектов",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.remove_circle_outline,
                color: Colors.white70,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                "${leaf.negatives.length} негативных аспектов",
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Создано: ${_formatDate(leaf.createdAt)}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Диалог добавления нового листа
  void _showAddLeafDialog(BuildContext context) {
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
                
                Provider.of<GardenProvider>(context, listen: false).createLeaf(
                  content: contentController.text,
                  positives: positives,
                  negatives: negatives,
                );
                
                Navigator.of(context).pop();
              }
            },
            child: const Text("Создать"),
          ),
        ],
      ),
    );
  }
  
  /// Диалог добавления новой дочерней ветви
  void _showAddChildBranchDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    BranchCategory selectedCategory = BranchCategory.personal;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text(
              "Новая ветвь",
              style: TextStyle(
                color: AppTheme.leafGreen,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: "Название",
                      hintText: "Введите название новой ветви...",
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: "Описание",
                      hintText: "Опишите направление развития...",
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<BranchCategory>(
                    value: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: "Категория",
                    ),
                    items: BranchCategory.values.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(_getCategoryName(category)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedCategory = value;
                        });
                      }
                    },
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
                  if (nameController.text.isNotEmpty) {
                    final provider = Provider.of<GardenProvider>(context, listen: false);
                    final selectedBranch = provider.selectedBranch;
                    
                    if (selectedBranch != null) {
                      provider.createBranch(
                        name: nameController.text,
                        description: descriptionController.text.isNotEmpty 
                            ? descriptionController.text 
                            : "Новое направление развития",
                        category: selectedCategory,
                        parentUuid: selectedBranch.uuid,
                      );
                    }
                    
                    Navigator.of(context).pop();
                  }
                },
                child: const Text("Создать"),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Диалог просмотра деталей листа
  void _showLeafDetailsDialog(BuildContext context, Leaf leaf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          "Лист от ${_formatDate(leaf.createdAt)}",
          style: const TextStyle(
            color: AppTheme.leafGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Основное содержание
                const Text(
                  "Размышление:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.soilBrown,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  leaf.content,
                  style: const TextStyle(
                    color: AppTheme.soilBrown,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Позитивные аспекты
                const Text(
                  "Позитивные аспекты:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.seedGreen,
                  ),
                ),
                const SizedBox(height: 8),
                if (leaf.positives.isEmpty)
                  const Text(
                    "Позитивные аспекты не указаны",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: leaf.positives.map((positive) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "• ",
                              style: TextStyle(
                                color: AppTheme.seedGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                positive,
                                style: const TextStyle(
                                  color: AppTheme.soilBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 16),
                
                // Негативные аспекты
                const Text(
                  "Негативные аспекты:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.flowerPink,
                  ),
                ),
                const SizedBox(height: 8),
                if (leaf.negatives.isEmpty)
                  const Text(
                    "Негативные аспекты не указаны",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: leaf.negatives.map((negative) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "• ",
                              style: TextStyle(
                                color: AppTheme.flowerPink,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                negative,
                                style: const TextStyle(
                                  color: AppTheme.soilBrown,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.grey),
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteLeafConfirmation(context, leaf);
            },
            tooltip: "Удалить лист",
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Закрыть",
              style: TextStyle(
                color: AppTheme.leafGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Диалог показа всех ветвей
  void _showBranchesDialog(BuildContext context) {
    final provider = Provider.of<GardenProvider>(context, listen: false);
    final branches = provider.allBranches;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Все ветви дерева",
          style: TextStyle(
            color: AppTheme.leafGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: branches.isEmpty
              ? const Center(
                  child: Text(
                    "Пока нет ветвей",
                    style: TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: branches.length,
                  itemBuilder: (context, index) {
                    final branch = branches[index];
                    final isRoot = branch.parentUuid == null;
                    
                    return ListTile(
                      title: Text(
                        branch.name,
                        style: TextStyle(
                          color: AppTheme.soilBrown,
                          fontWeight: isRoot ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        _getCategoryName(branch.category),
                        style: TextStyle(
                          color: Colors.grey,
                          fontStyle: isRoot ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      leading: Icon(
                        isRoot ? Icons.account_tree : Icons.grass,
                        color: isRoot ? AppTheme.branchBrown : AppTheme.leafGreen,
                      ),
                      trailing: provider.selectedBranch?.uuid == branch.uuid
                          ? const Icon(
                              Icons.check_circle,
                              color: AppTheme.seedGreen,
                            )
                          : null,
                      onTap: () {
                        provider.selectBranch(branch.uuid);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Закрыть",
              style: TextStyle(
                color: AppTheme.leafGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Подтверждение удаления листа
  void _showDeleteLeafConfirmation(BuildContext context, Leaf leaf) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Удалить лист?",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Это действие нельзя отменить. Вы уверены, что хотите удалить этот лист размышлений?",
          style: TextStyle(
            color: AppTheme.soilBrown,
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
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Provider.of<GardenProvider>(context, listen: false)
                  .deleteLeaf(leaf.uuid);
              Navigator.of(context).pop();
            },
            child: const Text("Удалить"),
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
  
  /// Получение суффикса для количества листьев
  String _getLeafCountSuffix(int count) {
    if (count % 10 == 1 && count % 100 != 11) {
      return "лист";
    } else if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) {
      return "листа";
    } else {
      return "листьев";
    }
  }
  
  /// Получение цвета для листа
  Color _getLeafColor(Leaf leaf) {
    // Базируем цвет на соотношении позитивных и негативных аспектов
    final positiveCount = leaf.positives.length;
    final negativeCount = leaf.negatives.length;
    
    if (positiveCount > negativeCount) {
      return AppTheme.seedGreen.withOpacity(0.9);
    } else if (negativeCount > positiveCount) {
      return AppTheme.flowerPink.withOpacity(0.9);
    } else {
      return AppTheme.skyBlue.withOpacity(0.9);
    }
  }
}
