import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:garden_of_soul/theme/app_theme.dart';
import 'package:garden_of_soul/providers/garden_provider.dart';
import 'package:garden_of_soul/services/database_service.dart';
import 'package:garden_of_soul/router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация сервисов
  final databaseService = await DatabaseService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GardenProvider(databaseService)),
      ],
      child: const GardenApp(),
    ),
  );
}

class GardenApp extends StatelessWidget {
  const GardenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Garden of Soul',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
