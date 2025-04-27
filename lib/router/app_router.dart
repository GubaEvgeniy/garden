import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:garden_of_soul/screens/seed_screen.dart';
import 'package:garden_of_soul/screens/branch_screen.dart';
import 'package:garden_of_soul/screens/tree_visualization_screen.dart';

/// Сервис маршрутизации с использованием go_router
class AppRouter {
  /// Создание роутера
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Основные маршруты
      GoRoute(
        path: '/',
        name: 'seed',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SeedScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/branch/:branchId',
        name: 'branch',
        pageBuilder: (context, state) {
          final branchId = state.pathParameters['branchId'] ?? '';
          return CustomTransitionPage<void>(
            key: state.pageKey,
            child: const BranchScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
      GoRoute(
        path: '/tree',
        name: 'tree',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const TreeVisualizationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Страница не найдена: ${state.error}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => GoRouter.of(context).go('/'),
              child: const Text('Вернуться к началу'),
            ),
          ],
        ),
      ),
    ),
  );
}
