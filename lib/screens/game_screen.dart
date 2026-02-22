import 'package:flutter/material.dart';
import '../utils/sound_service.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  final String mode; // "PvP" or "PvC"
  final bool useTimer; // Whether to enable turn timer
  final String? difficulty; // "easy", "medium", "hard" for PvC
  
  const GameScreen({
    super.key,
    required this.mode,
    this.useTimer = true,
    this.difficulty,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    // Background music temporarily disabled
    // SoundService().startBackgroundMusic();
  }

  @override
  void dispose() {
    // Background music temporarily disabled
    // SoundService().stopBackgroundMusic();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == 'PvC' 
            ? 'Derivative Damath – ${_getDifficultyLabel(widget.difficulty)}' 
            : 'Derivative Damath – PvP',
        ),
        centerTitle: true,
      ),
      body: GameBoard(
        mode: widget.mode, 
        useTimer: widget.useTimer,
        difficulty: widget.difficulty,
      ),
    );
  }
  
  String _getDifficultyLabel(String? difficulty) {
    switch (difficulty) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return 'PvC';
    }
  }
}
