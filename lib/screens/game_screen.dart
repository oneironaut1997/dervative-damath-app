import 'package:flutter/material.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
  final String mode; // "PvP" or "PvC"
  final bool useTimer; // Whether to enable turn timer

  const GameScreen({
    super.key,
    required this.mode,
    this.useTimer = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == 'PvC' ? 'Derivative Damath – PvC' : 'Derivative Damath – PvP',
        ),
        centerTitle: true,
      ),
      body: GameBoard(mode: mode, useTimer: useTimer),
    );
  }
}
