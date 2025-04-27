import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:garden_of_soul/theme/app_theme.dart';
import 'package:garden_of_soul/widgets/biomorphic_button.dart';
import 'package:garden_of_soul/screens/branch_screen.dart';
import 'package:provider/provider.dart';
import 'package:garden_of_soul/providers/garden_provider.dart';

/// Экран с семечком, с которого начинается приложение
class SeedScreen extends StatefulWidget {
  const SeedScreen({Key? key}) : super(key: key);

  @override
  State<SeedScreen> createState() => _SeedScreenState();
}

class _SeedScreenState extends State<SeedScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Анимация пульсации и вращения для семечка
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
    
    _rotateAnimation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut)
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Фоновый градиент
          Container(
            decoration: const BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
          ),
          
          // Лучи света от семечка
          CustomPaint(
            painter: _SunlightPainter(animation: _animationController),
            size: MediaQuery.of(context).size,
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Заголовок
                const Text(
                  "Сад Души",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.leafGreen,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Подзаголовок
                const Text(
                  "Вырастите свое дерево жизни",
                  style: TextStyle(
                    fontSize: 18,
                    color: AppTheme.soilBrown,
                  ),
                ),
                
                const SizedBox(height: 60),
                
                // Анимированное семечко
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: child,
                      ),
                    );
                  },
                  child: CustomPaint(
                    painter: _SeedPainter(),
                    size: const Size(120, 150),
                  ),
                ),
                
                const SizedBox(height: 70),
                
                // Текст вопроса
                const Text(
                  "Готовы начать путь личностного роста?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.soilBrown,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Кнопки выбора
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Кнопка "Да"
                    BiomorphicButton(
                      text: "Да",
                      isPositive: true,
                      onPressed: () => _onPositiveChoice(context),
                    ),
                    
                    const SizedBox(width: 40),
                    
                    // Кнопка "Нет"
                    BiomorphicButton(
                      text: "Нет",
                      isPositive: false,
                      onPressed: () => _onNegativeChoice(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Обработка положительного выбора
  void _onPositiveChoice(BuildContext context) {
    final provider = Provider.of<GardenProvider>(context, listen: false);
    
    // Анимированный переход к экрану ветви
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => 
          const BranchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          var opacityAnimation = animation.drive(tween);
          var scaleAnimation = animation.drive(
            Tween(begin: 0.8, end: 1.0).chain(
              CurveTween(curve: curve),
            ),
          );
          
          return FadeTransition(
            opacity: opacityAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }
  
  /// Обработка отрицательного выбора
  void _onNegativeChoice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Продолжить рост",
          style: TextStyle(
            color: AppTheme.leafGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          "Каждое семя имеет потенциал для роста. Когда вы будете готовы начать свой путь, возвращайтесь в Сад Души.",
          style: TextStyle(
            color: AppTheme.soilBrown,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Понятно",
              style: TextStyle(
                color: AppTheme.seedGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Кастомный painter для отрисовки семечка
class _SeedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint seedPaint = Paint()
      ..color = AppTheme.seedGreen
      ..style = PaintingStyle.fill;
      
    // Создаем форму семечка
    final Path seedPath = Path();
    seedPath.moveTo(size.width / 2, 0);
    seedPath.quadraticBezierTo(
      size.width * 0.8, size.height * 0.3,
      size.width * 0.6, size.height * 0.6,
    );
    seedPath.quadraticBezierTo(
      size.width * 0.9, size.height * 0.85,
      size.width / 2, size.height,
    );
    seedPath.quadraticBezierTo(
      size.width * 0.1, size.height * 0.85,
      size.width * 0.4, size.height * 0.6,
    );
    seedPath.quadraticBezierTo(
      size.width * 0.2, size.height * 0.3,
      size.width / 2, 0,
    );
    
    // Добавляем тень
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    final shadowPath = Path.from(seedPath);
    shadowPath.shift(const Offset(0, 5));
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Рисуем семечко с градиентом
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final LinearGradient gradient = LinearGradient(
      colors: [
        AppTheme.seedGreen,
        AppTheme.leafGreen.withOpacity(0.7),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(seedPath, gradientPaint);
    
    // Добавляем блик
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;
      
    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.3, size.height * 0.2);
    highlightPath.quadraticBezierTo(
      size.width * 0.4, size.height * 0.1,
      size.width * 0.5, size.height * 0.15,
    );
    highlightPath.quadraticBezierTo(
      size.width * 0.6, size.height * 0.25,
      size.width * 0.45, size.height * 0.35,
    );
    highlightPath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.3,
      size.width * 0.3, size.height * 0.2,
    );
    
    canvas.drawPath(highlightPath, highlightPaint);
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

/// Кастомный painter для отрисовки лучей света
class _SunlightPainter extends CustomPainter {
  final Animation<double> animation;
  
  _SunlightPainter({required this.animation}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    for (int i = 0; i < 12; i++) {
      final angle = (i * math.pi / 6) + (animation.value * math.pi / 8);
      final length = size.width * 0.4 * (0.7 + animation.value * 0.3);
      
      final startOffset = Offset(
        center.dx + math.cos(angle) * size.width * 0.2,
        center.dy + math.sin(angle) * size.width * 0.2,
      );
      
      final endOffset = Offset(
        center.dx + math.cos(angle) * length,
        center.dy + math.sin(angle) * length,
      );
      
      final paint = Paint()
        ..color = AppTheme.sunYellow.withOpacity(0.2 * (1 - animation.value * 0.5))
        ..strokeWidth = 15 * (1 - animation.value * 0.3)
        ..strokeCap = StrokeCap.round;
        
      canvas.drawLine(startOffset, endOffset, paint);
    }
  }
  
  @override
  bool shouldRepaint(covariant _SunlightPainter oldDelegate) {
    return true;
  }
}
