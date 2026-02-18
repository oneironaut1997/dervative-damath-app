import 'package:flutter/material.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
  final String mode; // "PvP" or "PvC"
  const GameScreen({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(mode == 'PvC' ? 'Derivative Damath – PvC' : 'Derivative Damath – PvP'),
        centerTitle: true,
      ),
      body: const Center(child: GameBoard()),
    );
  }
}
