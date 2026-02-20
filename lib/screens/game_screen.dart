import 'package:flutter/material.dart';
import '../utils/sound_service.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final String mode; // "PvP" or "PvC"
  final bool useTimer; // Whether to enable turn timer

  const GameScreen({
    super.key,
    required this.mode,
    this.useTimer = true,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Start background music when game screen is shown
    SoundService().startBackgroundMusic();
  }

  @override
  void dispose() {
    // Stop background music when leaving the game screen
    SoundService().stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == 'PvC' ? 'Derivative Damath – PvC' : 'Derivative Damath – PvP',
        ),
        centerTitle: true,
      ),
      body: GameBoard(mode: widget.mode, useTimer: widget.useTimer),
    );
  }
}
