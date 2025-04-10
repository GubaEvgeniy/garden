import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:garden_of_feelings/presentation/game/cloud_game.dart';

class AnimatedGardenScreen1 extends StatefulWidget {
  const AnimatedGardenScreen1({Key? key}) : super(key: key);

  @override
  _AnimatedGardenScreenState createState() => _AnimatedGardenScreenState();
}

class _AnimatedGardenScreenState extends State<AnimatedGardenScreen1>
    with SingleTickerProviderStateMixin {
  late AnimationController _cloudsController;

  @override
  void dispose() {
    _cloudsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Можно обернуть в Scaffold, если хотим полноценный экран с AppBar
    return Scaffold(
      appBar: AppBar(title: const Text('Анимированный пиксель-арт сад')),
      body: Stack(
        children: [
          _buildSky(),
          _buildMountains(),
          _buildCloudsLayer(),
          _buildGrass(),
          // _buildTree(),
          // _buildBush(),
          // _buildFlower(),
        ],
      ),
    );
  }

  Widget _buildSky() {
    return Positioned(
      child: Image.asset(
        'assets/images/prod/sky3.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildMountains() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Image.asset(
        'assets/images/prod/mountain3.png',
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildCloudsLayer() {
    return Positioned.fill(
      child: GameWidget(
        game: CloudsGame(),
        backgroundBuilder: (context) {
          return Container(color: Colors.transparent);
        },
      ),
    );
  }

  Widget _buildGrass() {
    return Positioned(
      bottom: 00,
      left: 0,
      right: 0,
      child: Image.asset('assets/images/prod/grass.png', fit: BoxFit.cover),
    );
  }

  Widget _buildTree() {
    return Positioned(
      bottom: 20,
      left: 30,
      child: Image.asset('assets/prod/tree.png'),
    );
  }

  Widget _buildBush() {
    return Positioned(
      bottom: 15,
      left: 100,
      child: Image.asset('assets/prod/bush.png'),
    );
  }

  Widget _buildFlower() {
    return Positioned(
      bottom: 15,
      left: 160,
      child: Image.asset('assets/prod/flower.png'),
    );
  }
}
