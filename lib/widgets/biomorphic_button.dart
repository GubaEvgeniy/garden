import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:garden_of_soul/theme/app_theme.dart';

/// Кастомная кнопка с биоморфным дизайном, 
/// форма которой напоминает лист или семя
class BiomorphicButton extends StatefulWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final double height;
  final double width;
  final bool isPositive;
  
  const BiomorphicButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.color,
    this.height = 56.0,
    this.width = 200.0,
    this.isPositive = true,
  }) : super(key: key);

  @override
  State<BiomorphicButton> createState() => _BiomorphicButtonState();
}

class _BiomorphicButtonState extends State<BiomorphicButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), 
      vsync: this
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut)
    );
    
    // Небольшой поворот для эффекта "живого" листа
    _rotateAnimation = Tween<double>(begin: 0, end: 0.01).animate(
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
    final color = widget.color ?? (widget.isPositive 
        ? AppTheme.seedGreen 
        : AppTheme.flowerPink);
    
    return MouseRegion(
      onEnter: (_) => _controller.forward(),
      onExit: (_) => _controller.reverse(),
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotateAnimation.value,
                child: CustomPaint(
                  painter: _LeafButtonPainter(
                    color: color,
                    isPositive: widget.isPositive,
                  ),
                  child: Container(
                    height: widget.height,
                    width: widget.width,
                    alignment: Alignment.center,
                    child: Text(
                      widget.text,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Кастомный painter для отрисовки формы листа/семени
class _LeafButtonPainter extends CustomPainter {
  final Color color;
  final bool isPositive;
  
  _LeafButtonPainter({
    required this.color,
    required this.isPositive,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
      
    // Создаем базовый path в форме листа или семени
    final Path path = Path();
    
    if (isPositive) {
      // Форма листа для "Да"
      path.moveTo(size.width * 0.2, size.height * 0.5);
      path.quadraticBezierTo(
        size.width * 0.05, size.height * 0.25, 
        size.width * 0.2, size.height * 0.1
      );
      path.quadraticBezierTo(
        size.width * 0.5, 0, 
        size.width * 0.8, size.height * 0.1
      );
      path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.25, 
        size.width * 0.8, size.height * 0.5
      );
      path.quadraticBezierTo(
        size.width * 0.95, size.height * 0.75, 
        size.width * 0.8, size.height * 0.9
      );
      path.quadraticBezierTo(
        size.width * 0.5, size.height, 
        size.width * 0.2, size.height * 0.9
      );
      path.quadraticBezierTo(
        size.width * 0.05, size.height * 0.75, 
        size.width * 0.2, size.height * 0.5
      );
    } else {
      // Форма семени для "Нет"
      path.moveTo(size.width * 0.1, size.height * 0.5);
      path.quadraticBezierTo(
        size.width * 0.1, size.height * 0.15, 
        size.width * 0.5, size.height * 0.1
      );
      path.quadraticBezierTo(
        size.width * 0.9, size.height * 0.15, 
        size.width * 0.9, size.height * 0.5
      );
      path.quadraticBezierTo(
        size.width * 0.9, size.height * 0.85, 
        size.width * 0.5, size.height * 0.9
      );
      path.quadraticBezierTo(
        size.width * 0.1, size.height * 0.85, 
        size.width * 0.1, size.height * 0.5
      );
    }
    
    // Создаем тень
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      
    final shadowPath = Path.from(path);
    shadowPath.shift(const Offset(0, 4));
    canvas.drawPath(shadowPath, shadowPaint);
    
    // Рисуем основную форму
    canvas.drawPath(path, paint);
    
    // Добавляем градиент
    final Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final LinearGradient gradient = LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    
    final gradientPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
      
    canvas.drawPath(path, gradientPaint);
    
    // Добавляем небольшие детали для придания "жизни"
    if (isPositive) {
      // Жилки листа
      final detailPaint = Paint()
        ..color = Colors.white.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
        
      final midX = size.width / 2;
      final midY = size.height / 2;
      
      // Центральная жилка
      canvas.drawLine(
        Offset(midX, size.height * 0.15),
        Offset(midX, size.height * 0.85),
        detailPaint,
      );
      
      // Боковые жилки
      for (int i = 1; i <= 3; i++) {
        final y = size.height * (0.3 + i * 0.15);
        
        // Левая жилка
        canvas.drawLine(
          Offset(midX, y),
          Offset(midX - size.width * 0.2, y - size.height * 0.05),
          detailPaint,
        );
        
        // Правая жилка
        canvas.drawLine(
          Offset(midX, y),
          Offset(midX + size.width * 0.2, y - size.height * 0.05),
          detailPaint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant _LeafButtonPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.isPositive != isPositive;
  }
}
