import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:garden_of_soul/theme/app_theme.dart';

/// Кастомная карточка с биоморфным дизайном, имитирующая форму листа
class BiomorphicCard extends StatefulWidget {
  final Widget child;
  final double height;
  final double width;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  
  const BiomorphicCard({
    Key? key,
    required this.child,
    this.height = 200,
    this.width = 300,
    this.color,
    this.padding = const EdgeInsets.all(16.0),
    this.onTap,
  }) : super(key: key);

  @override
  State<BiomorphicCard> createState() => _BiomorphicCardState();
}

class _BiomorphicCardState extends State<BiomorphicCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = widget.color ?? AppTheme.seedGreen.withOpacity(0.9);
    
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: CustomPaint(
                painter: _BiomorphicCardPainter(
                  color: cardColor,
                ),
                child: Container(
                  height: widget.height,
                  width: widget.width,
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Painter для отрисовки формы карточки с биоморфным дизайном
class _BiomorphicCardPainter extends CustomPainter {
  final Color color;
  final math.Random _random = math.Random(12345); // Фиксированный seed для воспроизводимости
  
  _BiomorphicCardPainter({
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Создаем базовую форму с неровными краями
    final Path path = Path();
    
    // Число точек для создания неровного контура
    const int points = 20;
    
    // Стартовые координаты
    path.moveTo(size.width * 0.1, 0);
    
    // Верхняя часть
    for (int i = 0; i < points; i++) {
      final x = size.width * 0.1 + (size.width * 0.8) * (i / (points - 1));
      final variance = _random.nextDouble() * size.height * 0.05;
      path.lineTo(x, variance);
    }
    
    // Правая часть
    for (int i = 0; i < points; i++) {
      final y = (size.height * (i / (points - 1)));
      final variance = size.width - size.width * 0.1 + _random.nextDouble() * size.width * 0.05;
      path.lineTo(variance, y);
    }
    
    // Нижняя часть (обратный порядок)
    for (int i = points - 1; i >= 0; i--) {
      final x = size.width * 0.1 + (size.width * 0.8) * (i / (points - 1));
      final variance = size.height - _random.nextDouble() * size.height * 0.05;
      path.lineTo(x, variance);
    }
    
    // Левая часть (обратный порядок)
    for (int i = points - 1; i >= 0; i--) {
      final y = (size.height * (i / (points - 1)));
      final variance = size.width * 0.1 - _random.nextDouble() * size.width * 0.05;
      path.lineTo(variance, y);
    }
    
    path.close();
    
    // Создаем тень
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    final shadowPath = Path.from(path);
    shadowPath.shift(const Offset(0, 4));
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Рисуем основную форму с градиентом
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final LinearGradient gradient = LinearGradient(
      colors: [
        color.withOpacity(0.9),
        color.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, gradientPaint);
    
    // Добавляем текстуру "бумаги"
    final texturePaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 0.5;
    
    for (int i = 0; i < 10; i++) {
      final startX = _random.nextDouble() * size.width;
      final startY = _random.nextDouble() * size.height;
      final length = _random.nextDouble() * size.width * 0.3;
      final angle = _random.nextDouble() * math.pi;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(
          startX + math.cos(angle) * length,
          startY + math.sin(angle) * length
        ),
        texturePaint,
      );
    }
    
    // Добавляем блик
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;
      
    final highlightPath = Path();
    highlightPath.moveTo(size.width * 0.1, size.height * 0.1);
    highlightPath.quadraticBezierTo(
      size.width * 0.25, size.height * 0.05,
      size.width * 0.4, size.height * 0.15
    );
    highlightPath.quadraticBezierTo(
      size.width * 0.3, size.height * 0.3,
      size.width * 0.15, size.height * 0.25
    );
    highlightPath.quadraticBezierTo(
      size.width * 0.05, size.height * 0.2,
      size.width * 0.1, size.height * 0.1
    );
    
    canvas.drawPath(highlightPath, highlightPaint);
  }
  
  @override
  bool shouldRepaint(covariant _BiomorphicCardPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
