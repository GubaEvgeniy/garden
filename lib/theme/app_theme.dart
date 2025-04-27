import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Класс с определением общей темы для приложения
/// с биоморфными элементами дизайна
class AppTheme {
  // Приватный конструктор
  AppTheme._();
  
  // Цветовая палитра приложения
  static const Color seedGreen = Color(0xFF80C683);
  static const Color leafGreen = Color(0xFF3E8948);
  static const Color branchBrown = Color(0xFF8B5A2B);
  static const Color soilBrown = Color(0xFF5D4037);
  static const Color skyBlue = Color(0xFFAED9E0);
  static const Color sunYellow = Color(0xFFFFC107);
  static const Color flowerPink = Color(0xFFF8BBD0);
  static const Color flowerPurple = Color(0xFFCE93D8);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [seedGreen, leafGreen],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    colors: [flowerPink, flowerPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Colors.white, skyBlue],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Основная светлая тема приложения
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    primaryColor: seedGreen,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedGreen,
      primary: seedGreen,
      secondary: flowerPink,
      tertiary: skyBlue,
      background: Colors.white,
    ),
    
    // Определение стиля текста
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: leafGreen,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: leafGreen,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: leafGreen,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: soilBrown,
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: soilBrown,
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Стилизация кнопок
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seedGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    
    // Стилизация карточек
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    
    // Стилизация AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: seedGreen,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w600,
      ),
    ),
    
    // Стилизация InputDecoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: seedGreen.withOpacity(0.5), width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: seedGreen.withOpacity(0.5), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: seedGreen, width: 2),
      ),
      hintStyle: TextStyle(
        color: soilBrown.withOpacity(0.5),
        fontSize: 16,
      ),
    ),
    
    // Стилизация диалогов
    dialogTheme: DialogTheme(
      backgroundColor: Colors.white,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
  );
  
  // Темная тема приложения
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    primaryColor: seedGreen,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedGreen,
      primary: seedGreen,
      secondary: flowerPink,
      tertiary: skyBlue,
      background: const Color(0xFF121212),
      brightness: Brightness.dark,
    ),
    
    // Темная тема текста
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: seedGreen,
        letterSpacing: 0.5,
      ),
      displayMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: seedGreen,
      ),
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        color: seedGreen,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: Colors.white.withOpacity(0.87),
        letterSpacing: 0.2,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: Colors.white.withOpacity(0.87),
      ),
      labelLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    
    // Темные кнопки
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: seedGreen,
        foregroundColor: Colors.white,
        elevation: 3,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    ),
    
    // Темные карточки
    cardTheme: CardTheme(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
  );
}
